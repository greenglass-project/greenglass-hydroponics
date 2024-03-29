package io.greenglass.hydroponics.application.installations

import checkExists
import checkNullSuccessOrNotFoundError
import checkSuccess
import checkSuccessOrNull
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*
import kotlin.coroutines.coroutineContext
import java.time.ZonedDateTime

import io.github.oshai.kotlinlogging.KotlinLogging
import io.greenglass.host.application.error.ErrorCodes.Companion.ILLEGAL_STATE_CHANGE
import io.greenglass.host.application.error.ErrorCodes.Companion.INTERNAL_ERROR
import io.greenglass.host.application.error.ErrorCodes.Companion.OBJECT_NOT_FOUND
import io.greenglass.host.application.error.NotFoundException
import io.greenglass.host.application.nats.NatsService

import io.greenglass.host.control.controlprocess.models.ProcessVariableModel
import io.greenglass.host.control.controlprocess.providers.MetricProvider
import io.greenglass.host.control.system.SystemInstance

import io.greenglass.hydroponics.application.models.installation.InstallationModel
import io.greenglass.hydroponics.application.models.recipe.phase.ControlledPhaseModel
import io.greenglass.hydroponics.application.models.recipe.phase.ManualPhaseModel
import io.greenglass.hydroponics.application.graphdb.GraphRepository
import io.greenglass.hydroponics.application.installations.phases.ControlledPhaseRunner
import io.greenglass.hydroponics.application.installations.phases.ManualPhaseRunner
import io.greenglass.hydroponics.application.installations.phases.SequencePhaseRunner
import io.greenglass.hydroponics.application.models.jobs.JobContextModel
import io.greenglass.hydroponics.application.models.jobs.JobState

import io.greenglass.sparkplug.datatypes.MetricIdentifier
import io.greenglass.sparkplug.datatypes.MetricValue
import io.greenglass.sparkplug.datatypes.NodeMetricNameValue
import io.greenglass.sparkplug.models.Metric
import io.greenglass.sparkplug.models.PhysicalNode

import io.greenglass.host.application.error.Result
import io.greenglass.host.application.microservice.microService
import io.greenglass.host.application.microservice.publishEvent
import io.greenglass.host.application.nats.publishToNats

import io.greenglass.host.sparkplug.SparkplugService

import io.greenglass.host.control.controlprocess.process.Process
import io.greenglass.host.control.controlprocess.registry.ProcessRegistry
import io.greenglass.sparkplug.datatypes.toMetricValue

@OptIn(DelicateCoroutinesApi::class)
class InstallationsManager(
    private val repository: GraphRepository,
    private val sparkplugService: SparkplugService,
    private val processRegistry: ProcessRegistry,
    private val nats: NatsService,
) : MetricProvider {

    /**
     * InstallationContext
     *
     * @property instance
     * @property controlPhaseRunner
     * @property manualPhaseRunner
     * @property jobCtx
     * @property instanceControl
     * @property nodesCtxs
     * @property processesCtxs
     */
    data class InstallationContext(
        val instance: SystemInstance,
        val controlPhaseRunner: ControlledPhaseRunner,
        val manualPhaseRunner: ManualPhaseRunner,
        var jobCtx: JobContextModel?,
        val instanceControl: MutableStateFlow<Boolean>,
        val nodesCtxs: Map<String,NodeContext>,
        val processesCtxs : Map<String, ProcessContext>
    )

    /**
     * ProcessContext
     *
     * @property procesId
     * @property process
     * @property processState
     * @property variableCtxs
     * @property variablesMap
     */
    data class ProcessContext(
        val procesId : String,
        val process : Process,
        val processState : StateFlow<MetricValue>,
        val variableCtxs : Map<String, VariableContext>?,
        val variablesMap : Map<String, MetricIdentifier>
    )

    /**
     * VariableContext
     *
     * @property variable
     * @property metricIdentifier
     * @property metricValue
     * @property setPointValue
     */
    data class VariableContext(
        val variable : ProcessVariableModel,
        val metricIdentifier : MetricIdentifier,
        val metricValue : StateFlow<MetricValue>,
        val setPointValue : StateFlow<MetricValue>
    )

    /**
     * NodeContext
     *
     * @property node
     * @property state
     * @property metricsCtxs
     */
    data class NodeContext(
        val node : PhysicalNode,
        val state : StateFlow<Boolean>,
        val metricsCtxs : Map<String,MetricContext>
    )

    data class MetricContext(
        val metric : Metric,
        val value : StateFlow<MetricValue>
    )

    val logger = KotlinLogging.logger {}
    private lateinit var installationScope: CoroutineScope

    @OptIn(ExperimentalCoroutinesApi::class)
    val dispatcher = newSingleThreadContext("installations")
    private val installations: HashMap<String, InstallationContext> = hashMapOf()
    val jobFlow: MutableSharedFlow<JobContextModel> = MutableSharedFlow(1)

    private fun nodeState(instId : String, nodeId : String) =
        checkNullSuccessOrNotFoundError(
            objId = nodeId,
            obj = installations[instId]
                ?.nodesCtxs
                ?.get(nodeId)
                ?.state
                ?.value
                ?.let {s -> MetricValue(s)}
        )

    private fun metricValues(instId : String, nodeId : String) =
        checkNullSuccessOrNotFoundError(
            objId = nodeId,
            obj = installations[instId]
                ?.nodesCtxs
                ?.get(nodeId)
                ?.metricsCtxs
                ?.values
                ?.map { mc -> NodeMetricNameValue(
                    nodeId = nodeId,
                    metricName = mc.metric.metricName,
                    value = mc.value.value
                )
                }
        )

    private fun variableValue(instId : String, processId : String, variableId : String) =
        installations[instId]
            ?.processesCtxs
            ?.get(processId)
            ?.variableCtxs
            ?.get(variableId)
            ?.metricValue
            ?.value

    private fun variableSetpoint(instId : String, processId : String, variableId : String) =
        installations[instId]
            ?.processesCtxs
            ?.get(processId)
            ?.variableCtxs
            ?.get(variableId)
            ?.setPointValue
            ?.value

    fun findOneInstallationNodes(installationId: String) =
        checkNullSuccessOrNotFoundError(
            objId = installationId,
            obj = installations[installationId]?.nodesCtxs?.values?.map { n -> n.node }
        )

    suspend fun run() {
        logger.debug { "Starting InstallationsManager" }

        installationScope = CoroutineScope(coroutineContext)

        //init {
        checkSuccess(repository.findAllInstallations()).forEach { i ->
            val instCtx = createInstallation(i)
            val jobCtx = instCtx.jobCtx
            if (jobCtx != null) {
                logger.debug { "Installation has active job " }
                when (val currentPhase = jobCtx.currentPhase()) {
                    is ControlledPhaseModel -> instCtx.controlPhaseRunner.resumePhase(
                        currentPhase,
                        jobCtx.job.phaseEnd!!
                    )

                    is ManualPhaseModel -> instCtx.manualPhaseRunner.resumePhase(currentPhase, jobCtx.job.phaseEnd!!)
                }
            }
        }
    }

    fun addInstallation(installation: InstallationModel) : Result<Unit> {
        val result = repository.addInstallation(installation)
        if(result is Result.Success)
            createInstallation(installation)
        return result
    }

    private fun createInstallation(inst: InstallationModel): InstallationContext {
        logger.debug { "createInstallation() ${inst.installationId}" }
        val hydroponicsSystemModel = checkSuccess(repository.findOneInstallationSystem(inst.installationId))
        val installationNodes = checkSuccess(repository.findOneInstallationNodes(inst.installationId))

        // Register the installation nodes with Sparkplug
        installationNodes.forEach { nd -> sparkplugService.addNode(nd) }

        // Impl node to physical map implNodeId -> nodeId
        val implNodes = checkSuccess(repository.findImplementationNodes(inst.implementationId))
        val implToPhysicalMap = inst.physicalNodes.associate { pn -> pn.implNodeId to pn.nodeId }

        // Variable map variableId -> MetricIdentifier
        val variablesMap = implNodes
            .map { i -> i.toVariableTriple() }
            .flatten()
            .associate { t -> t.second to MetricIdentifier(checkExists(implToPhysicalMap[t.first]), t.third) }

        installationNodes.forEach { pn ->
            sparkplugService.addNode(pn)
        }


        logger.debug { "Instantiating installation ${inst.installationId} " }
        val systemModel = hydroponicsSystemModel.toControlledSystemModel()

        val controlPhaseRunner = ControlledPhaseRunner(inst.installationId, hydroponicsSystemModel.processSchedulers)
        val manualPhaseRunner = ManualPhaseRunner(inst.installationId)
        val sequencePhaseRunner = SequencePhaseRunner(inst.installationId)
        val jobContext = checkSuccessOrNull(repository.findOneJob(inst.installationId))

        val instanceControl = MutableStateFlow(false)

        val processes : List<Process> = systemModel.processes.map { p ->
                processRegistry.processForName(
                    name = p.process,
                    instanceId = inst.installationId,
                    processModel = p,
                    metricProvider = this,
                    setpointProvider = controlPhaseRunner,
                    processStateProvider = controlPhaseRunner,
                    sparkplugService = sparkplugService,
                    dispatcher = dispatcher
                )
        }

        val installationSystem = SystemInstance(
            instanceId = inst.installationId,
            systemModel = systemModel,
            processes = processes,
            sequences = listOf()
        )

        val nodeContexts = installationNodes.associate { n ->
            n.nodeId to NodeContext(
                node = n,
                state = sparkplugService.subscribeToNodeState(n.nodeId),
                metricsCtxs = n.metrics.associate {
                        m -> m.metricName to MetricContext(
                        metric = m,
                        value = sparkplugService.subscribeToMetric(n.nodeId, m.metricName)
                    )
                }
            )
        }

        val processContexts = processes.associate { p ->
            p.processModel.processId to ProcessContext(
                procesId = p.processModel.processId,
                process = p,
                processState = p.subscribeProcessState(),
                variableCtxs = p.processModel.processVariables?.associate { pv ->
                    pv.variableId to VariableContext(
                        variable = pv,
                        metricIdentifier = checkExists(variablesMap[pv.variableId]),
                        metricValue = sparkplugService.subscribeToMetric(variablesMap[pv.variableId]!!),
                        setPointValue = p.subscribePVsetpoint(pv.variableId)
                    )
                },
                variablesMap = variablesMap
            )
        }

        // Create the installation context
        val instCtx = InstallationContext(
            instance = installationSystem,
            controlPhaseRunner = controlPhaseRunner,
            manualPhaseRunner = manualPhaseRunner,
            jobCtx = jobContext,
            instanceControl = instanceControl,
            nodesCtxs = nodeContexts,
            processesCtxs = processContexts
        )
        installations[inst.installationId] = instCtx

        nodeContexts.values.forEach { i ->

            // Set up a subscriber and public the node state an a
            // Metric value event
            installationScope.launch(dispatcher) {
                i.state.toMetricValue()
                    .publishToNats(nats, "event.installations.${inst.installationId}.nodes.${i.node.nodeId}.state")
            }

            // Set up subscribers for each metric in the node and publish
            // changes as NodeMetricNameValue events
            i.metricsCtxs.values.forEach { m ->
                installationScope.launch(dispatcher) {
                    m.value
                        .map { v -> NodeMetricNameValue(i.node.nodeId, m.metric.metricName, v) }
                        .publishToNats(nats, "event.installations.${inst.installationId}.nodes.${i.node.nodeId}.metrics")
                }
            }
        }

        // Set up a subscriber for the installation state
        installationScope.launch(dispatcher) {
            instanceControl.asStateFlow()
                .toMetricValue()
                .publishEvent(
                    nats = nats,
                    topic = "event.installations.${inst.installationId}.state"
                )
        }

        // Iterate through this installation's processes
        processContexts.values.forEach { p ->

            // Set up a subscriber for the process' state
            //val procState = p.subscribeProcessState()
            installationScope.launch(dispatcher) {
                p.processState
                    .publishEvent(
                        nats = nats,
                        topic = "event.installations.${inst.installationId}.processes.${p.procesId}.state",
                    )
            }

            // Set up subscribers for the process variable values and set points
                p.variableCtxs?.values?.forEach { vc ->
                    installationScope.launch(dispatcher) {
                        vc.metricValue.publishEvent(
                            nats = nats,
                            topic = "event.installations.${inst.installationId}.processes.${p.procesId}.variables.${vc.variable.variableId}.value",
                        )
                    }
                    installationScope.launch(dispatcher) {
                        vc.setPointValue.publishEvent(
                            nats = nats,
                            topic = "event.installations.${inst.installationId}.processes.${p.procesId}.variables.${vc.variable.variableId}.setpoint",
                        )
                    }
            }

            // Run the process
            installationScope.launch(dispatcher) { p.process.run() }
        }

        // =================================================================================================
        // Microservices
        // =================================================================================================

        // Publish a metric
        installationScope.launch(dispatcher) {
            microService<NodeMetricNameValue, Unit>(nats,
                "set.installations.${inst.installationId}.node.{nodeId}.metric")
            { m -> publishMetricValue(
                instanceId = inst.installationId,
                metricValue = m.obj!!)
            }
        }

        // Process state
        installationScope.launch(dispatcher) {
            microService<Unit, MetricValue>(nats,
                    "findone.installations.${inst.installationId}.processes.{processId}.state")
                { m -> checkNullSuccessOrNotFoundError(
                    m.topic.stringParam("processId"),processContexts[m.topic.stringParam("processId")]?.processState?.value)
            }
        }

        // process variable value
        installationScope.launch(dispatcher) {
            microService<Unit, MetricValue>(
                nats,
                "findone.installations.${inst.installationId}.processes.{processId}.variables.{variable}.value"
            )
            { m ->
                checkNullSuccessOrNotFoundError(
                    m.topic.stringParam("processId"),
                    variableValue(
                        instId = inst.installationId,
                        processId = m.topic.stringParam("processId"),
                        variableId = m.topic.stringParam("variableId")
                    )
                )
            }
        }

        // Node state
        installationScope.launch(dispatcher) {
            microService<Unit, MetricValue>(nats, "findone.installations.${inst.installationId}.nodes.{nodeId}.state")
                { m -> nodeState(inst.installationId, m.topic.stringParam("nodeId")) }
        }

        // Node metrics
        installationScope.launch(dispatcher) {
            microService<Unit, List<NodeMetricNameValue>>(nats, "findone.installations.${inst.installationId}.nodes.{nodeId}.metrics")
            { m -> metricValues(inst.installationId, m.topic.stringParam("nodeId")) }
        }

        logger.debug { "createInstallation complete" }
            return instCtx
    }


    fun startJob(installationId: String): Result<JobContextModel> {
        val instCtx = installations[installationId] ?: return Result.Failure(OBJECT_NOT_FOUND, installationId)
        val jobCtx = instCtx.jobCtx ?: return Result.Failure(OBJECT_NOT_FOUND, installationId)

        if (jobCtx.job.state != JobState.Inactive)
            return Result.Failure(ILLEGAL_STATE_CHANGE, installationId)

        val phase = jobCtx.recipe.phases[0]
        val endPhase = ZonedDateTime.now().plusDays(phase.duration.toLong())

        repository.startJob(jobCtx.job.jobId, phase.phaseId, endPhase).let { r ->
            return when (r) {
                is Result.Success -> {
                    jobCtx.job = r.value // replace the job model
                    when (val currentPhase = jobCtx.currentPhase()) {
                        is ControlledPhaseModel -> instCtx.controlPhaseRunner.startPhase(
                            currentPhase,
                            jobCtx.job.phaseEnd!!
                        )

                        is ManualPhaseModel -> instCtx.manualPhaseRunner.startPhase(currentPhase, jobCtx.job.phaseEnd!!)
                    }
                    jobFlow.tryEmit(jobCtx)
                    Result.Success(jobCtx)
                }

                is Result.Failure -> Result.Failure(r.code, r.msg)
            }
        }
    }

    fun newJob(installationId: String, recipeId: String): Result<JobContextModel> {
        return try {
            val result = repository.newJobForInstallation(installationId, recipeId)
            if(result is Result.Success) {
                installations[installationId]!!.jobCtx = result.value
                jobFlow.tryEmit(result.value)
            }
            result
        } catch (ex: NotFoundException) {
            logger.warn { "Job for $installationId not found" }
            Result.Failure(OBJECT_NOT_FOUND, installationId)
        } catch (ex: Exception) {
            logger.error { "Job for $installationId error ${ex.message}" }
            Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun nextPhase(installationId: String): Result<JobContextModel> {
        val instCtx = installations[installationId] ?: return Result.Failure(OBJECT_NOT_FOUND, installationId)
        val jobCtx = instCtx.jobCtx ?: return Result.Failure(OBJECT_NOT_FOUND, installationId)

        when (jobCtx.currentPhase()) {
            is ControlledPhaseModel -> instCtx.controlPhaseRunner.stopPhase()
            is ManualPhaseModel -> instCtx.manualPhaseRunner.stopPhase()
        }

        val nextPhase = jobCtx.nextPhase()
        if (nextPhase != null) {
            val endPhase = ZonedDateTime.now().plusDays(nextPhase.duration.toLong())
            repository.setJobPhase(jobCtx.job.jobId, nextPhase.phaseId, endPhase).let { r ->
                return when (r) {
                    is Result.Success -> {
                        jobCtx.job = r.value // replace the job model
                        when (val currentPhase = jobCtx.currentPhase()) {
                            is ControlledPhaseModel -> instCtx.controlPhaseRunner.startPhase(
                                currentPhase,
                                jobCtx.job.phaseEnd!!
                            )

                            is ManualPhaseModel -> instCtx.manualPhaseRunner.startPhase(
                                currentPhase,
                                jobCtx.job.phaseEnd!!
                            )
                        }
                        jobFlow.tryEmit(jobCtx)
                        Result.Success(jobCtx)
                    }

                    is Result.Failure -> Result.Failure(r.code, r.msg)
                }
            }
        } else {
            repository.completeJob(jobCtx.job.jobId).let { r ->
                return when (r) {
                    is Result.Success -> {
                        jobCtx.job = r.value // replace the job model
                        jobFlow.tryEmit(jobCtx)
                        Result.Success(jobCtx)
                    }

                    is Result.Failure -> Result.Failure(r.code, r.msg)
                }
            }
        }
    }

    override fun metricForVariable(instanceId: String, processId: String, variableId: String) : MetricIdentifier {
        val instCtx = installations[instanceId]
        val processCtx = instCtx?.processesCtxs?.get(processId)
        val metric = processCtx?.variablesMap?.get(variableId)
        if(metric == null)
            logger.debug { "Metric for variable $instanceId $processId $variableId not found"}
        return checkNotNull(metric)
    }


    private fun publishMetricValue(instanceId: String, metricValue : NodeMetricNameValue) : Result<Unit> {
        val inst = installations[instanceId] ?: return Result.Failure(OBJECT_NOT_FOUND, instanceId)
        val node = inst.nodesCtxs[metricValue.nodeId] ?: return Result.Failure(OBJECT_NOT_FOUND, metricValue.nodeId)
        if(node.metricsCtxs[metricValue.metricName] == null) return Result.Failure(OBJECT_NOT_FOUND, metricValue.metricName)
        sparkplugService.publishToMetric(metricValue.nodeId, metricValue.metricName, metricValue.value)
        return Result.Success(Unit)
    }



//checkNotNull(installations[instanceId]
        //    ?.processesCtxs
        //    ?.get(processId)
        //    ?.variableCtxs
        //    ?.get(variableId)
        //).metricIdentifier
}

