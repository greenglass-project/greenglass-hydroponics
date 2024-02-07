package io.greenglass.hydroponics.application.microservices

import kotlinx.coroutines.*
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.map

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
import io.greenglass.host.application.microservice.StringValue
import io.greenglass.host.application.microservice.microService
import io.greenglass.host.application.microservice.publishEvent
import io.greenglass.host.application.nats.NatsService
import io.greenglass.host.application.nats.messages.NatsMessageOut
import io.greenglass.host.control.controlprocess.models.ProcessModel
import io.greenglass.hydroponics.application.models.jobs.JobContextModel
import io.greenglass.sparkplug.models.NodeType
import io.greenglass.sparkplug.models.PhysicalNode


class MicroServices(
    private val ns: NatsService,
    private val repository: GraphRepository,
    private val installations: InstallationsManager
) {

    private val logger = KotlinLogging.logger {}

    @OptIn(DelicateCoroutinesApi::class, ExperimentalCoroutinesApi::class)
    suspend fun run() {
        logger.debug { "Starting NodeMicroservice" }
        //val microServiceScope = CoroutineScope(coroutineContext)
        //val thread = newSingleThreadContext("microservices")

        val microServiceScope = CoroutineScope(newSingleThreadContext("microservices"))
        //val thread = newSingleThreadContext("microservices")

        // ========================= Node functions ====================================
        microServiceScope.launch {
            repository.nodeFlow.asSharedFlow()
                .map { n ->
                    NatsMessageOut(
                        topic = "event.nodetypes.${n.type}",
                        obj = n
                    )
                }
                .publishEvent(ns)
        }

        microServiceScope.launch {
            microService<Unit, List<NodeType>>(ns, "findall.nodetypes")
            { _ -> repository.findAllNodeTypes() }
        }

        // ========================= Plant functions ====================================
        microServiceScope.launch {
            repository.plantFlow.asSharedFlow()
                .map { p ->
                    NatsMessageOut(
                        topic = "event.plants",
                        obj = p
                    )
                }
                .publishEvent(ns)
        }

        microServiceScope.launch {
            microService<Unit, List<PlantModel>>(ns, "findall.plants")
            { _ -> repository.findAllPlants() }
        }
        microServiceScope.launch {
            microService<Unit, PlantModel>(ns, "findone.plants.{plantId}")
            { m -> repository.findOnePlant(m.topic.stringParam("plantId")) }
        }

        microServiceScope.launch {
            microService<Unit, ByteArray>(ns, "findone.plants.{plantId}.image")
            { m -> repository.findOnePlantImage(m.topic.stringParam("plantId")) }
        }

        // ========================= System functions ====================================
        microServiceScope.launch {
            repository.systemFlow.asSharedFlow()
                .map { s ->
                    NatsMessageOut(
                        topic = "event.systems.${s.systemId}",
                        obj = s
                    )
                }
                .publishEvent(ns)
        }

        microServiceScope.launch {
            microService<Unit, List<HydroponicsSystemModel>>(ns, "findall.systems")
            { _ -> repository.findAllSystems() }
        }
        microServiceScope.launch {
            microService<Unit, HydroponicsSystemModel>(ns, "findone.systems.{systemId}")
            { m -> repository.findOneSystem(m.topic.stringParam("systemId")) }
        }

        microServiceScope.launch {
            microService<Unit, List<ProcessModel>>(ns, "findall.systems.{systemId}.processes")
            { m -> repository.findAllControlProcesses(m.topic.stringParam("systemId")) }
        }

        // ========================= Recipe functions ====================================
        microServiceScope.launch {
            repository.recipeFlow.asSharedFlow()
                .map { r ->
                    NatsMessageOut(
                        topic = "event.plants.${r.plantId}.systems.${r.systemId}.recipes",
                        obj = r
                    )
                }
                .publishEvent(ns)
        }

        microServiceScope.launch {
            repository.recipeUpdateFlow.asSharedFlow()
                .map { r ->
                    NatsMessageOut(
                        topic = "event.recipes.${r.recipeId}",
                        obj = r
                    )
                }
                .publishEvent(ns)
        }

        microServiceScope.launch {
            microService<Unit, List<RecipeViewModel>>(ns, "findall.plants.{plantId}.recipes")
            { m -> repository.findAllRecipes(m.topic.stringParam("plantId")) }
        }

        microServiceScope.launch {
            microService<Unit, List<RecipeViewModel>>(ns, "findall.plants.{plantId}.systems.{systemId}.recipes")
            { m ->
                repository.findAllRecipesForPlantAndSystem(
                    m.topic.stringParam("plantId"),
                    m.topic.stringParam("systemId")
                )
            }
        }

        microServiceScope.launch {
            microService<Unit, List<SystemRecipesViewModel>>(ns, "findall.systems.{systemId}.recipes")
            { m ->
                repository.findAllRecipesByPlantForSystem(
                    m.topic.stringParam("systemId")
                )
            }
        }

        microServiceScope.launch {
            microService<Unit, RecipeModel>(ns, "findone.recipes.{recipeId}")
            { m -> repository.findOneRecipe(m.topic.stringParam("recipeId")) }
        }

        microServiceScope.launch {
            microService<RecipeModel, Unit>(ns, "add.recipe")
            { m -> repository.saveRecipe(m.obj!!) }
        }

        microServiceScope.launch {
            microService<Unit, Unit>(ns, "inuse.recipes.{recipeId}")
            { m -> repository.recipeInUse(m.topic.stringParam("recipeId")) }
        }

        microServiceScope.launch {
            microService<RecipeModel, Unit>(ns, "update.recipes.{recipeId}")
            { m -> repository.updateRecipe(m.topic.stringParam("recipeId"), m.obj!!) }
        }

        // ========================= Recipe - phases functions ====================================
        microServiceScope.launch {
            microService<AddPhaseModel, Unit>(ns, "add.recipes.{recipeId}.phases")
            { m -> repository.updateRecipeAddPhase(m.topic.stringParam("recipeId"), m.obj!!) }
        }

        microServiceScope.launch {
            microService<PhaseModel, Unit>(ns, "update.recipes.{recipeId}.phases.{phaseId}")
            { m -> repository.updateRecipeModifyPhase(
                m.topic.stringParam("recipeId"),
                m.topic.stringParam("phaseId"),
                m.obj!!
            )}
        }

        microServiceScope.launch {
            microService<PhaseModel, Unit>(ns, "delete.recipes.{recipeId}.phases.{phaseId}")
            { m -> repository.updateRecipeDeletePhase(
                m.topic.stringParam("recipeId"),
                m.topic.stringParam("phaseId"),
            )}
        }

        // ========================= Implementation functions ====================================
        microServiceScope.launch {
            repository.implementationFlow.asSharedFlow()
                .map { i ->
                    NatsMessageOut(
                        topic = "event.implementations.${i.implementationId}",
                        obj = i
                    )
                }
                .publishEvent(ns)
        }

        microServiceScope.launch {
            microService<Unit, List<ImplementationModel>>(ns, "findall.implementations")
            { _ -> repository.findAllImplementations() }
        }

        // ========================= Installation / Job functions ==================================

        microServiceScope.launch {
            microService<Unit, List<InstallationViewModel>>(ns, "findall.installations")
            { _ -> repository.findAllInstallationViews() }
        }
        microServiceScope.launch {
            microService<Unit, InstallationModel>(ns, "findone.installations.{installationId}")
            { m -> repository.findOneInstallation(m.topic.stringParam("installationId")) }
        }

        microServiceScope.launch {
            microService<Unit, List<PhysicalNode>>(ns, "findone.installations.{installationId}.nodes")
            { m -> repository.findOneInstallationNodes(m.topic.stringParam("installationId")) }
        }

       /* microServiceScope.launch {
            microService<Unit, MetricValue>(ns, "findone.installations.{installationId}.state")
            { m -> installations.installationState(m.topic.stringParam("installationId")) }
        }

        microServiceScope.launch {
            microService<Unit, MetricValue>(ns, "findone.installations.{installationId}.processes.{processId}.state")
            { m ->
                installations.processState(
                    instanceId = m.topic.stringParam("installationId"),
                    processId = m.topic.stringParam("processId"),
                )
            }
        }

        microServiceScope.launch {
            microService<Unit, MetricValue>(
                ns,
                "findone.installations.{installationId}.processes.{processId}.variables.{variableId}.state"
            )
            { m ->
                installations.processVariableValue(
                    instanceId = m.topic.stringParam("installationId"),
                    processId = m.topic.stringParam("processId"),
                    variableId = m.topic.stringParam("variableId"),
                )
            }
        }*/

        microServiceScope.launch {
            microService<InstallationModel, Unit>(ns, "add.installations")
            { s -> installations.addInstallation(s.obj!!) }
        }

        // ------ job services

        microServiceScope.launch {
            microService<StartJobModel, JobContextModel>(ns, "newjob.installations.{installationId}.recipes.{recipeId}")
            { m ->
                installations.newJob(
                    installationId = m.topic.stringParam("installationId"),
                    recipeId = m.topic.stringParam("recipeId"),
                )
            }
        }

        microServiceScope.launch {
            microService<Unit, JobContextModel>(ns, "startjob.installations.{installationId}.job")
            { m -> installations.startJob(installationId = m.topic.stringParam("installationId"),) }
        }

        microServiceScope.launch {
            microService<StartJobModel, JobContextModel>(ns, "nextphase.installations.{installationId}.job")
            { m -> installations.nextPhase(installationId = m.topic.stringParam("installationId"),) }
        }

        microServiceScope.launch {
            microService<Unit, JobContextModel>(ns, "findone.installations.{installationId}.job")
            { m -> repository.findOneJob(m.topic.stringParam("installationId")) }
        }

        // ---- events ---
        microServiceScope.launch {
            repository.installationFlow.asSharedFlow()
                .map { i ->
                    NatsMessageOut(
                        topic = "event.installations.${i.installationId}",
                        obj = i
                    )
                }
                .publishEvent(ns)
        }

        microServiceScope.launch {
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
