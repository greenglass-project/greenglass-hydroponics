package io.greenglass.hydroponics.application.microservices

import checkNullSuccessOrNotFoundError
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.asStateFlow

import io.greenglass.hydroponics.application.graphdb.GraphRepository
import io.greenglass.hydroponics.application.installations.InstallationsManager

import io.greenglass.hydroponics.application.models.implementation.ImplementationModel
import io.greenglass.hydroponics.application.models.installation.InstallationModel
import io.greenglass.hydroponics.application.models.installation.InstallationViewModel
import io.greenglass.hydroponics.application.models.jobs.StartJobModel
import io.greenglass.hydroponics.application.models.recipe.PlantModel
import io.greenglass.hydroponics.application.models.recipe.RecipeModel
import io.greenglass.hydroponics.application.models.recipe.RecipeViewModel
import io.greenglass.hydroponics.application.models.recipe.SystemRecipesViewModel
import io.greenglass.hydroponics.application.models.recipe.phase.AddPhaseModel
import io.greenglass.hydroponics.application.models.recipe.phase.PhaseModel
import io.greenglass.hydroponics.application.models.system.HydroponicsSystemModel
import io.github.oshai.kotlinlogging.KotlinLogging
import io.greenglass.host.application.microservice.microService
import io.greenglass.host.application.microservice.publishEvent
import io.greenglass.host.application.nats.NatsService
import io.greenglass.host.application.nats.messages.NatsMessageOut
import io.greenglass.host.application.nats.publishToNats
import io.greenglass.host.control.controlprocess.models.ProcessModel
import io.greenglass.hydroponics.application.models.config.CoroutineScopes
import io.greenglass.hydroponics.application.models.config.MasterConfig
import io.greenglass.hydroponics.application.models.installation.InstallationNodeModel
import io.greenglass.hydroponics.application.models.jobs.JobContextModel
import io.greenglass.sparkplug.datatypes.MetricValue
import io.greenglass.sparkplug.datatypes.NodeMetricNameValue
import io.greenglass.sparkplug.datatypes.toMetricValue
import io.greenglass.sparkplug.models.NodeType

class MicroServices(
    private val ns: NatsService,
    private val repository: GraphRepository,
    private val installations: InstallationsManager,
    private val coroutineScopes: CoroutineScopes
) {

    private val logger = KotlinLogging.logger {}

    suspend fun runMasterConfig() {
        logger.debug { "Starting NodeMicroservice - master config" }
        
        // ========================= Master Config ==================================
        coroutineScopes.microServicesScope.launch {
            microService<Unit, MasterConfig>(ns, "findone.masterconfig")
            { m -> repository.findOneMasterConfig() } }

        coroutineScopes.microServicesScope.launch {
            microService<MasterConfig, Unit>(ns, "add.masterconfig")
            { m -> repository.addMasterConfig(m.obj!!) } }

        coroutineScopes.microServicesScope.launch {
            microService<MasterConfig, Unit>(ns, "update.masterconfig")
            { m -> repository.updateMasterConfig(m.obj!!) } }
    }

    suspend fun run() {
        logger.debug { "Starting NodeMicroservice - all microservices" }

        // ========================= Node functions ====================================
        coroutineScopes.microServicesScope.launch {
            repository.nodeFlow.asSharedFlow()
                .map { n ->
                    NatsMessageOut(
                        topic = "event.nodetypes.${n.type}",
                        obj = n
                    )
                }
                .publishEvent(ns)
        }

        coroutineScopes.microServicesScope.launch {
            microService<Unit, List<NodeType>>(ns, "findall.nodetypes")
            { _ -> repository.findAllNodeTypes() }
        }

        coroutineScopes.microServicesScope.launch {
            microService<Unit, ByteArray>(ns, "findone.nodetypes.{type}.image")
            { m -> repository.findOneNodeImage(m.topic.stringParam("type")) }
        }

        // ========================= Plant functions ====================================
        coroutineScopes.microServicesScope.launch {
            repository.plantFlow.asSharedFlow()
                .map { p ->
                    NatsMessageOut(
                        topic = "event.plants",
                        obj = p
                    )
                }
                .publishEvent(ns)
        }

        coroutineScopes.microServicesScope.launch {
            microService<Unit, List<PlantModel>>(ns, "findall.plants")
            { _ -> repository.findAllPlants() }
        }
        coroutineScopes.microServicesScope.launch {
            microService<Unit, PlantModel>(ns, "findone.plants.{plantId}")
            { m -> repository.findOnePlant(m.topic.stringParam("plantId")) }
        }

        coroutineScopes.microServicesScope.launch {
            microService<Unit, ByteArray>(ns, "findone.plants.{plantId}.image")
            { m -> repository.findOnePlantImage(m.topic.stringParam("plantId")) }
        }

        // ========================= System functions ====================================
        coroutineScopes.microServicesScope.launch {
            repository.systemFlow.asSharedFlow()
                .map { s ->
                    NatsMessageOut(
                        topic = "event.systems.${s.systemId}",
                        obj = s
                    )
                }
                .publishEvent(ns)
        }

        coroutineScopes.microServicesScope.launch {
            microService<Unit, List<HydroponicsSystemModel>>(ns, "findall.systems")
            { _ -> repository.findAllSystems() }
        }
        coroutineScopes.microServicesScope.launch {
            microService<Unit, HydroponicsSystemModel>(ns, "findone.systems.{systemId}")
            { m -> repository.findOneSystem(m.topic.stringParam("systemId")) }
        }

        coroutineScopes.microServicesScope.launch {
            microService<Unit, List<ProcessModel>>(ns, "findall.systems.{systemId}.processes")
            { m -> repository.findAllControlProcesses(m.topic.stringParam("systemId")) }
        }

        // ========================= Recipe functions ====================================
        coroutineScopes.microServicesScope.launch {
            repository.recipeFlow.asSharedFlow()
                .map { r ->
                    NatsMessageOut(
                        topic = "event.plants.${r.plantId}.systems.${r.systemId}.recipes",
                        obj = r
                    )
                }
                .publishEvent(ns)
        }

        coroutineScopes.microServicesScope.launch {
            repository.recipeUpdateFlow.asSharedFlow()
                .map { r ->
                    NatsMessageOut(
                        topic = "event.recipes.${r.recipeId}",
                        obj = r
                    )
                }
                .publishEvent(ns)
        }

        coroutineScopes.microServicesScope.launch {
            microService<Unit, List<RecipeViewModel>>(ns, "findall.plants.{plantId}.recipes")
            { m -> repository.findAllRecipes(m.topic.stringParam("plantId")) }
        }

        coroutineScopes.microServicesScope.launch {
            microService<Unit, List<RecipeViewModel>>(ns, "findall.plants.{plantId}.systems.{systemId}.recipes")
            { m ->
                repository.findAllRecipesForPlantAndSystem(
                    m.topic.stringParam("plantId"),
                    m.topic.stringParam("systemId")
                )
            }
        }

        coroutineScopes.microServicesScope.launch {
            microService<Unit, List<SystemRecipesViewModel>>(ns, "findall.systems.{systemId}.recipes")
            { m ->
                repository.findAllRecipesByPlantForSystem(
                    m.topic.stringParam("systemId")
                )
            }
        }

        coroutineScopes.microServicesScope.launch {
            microService<Unit, RecipeModel>(ns, "findone.recipes.{recipeId}")
            { m -> repository.findOneRecipe(m.topic.stringParam("recipeId")) }
        }

        coroutineScopes.microServicesScope.launch {
            microService<RecipeModel, Unit>(ns, "add.recipe")
            { m -> repository.saveRecipe(m.obj!!) }
        }

        coroutineScopes.microServicesScope.launch {
            microService<Unit, Unit>(ns, "inuse.recipes.{recipeId}")
            { m -> repository.recipeInUse(m.topic.stringParam("recipeId")) }
        }

        coroutineScopes.microServicesScope.launch {
            microService<RecipeModel, Unit>(ns, "update.recipes.{recipeId}")
            { m -> repository.updateRecipe(m.topic.stringParam("recipeId"), m.obj!!) }
        }

        // ========================= Recipe - phases functions ====================================
        coroutineScopes.microServicesScope.launch {
            microService<AddPhaseModel, Unit>(ns, "add.recipes.{recipeId}.phases")
            { m -> repository.updateRecipeAddPhase(m.topic.stringParam("recipeId"), m.obj!!) }
        }

        coroutineScopes.microServicesScope.launch {
            microService<PhaseModel, Unit>(ns, "update.recipes.{recipeId}.phases.{phaseId}")
            { m -> repository.updateRecipeModifyPhase(
                m.topic.stringParam("recipeId"),
                m.topic.stringParam("phaseId"),
                m.obj!!
            )}
        }

        coroutineScopes.microServicesScope.launch {
            microService<PhaseModel, Unit>(ns, "delete.recipes.{recipeId}.phases.{phaseId}")
            { m -> repository.updateRecipeDeletePhase(
                m.topic.stringParam("recipeId"),
                m.topic.stringParam("phaseId"),
            )}
        }

        // ========================= Implementation functions ====================================
        coroutineScopes.microServicesScope.launch {
            repository.implementationFlow.asSharedFlow()
                .map { i ->
                    NatsMessageOut(
                        topic = "event.implementations.${i.implementationId}",
                        obj = i
                    )
                }
                .publishEvent(ns)
        }

        coroutineScopes.microServicesScope.launch {
            microService<Unit, List<ImplementationModel>>(ns, "findall.implementations")
            { _ -> repository.findAllImplementations() }
        }

        // ========================= Installation / Job functions ==================================

        coroutineScopes.microServicesScope.launch {
            microService<Unit, List<InstallationViewModel>>(ns, "findall.installations")
            { _ -> repository.findAllInstallationViews() }
        }
        coroutineScopes.microServicesScope.launch {
            microService<Unit, InstallationModel>(ns, "findone.installations.{installationId}")
            { m -> repository.findOneInstallation(m.topic.stringParam("installationId")) }
        }

        coroutineScopes.microServicesScope.launch {
            microService<Unit, List<InstallationNodeModel>>(ns, "findone.installations.{installationId}.nodes")
            { m -> repository.findOneInstallationNodes(m.topic.stringParam("installationId")) }
        }

        coroutineScopes.microServicesScope.launch {
            microService<NodeMetricNameValue, Unit>(ns,
                "set.installations.{installationId}.node.{nodeId}.metric")
            { m -> installations.publishMetricValue(
                instanceId = m.topic.stringParam("installationId"),
                metricValue = m.obj!!)
            }
        }

        // Variable value
        coroutineScopes.microServicesScope.launch {
            microService<Unit, MetricValue>(
                ns,
                "findone.installations.{installationId}.processes.{processId}.variables.{variable}.value"
            )
            { m ->
                checkNullSuccessOrNotFoundError(
                    m.topic.stringParam("variable"),
                    installations.variableValue(
                        instId = m.topic.stringParam("installationId"),
                        processId = m.topic.stringParam("processId"),
                        variableId = m.topic.stringParam("variableId")
                    )
                )
            }
        }

        // Process state
        coroutineScopes.microServicesScope.launch {
            microService<Unit, MetricValue>(ns,
                    "findone.installations.{installationId}.processes.{processId}.state")
                { m -> checkNullSuccessOrNotFoundError(
                    m.topic.stringParam("processId"),
                    installations.processState(
                        installationId = m.topic.stringParam("installationId"),
                        processId = m.topic.stringParam("processId")
                    )
                )
             }
        }

        // Node state microservice
        coroutineScopes.microServicesScope.launch {
            microService<Unit, MetricValue>(ns, "findone.installations.{installationId}.nodes.{nodeId}.state")
            { m -> installations.nodeState(
                    instId = m.topic.stringParam("installationId"),
                    nodeId =  m.topic.stringParam("nodeId")
                )
            }
        }


        // Node metrics
        coroutineScopes.microServicesScope.launch {
            microService<Unit, List<NodeMetricNameValue>>(ns, "findone.installations.{installationId}.nodes.{nodeId}.metrics")
            { m -> installations.metricValues(
                    instId = m.topic.stringParam("installationId"),
                    nodeId = m.topic.stringParam("nodeId")
                )
            }
        }

        coroutineScopes.microServicesScope.launch {
            microService<InstallationModel, Unit>(ns, "add.installations")
            { s -> installations.addInstallation(s.obj!!) }

        }

        // Installation events
        installations.installations().forEach { i ->

            // Publish installation state events
            coroutineScopes.microServicesScope.launch {
                logger.debug { "PUBLISHER FOR 'event.installations.${i.instance.instanceId}.state'" }
                i.instanceControl.asStateFlow()
                    .toMetricValue()
                    .publishEvent(
                        nats = ns,
                        topic = "event.installations.${i.instance.instanceId}.state"
                    )
            }

            // Iterate through the instattation and publish process events
            i.processesCtxs.values.forEach { p ->

                // Set up a subscriber for the process' state
                //val procState = p.subscribeProcessState()
                coroutineScopes.microServicesScope.launch {
                    logger.debug { "PUBLISHER FOR 'event.installations.${i.instance.instanceId}.processes.${p.procesId}.state'" }
                    p.processState
                        .publishEvent(
                            nats = ns,
                            topic = "event.installations.${i.instance.instanceId}.processes.${p.procesId}.state",
                        )
                }

                // Set up subscribers for the process variable values and set points
                p.variableCtxs?.values?.forEach { vc ->
                    coroutineScopes.microServicesScope.launch {
                        logger.debug { "PUBLISHER FOR 'event.installations.${i.instance.instanceId}.processes.${p.procesId}.variables.${vc.variable.variableId}.value'" }
                        vc.metricValue.publishEvent(
                            nats = ns,
                            topic = "event.installations.${i.instance.instanceId}.processes.${p.procesId}.variables.${vc.variable.variableId}.value",
                        )
                    }
                    coroutineScopes.microServicesScope.launch {
                        vc.setPointValue.publishEvent(
                            nats = ns,
                            topic = "event.installations.${i.instance.instanceId}.processes.${p.procesId}.variables.${vc.variable.variableId}.setpoint",
                        )
                    }
                }

            }

            // Publish node events
            i.nodesCtxs.values.forEach { n ->
                // Set up a subscriber and public the node state an a
                // Metric value event
                coroutineScopes.microServicesScope.launch {
                    logger.debug { "PUBLISHER FOR 'event.installations.${i.instance.instanceId}.nodes.${n.node.nodeId}.state'" }
                    n.state.toMetricValue()
                        .publishToNats(ns, "event.installations.${i.instance.instanceId}.nodes.${n.node.nodeId}.state")
                }

                // Set up subscribers for each metric in the node and publish
                // changes as NodeMetricNameValue events
                n.metricsCtxs.values.forEach { m ->
                    coroutineScopes.microServicesScope.launch {
                        logger.debug { "event.installations.${i.instance.instanceId}.nodes.${n.node.nodeId}.metrics'" }
                        m.value
                            .map { v -> NodeMetricNameValue(n.node.nodeId, m.metric.metricName, v) }
                            .publishToNats(
                                ns,
                                "event.installations.${i.instance.instanceId}.nodes.${n.node.nodeId}.metrics"
                            )
                    }
                }
            }

        }
        // Time line



        // ------ job services

        coroutineScopes.microServicesScope.launch {
            microService<StartJobModel, JobContextModel>(ns, "newjob.installations.{installationId}.recipes.{recipeId}")
            { m ->
                installations.newJob(
                    installationId = m.topic.stringParam("installationId"),
                    recipeId = m.topic.stringParam("recipeId"),
                )
            }
        }

        coroutineScopes.microServicesScope.launch {
            microService<Unit, JobContextModel>(ns, "startjob.installations.{installationId}.job")
            { m -> installations.startJob(installationId = m.topic.stringParam("installationId"),) }
        }

        coroutineScopes.microServicesScope.launch {
            microService<StartJobModel, JobContextModel>(ns, "nextphase.installations.{installationId}.job")
            { m -> installations.nextPhase(installationId = m.topic.stringParam("installationId"),) }
        }

        coroutineScopes.microServicesScope.launch {
            microService<Unit, JobContextModel>(ns, "findone.installations.{installationId}.job")
            { m -> repository.findOneJob(m.topic.stringParam("installationId")) }
        }

        // ---- events ---
        coroutineScopes.microServicesScope.launch {
            repository.installationFlow.asSharedFlow()
                .map { i ->
                    NatsMessageOut(
                        topic = "event.installations.${i.installationId}",
                        obj = i
                    )
                }
                .publishEvent(ns)
        }

        coroutineScopes.microServicesScope.launch {
            installations.jobFlow.asSharedFlow()
                .map { j ->
                    NatsMessageOut(
                        topic = "event.installations.${j.job.installationId}.job",
                        obj = j
                    )
                }
                .publishEvent(ns)
        }


    }
}
