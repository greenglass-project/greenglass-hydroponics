package io.greenglass.hydroponics.application.graphdb

import checkAvailable
import checkExists
import checkNotExists
import org.neo4j.graphdb.Direction.*
import org.neo4j.graphdb.Node
import org.neo4j.graphdb.Transaction
import kotlinx.coroutines.flow.MutableSharedFlow
import io.github.oshai.kotlinlogging.KotlinLogging

import java.io.File
import java.time.ZonedDateTime
import java.util.*

import io.greenglass.host.application.error.AlreadyExistsException
import io.greenglass.host.application.error.ErrorCodes.Companion.ILLEGAL_STATE_CHANGE
import io.greenglass.host.application.error.ErrorCodes.Companion.INTERNAL_ERROR
import io.greenglass.host.application.error.ErrorCodes.Companion.OBJECT_ALREADY_EXISTS
import io.greenglass.host.application.error.ErrorCodes.Companion.OBJECT_IN_USE
import io.greenglass.host.application.error.ErrorCodes.Companion.OBJECT_NOT_AVAILABLE
import io.greenglass.host.application.error.ErrorCodes.Companion.OBJECT_NOT_FOUND
import io.greenglass.host.application.error.NotAvailableException
import io.greenglass.host.application.error.NotFoundException
import io.greenglass.host.application.error.Result
import io.greenglass.host.application.neo4j.*
import io.greenglass.host.control.controlprocess.models.ProcessModel
import io.greenglass.host.control.controlprocess.models.ProcessVariableModel
import io.greenglass.host.control.controlprocess.registry.ProcessRegistry
import io.greenglass.hydroponics.application.models.config.MasterConfig
import io.greenglass.hydroponics.application.models.config.MasterConfig.Graph.masterConfigLabel

import io.greenglass.hydroponics.application.models.jobs.JobModel
import io.greenglass.hydroponics.application.models.jobs.JobModel.Graph.CURRENTJOB
import io.greenglass.hydroponics.application.models.jobs.JobState

import io.greenglass.hydroponics.application.models.implementation.ImplementationModel
import io.greenglass.hydroponics.application.models.recipe.phase.ControlledPhaseModel.Graph.PHASE
import io.greenglass.hydroponics.application.models.recipe.PlantModel.Graph.plantLabel
import io.greenglass.hydroponics.application.models.recipe.RecipeModel.Graph.RECIPE
import io.greenglass.hydroponics.application.models.recipe.RecipeModel.Graph.recipeLabel
import io.greenglass.hydroponics.application.models.recipe.SetpointModel.Graph.SET_POINT
import io.greenglass.hydroponics.application.models.implementation.ImplementationModel.Graph.implementationLabel
import io.greenglass.hydroponics.application.models.implementation.ImplementationNodeModel
import io.greenglass.hydroponics.application.models.implementation.ImplementationNodeModel.Graph.IMPLEMENTATION_NODE
import io.greenglass.hydroponics.application.models.installation.InstallationModel
import io.greenglass.hydroponics.application.models.installation.InstallationModel.Graph.INSTALLATION
import io.greenglass.hydroponics.application.models.installation.InstallationModel.Graph.installationLabel
import io.greenglass.hydroponics.application.models.installation.InstallationNodeModel
import io.greenglass.hydroponics.application.models.installation.InstallationViewModel
import io.greenglass.hydroponics.application.models.installation.PhysicalNodeModel.Graph.physicalNodeLabel
import io.greenglass.hydroponics.application.models.recipe.ProcessScheduleModel.Graph.PROCESS_SCHEDULE
import io.greenglass.hydroponics.application.models.recipe.SetpointModel.Graph.PROCESS_VARIABLE
import io.greenglass.hydroponics.application.models.recipe.phase.AddPhaseModel
import io.greenglass.hydroponics.application.models.recipe.phase.PhaseModel
import io.greenglass.hydroponics.application.models.recipe.phase.PhaseModel.Graph.CURRENT_PHASE
import io.greenglass.hydroponics.application.models.jobs.JobContextModel
import io.greenglass.hydroponics.application.models.jobs.JobModel.Graph.JOB
import io.greenglass.hydroponics.application.models.node.*
import io.greenglass.hydroponics.application.models.recipe.*
import io.greenglass.hydroponics.application.models.recipe.PlantModel.Graph.PLANT
import io.greenglass.hydroponics.application.models.system.*
import io.greenglass.sparkplug.models.NodeType

class GraphRepository(
    private val neo4jService: Neo4jService,
    private val configRoot: String,
    private val processRegistry : ProcessRegistry,
    private val masterConfigFlow : MutableSharedFlow<MasterConfig>
) {
    //private val mapper = ObjectMapper(YAMLFactory())
    private val logger = KotlinLogging.logger {}

    val systemFlow: MutableSharedFlow<HydroponicsSystemModel> = MutableSharedFlow(1)
    val implementationFlow: MutableSharedFlow<ImplementationModel> = MutableSharedFlow(1)
    val plantFlow: MutableSharedFlow<PlantModel> = MutableSharedFlow(1)
    val recipeFlow: MutableSharedFlow<RecipeViewModel> = MutableSharedFlow(1)
    val recipeUpdateFlow: MutableSharedFlow<RecipeModel> = MutableSharedFlow(1)
    val installationFlow: MutableSharedFlow<InstallationViewModel> = MutableSharedFlow(1)

    val nodeFlow: MutableSharedFlow<NodeType> = MutableSharedFlow(1)

    // ===================================================================================
    //  SystemModelExt
    // ===================================================================================
    fun systemExists(systemId: String): Boolean {
        neo4jService.db.beginTx().use { tx ->
            val model = tx.findNode(HydroponicsSystemModel.systemLabel, "systemId", systemId)
            return model != null
        }
    }

    fun findAllSystems(): Result<List<HydroponicsSystemModel>> {
        neo4jService.db.beginTx().use { tx ->
            logger.debug { "findAllSystems" }
            val list =
                tx.findNodes(HydroponicsSystemModel.systemLabel).map { n -> HydroponicsSystemModel(n, processRegistry) }.asSequence().toList()
            return Result.Success(list)
        }
    }

    fun findOneSystem(systemId: String): Result<HydroponicsSystemModel> {
        try {
            neo4jService.db.beginTx().use { tx ->
                val model = checkExists(
                    tx.findNode(HydroponicsSystemModel.systemLabel, "systemId", systemId)
                        ?.let { sn -> HydroponicsSystemModel(sn, processRegistry) })
                return Result.Success(model)
            }
        } catch (ex: NotFoundException) {
            return Result.Failure(OBJECT_NOT_FOUND, systemId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun findAllControlProcesses(systemId: String): Result<List<ProcessModel>> {
        try {
            neo4jService.db.beginTx().use { tx ->
                val list = tx.findNode(HydroponicsSystemModel.systemLabel, "systemId", systemId)?.let { s ->
                    s.getRelationships(ProcessModel.PROCESS).map { r -> ProcessModel(r.endNode) }
                }
                if (list != null)
                    return Result.Success(list)
                else
                    return Result.Success(listOf())
            }
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun addSystem(system: HydroponicsSystemModel): Result<Unit> {
        logger.debug { "addSystem() - ${system.systemId}" }
        try {
            neo4jService.db.beginTx().use { tx ->
                checkNotExists(tx.findNode(HydroponicsSystemModel.systemLabel, "systemId", system.systemId))
                system.toNode(tx, processRegistry)
                tx.commit()
                logger.debug { "SystemModelExt added " }
                systemFlow.tryEmit(system)
                return Result.Success(Unit)
            }
        } catch (ex: AlreadyExistsException) {
            return Result.Failure(OBJECT_ALREADY_EXISTS, system.systemId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun findSchedulerForProcess(processId: String): Result<ProcessSchedulerModel> {
        logger.debug { "findSchedulerForProcess() - $processId}" }
        try {
            neo4jService.db.beginTx().use { tx ->
                val processNode = tx.findNode(ProcessModel.processLabel, "processId", processId)
                if (processNode != null) {
                    val scheduleNode = checkExists(
                        processNode.getSingleRelationshipToNodeType(
                            INCOMING, ProcessModel.PROCESS, ProcessSchedulerModel.schedulerLabel
                        )?.startNode
                    )
                    return Result.Success(ProcessSchedulerModel(scheduleNode, processRegistry))
                } else
                    return Result.Failure(OBJECT_NOT_FOUND, processId)
            }
        } catch (ex: NotFoundException) {
            return Result.Failure(OBJECT_NOT_FOUND, processId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun findOneScheduler(schedulerId: String): Result<ProcessSchedulerModel> {
        logger.debug { "findOneScheduler() - $schedulerId}" }
        try {
            neo4jService.db.beginTx().use { tx ->
                val node = tx.findNode(ProcessSchedulerModel.schedulerLabel, "schedulerId", schedulerId)
                if (node != null)
                    return Result.Success(ProcessSchedulerModel(node, processRegistry))
                else
                    return Result.Failure(OBJECT_NOT_FOUND, schedulerId)
            }
        } catch (ex: NotFoundException) {
            return Result.Failure(OBJECT_NOT_FOUND, schedulerId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    // ===================================================================================
    //  Implementation
    // ===================================================================================
    fun implementationExists(implementationId: String): Boolean {
        neo4jService.db.beginTx().use { tx ->
            val model = tx.findNode(implementationLabel, "implementationId", implementationId)
            return model != null
        }
    }

    fun addImplementation(implementation: ImplementationModel): Result<Unit> {
        logger.debug { "addImplementation() - ${implementation.name}" }
        try {
            neo4jService.db.beginTx().use { tx ->
                checkNotExists(tx.findNode(implementationLabel, "implementationId", implementation.implementationId))
                implementation.toNode(tx)
                tx.commit()
                implementationFlow.tryEmit(implementation)
                return Result.Success(Unit)
            }
        } catch (ex: AlreadyExistsException) {
            return Result.Failure(OBJECT_ALREADY_EXISTS, implementation.implementationId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun findAllImplementations(): Result<List<ImplementationModel>> {
        try {
            neo4jService.db.beginTx().use { tx ->
                return Result.Success(tx.findNodes(implementationLabel)
                    .map { i -> ImplementationModel(i) }
                    .asSequence().toList())
            }
        } catch (ex: Exception) {
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }
    fun findImplementationNodes(implementationId : String): Result<List<ImplementationNodeModel>> {
        try {
            neo4jService.db.beginTx().use { tx ->
                val impl = checkExists(tx.findNode(implementationLabel, "implementationId",implementationId))
                return Result.Success(impl.getRelationships(OUTGOING, IMPLEMENTATION_NODE).map { r -> ImplementationNodeModel(r.endNode) })
            }
        } catch (ex: NotFoundException) {
            return Result.Failure(OBJECT_NOT_FOUND, implementationId)
        } catch (ex: Exception) {
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }


    // ===================================================================================
    //  Recipe
    // ===================================================================================
    fun plantExists(plantId: String): Boolean {
        neo4jService.db.beginTx().use { tx ->
            val model = tx.findNode(plantLabel, "plantId", plantId)
            return model != null
        }
    }

    fun findAllPlants(): Result<List<PlantModel>> {
        logger.debug { "findAllPlants()" }
        try {
            neo4jService.db.beginTx().use { tx ->
                return Result.Success(tx.findNodes(plantLabel)
                    .map { n -> PlantModel(n) }
                    .asSequence().toList())
            }
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun findOnePlant(plantId: String): Result<PlantModel> {
        logger.debug { "findOnePlant() - $plantId" }
        try {
            neo4jService.db.beginTx().use { tx ->
                val model = checkExists(tx.findNode(plantLabel, "plantId", plantId)?.let { p -> PlantModel(p) })
                return Result.Success(model)
            }
        } catch (ex: NotFoundException) {
            return Result.Failure(OBJECT_NOT_FOUND, plantId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun findOnePlantImage(plantId: String): Result<ByteArray> {
        logger.debug { "findOnePlantImage() - $plantId" }
        try {
            neo4jService.db.beginTx().use { tx ->
                val model = checkExists(tx.findNode(plantLabel, "plantId", plantId)?.let { p -> PlantModel(p) })
                val plantsDir = File(configRoot, "plants")
                val imagesDir = File(plantsDir, "images")
                val image = File(imagesDir, model.image).readBytes()
                return Result.Success(image)
            }
        } catch (ex: NotFoundException) {
            return Result.Failure(OBJECT_NOT_FOUND, plantId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun addPlant(plant: PlantModel): Result<Unit> {
        logger.debug { "addPlant() - ${plant.name}" }
        try {
            neo4jService.db.beginTx().use { tx ->
                checkNotExists(tx.findNode(plantLabel, "plantId", plant.plantId))
                plant.toNode(tx)
                tx.commit()
                plantFlow.tryEmit(plant)
                return Result.Success(Unit)
            }
        } catch (ex: AlreadyExistsException) {
            return Result.Failure(OBJECT_ALREADY_EXISTS, plant.plantId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun recipeExists(recipeId: String): Boolean {
        logger.debug { "recipeExists()" }
        neo4jService.db.beginTx().use { tx ->
            val model = tx.findNode(recipeLabel, "recipeId", recipeId)
            return model != null
        }
    }

    fun findAllRecipes(plantId: String): Result<List<RecipeViewModel>> {
        logger.debug { "findAllRecipeViews() - plant $plantId" }
        try {
            neo4jService.db.beginTx().use { tx ->
                val plantNode = checkExists(tx.findNode(plantLabel, "plantId", plantId))
                return Result.Success(plantNode.getRelationships(OUTGOING, RECIPE)
                    .map { r -> r.endNode }
                    .map { n ->
                        RecipeViewModel(
                            n, plantNode,
                            n.getSingleRelationship(HydroponicsSystemModel.SYSTEM, OUTGOING).endNode,
                        )
                    }.toList()
                )
            }
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun findAllRecipesForPlantAndSystem(plantId: String, systemId: String): Result<List<RecipeViewModel>> {
        logger.debug { "findAllRecipesForPlantAndSystem() - systemId $systemId" }
        try {
            neo4jService.db.beginTx().use { tx ->
                val systemNode = checkExists(tx.findNode(HydroponicsSystemModel.systemLabel, "systemId", systemId))
                val plantNode = checkExists(tx.findNode(plantLabel, "plantId", plantId))

                return Result.Success(getNodesWithRelationships(
                    node1 = systemNode,
                    rel1 = HydroponicsSystemModel.SYSTEM,
                    dir1 = INCOMING,
                    node2 = plantNode,
                    rel2 = PlantModel.PLANT,
                    dir2 = INCOMING
                    //).map { n -> RecipeModel(tx,n) }) //, plantNode, systemNode) })
                ).map { n -> RecipeViewModel(n, plantNode, systemNode) })

            }
        } catch (ex: NotFoundException) {
            return Result.Failure(OBJECT_NOT_FOUND, plantId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun findAllRecipesByPlantForSystem(systemId: String): Result<List<SystemRecipesViewModel>> {
        logger.debug { "findAllRecipesByPlantForSystem() - systemId $systemId" }
        try {
            neo4jService.db.beginTx().use { tx ->
                val systemNode = checkExists(tx.findNode(HydroponicsSystemModel.systemLabel, "systemId", systemId))
                val recipes = systemNode.getRelationshipsToNodeType(INCOMING, HydroponicsSystemModel.SYSTEM, recipeLabel)
                    .map { r -> RecipeModel(tx, r.startNode) }.groupBy { rm -> rm.plantId }
                return Result.Success(recipes.entries.map { e ->
                    SystemRecipesViewModel(
                        plant = PlantModel(checkExists(tx.findNode(plantLabel, "plantId", e.key))),
                        recipes = e.value
                    )
                })
            }
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun findOneRecipe(recipeId: String): Result<RecipeModel> {
        logger.debug { "findOneRecipe() - recipe $recipeId" }
        try {

            neo4jService.db.beginTx().use { tx ->
                val node = tx.findNode(recipeLabel, "recipeId", recipeId)
                if (node != null) {
                    val model = RecipeModel(tx, node);
                    return Result.Success(model)
                } else {
                    return Result.Failure(OBJECT_NOT_FOUND, recipeId)
                }
            }
        } catch (ex: NotFoundException) {
            return Result.Failure(OBJECT_NOT_FOUND, recipeId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun saveRecipe(recipe: RecipeModel): Result<Unit> {
        neo4jService.db.beginTx().use { tx ->
            val model = tx.findNode(recipeLabel, "recipeId", recipe.recipeId)
            if (model == null) {
                recipe.toNode(tx)
                val viewModel = RecipeViewModel(tx, recipe)
                tx.commit()
                recipeFlow.tryEmit(viewModel)
                return Result.Success(Unit)
            } else {
                return Result.Failure(OBJECT_ALREADY_EXISTS, recipe.recipeId)
            }
        }
    }

    fun recipeInUse(recipeId: String): Result<Unit> {
        try {
            neo4jService.db.beginTx().use { tx ->
                val node = checkExists(tx.findNode(recipeLabel, "recipeId", recipeId))
                if (node.hasRelationship(INCOMING, RECIPE))
                    return Result.Failure(OBJECT_IN_USE, recipeId)
                else
                    return Result.Success(Unit)
            }
        } catch (ex: NotFoundException) {
            return Result.Failure(OBJECT_NOT_FOUND, recipeId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun removeRecipe(tx: Transaction, recipeNode: Node) {
        if (recipeNode.hasRelationship(OUTGOING, PHASE)) {
            var currentNode = recipeNode.getSingleRelationship(
                PHASE,
                OUTGOING
            ).endNode //.getSingleRelationship(PHASE, Direction.OUTGOING)
            while (currentNode != null) {
                currentNode.getRelationships(OUTGOING, PROCESS_SCHEDULE).forEach { r ->
                    r.endNode.getRelationships(OUTGOING).forEach { s -> s.delete() }
                    r.endNode.getRelationships(INCOMING).forEach { s -> s.delete() }
                    r.endNode.delete()
                }
                currentNode.getRelationships(OUTGOING, SET_POINT).forEach { r ->
                    r.endNode.getRelationships(OUTGOING).forEach { s -> s.delete() }
                    r.endNode.getRelationships(INCOMING).forEach { s -> s.delete() }
                    r.endNode.delete()
                }
                var nextNode: Node? = null;
                if (currentNode.hasRelationship(OUTGOING, PHASE)) {
                    nextNode = currentNode.getSingleRelationship(PHASE, OUTGOING).endNode
                }
                currentNode.getSingleRelationship(PHASE, INCOMING).delete()
                currentNode.delete()
                currentNode = nextNode
            }
        }
        recipeNode.getSingleRelationship(RECIPE, INCOMING)?.delete()

        recipeNode.getSingleRelationship(HydroponicsSystemModel.SYSTEM, OUTGOING).delete()
        recipeNode.getSingleRelationship(PLANT, OUTGOING).delete()
        recipeNode.delete()
    }

    fun updateRecipe(recipeId: String, recipe: RecipeModel): Result<Unit> {
        try {
            neo4jService.db.beginTx().use { tx ->
                val existing = checkExists(tx.findNode(recipeLabel, "recipeId", recipe.recipeId));
                removeRecipe(tx, existing)
                recipe.toNode(tx)
                tx.commit()
                recipeUpdateFlow.tryEmit(recipe)
                return Result.Success(Unit)
            }
        } catch (ex: NotFoundException) {
            return Result.Failure(OBJECT_NOT_FOUND, recipeId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun updateRecipeAddPhase(recipeId: String, newPhase: AddPhaseModel): Result<Unit> {
        try {
            neo4jService.db.beginTx().use { tx ->
                var previousPhaseNode: Node? = null
                var nextPhaseNode: Node? = null

                val recipeNode = checkExists(tx.findNode(recipeLabel, "recipeId", recipeId))

                // Get the previous and next phase nodes in the chain (if any)
                // If there is node previous node the starting point is the recipe
                if (newPhase.previousPhaseId != null) {
                    previousPhaseNode =
                        checkExists(tx.findNode(PhaseModel.phaseLabel, "phaseId", newPhase.previousPhaseId));
                    if (previousPhaseNode.hasRelationship(OUTGOING, PHASE))
                        nextPhaseNode = previousPhaseNode.getSingleRelationship(PHASE, OUTGOING).endNode
                } else if (recipeNode.hasRelationship(OUTGOING, PHASE)) {
                    // If the recipe has a phase node this becomes the next phase node
                    nextPhaseNode = recipeNode.getSingleRelationship(PHASE, OUTGOING).endNode
                }

                // Add the new phase node to the graph
                val phase = newPhase.phase
                phase.phaseId = UUID.randomUUID().toString()
                val newPhaseNode = newPhase.phase.toNode(tx)

                // Reconstruct the chain
                if (previousPhaseNode == null)
                    recipeNode.createRelationshipTo(newPhaseNode, PHASE)
                else
                    previousPhaseNode.createRelationshipTo(newPhaseNode, PHASE)

                if (nextPhaseNode != null)
                    newPhaseNode.createRelationshipTo(nextPhaseNode, PHASE)

                tx.commit()
                return Result.Success(Unit)
            }

        } catch (ex: NotFoundException) {
            return Result.Failure(OBJECT_NOT_FOUND, recipeId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun updateRecipeModifyPhase(recipeId: String, phaseId: String, phaseModel: PhaseModel): Result<Unit> {
        try {
            neo4jService.db.beginTx().use { tx ->
                check(phaseModel.phaseId == phaseId)
                var nextPhaseNode: Node? = null
                val recipeNode = checkExists(tx.findNode(recipeLabel, "recipeId", recipeId))
                val currentNode = checkExists(tx.findNode(PhaseModel.phaseLabel, "phaseId", phaseId))

                // If the phase is currently inuse abort the operation
                if (currentNode.hasRelationship(CURRENT_PHASE))
                    return Result.Failure(OBJECT_IN_USE, phaseModel.phaseId)

                // Find the current PHASE relationships and delete them
                val previousPhaseRelationship = currentNode.getSingleRelationship(PHASE, INCOMING)
                val previousPhaseNode = previousPhaseRelationship.startNode
                previousPhaseRelationship.delete()

                if (currentNode.hasRelationship(OUTGOING, PHASE)) {
                    val nextPhaseRelationship = currentNode.getSingleRelationship(PHASE, OUTGOING)
                    nextPhaseNode = nextPhaseRelationship.endNode
                    nextPhaseRelationship.delete()
                }

                // Delete the current node and create a new one with the same id
                currentNode.delete()
                val newNode = phaseModel.toNode(tx)

                // Recreate the PHASE relationships
                previousPhaseNode.createRelationshipTo(newNode, PHASE)
                if (nextPhaseNode != null)
                    newNode.createRelationshipTo(nextPhaseNode, PHASE)

                tx.commit()
                return Result.Success(Unit)
            }
        } catch (ex: NotFoundException) {
            return Result.Failure(OBJECT_NOT_FOUND, recipeId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun updateRecipeDeletePhase(recipeId: String, phaseId: String): Result<Unit> {
        try {
            neo4jService.db.beginTx().use { tx ->
                var nextPhaseNode: Node? = null

                checkExists(tx.findNode(recipeLabel, "recipeId", recipeId))
                val currentNode = checkExists(tx.findNode(PhaseModel.phaseLabel, "phaseId", phaseId))

                // If the phase is currently inuse abort the operation
                if (currentNode.hasRelationship(CURRENT_PHASE))
                    return Result.Failure(OBJECT_IN_USE, phaseId)

                // Find the current PHASE relationships and delete them
                val previousPhaseRelationship = currentNode.getSingleRelationship(PHASE, INCOMING)
                val previousPhaseNode = previousPhaseRelationship.startNode

                if (currentNode.hasRelationship(OUTGOING, PHASE)) {
                    val nextPhaseRelationship = currentNode.getSingleRelationship(PHASE, OUTGOING)
                    nextPhaseNode = nextPhaseRelationship.endNode
                    nextPhaseRelationship.delete()
                } else {
                    if (previousPhaseNode.hasLabel(recipeLabel)) {
                        return Result.Failure(OBJECT_IN_USE, phaseId)
                    }
                }
                // delete the incoming relationship
                previousPhaseRelationship.delete()

                // delete the phase
                currentNode.delete()

                // Recreate the PHASE chain if necessary
                if (nextPhaseNode != null) {
                    previousPhaseNode.createRelationshipTo(nextPhaseNode, PHASE)
                }
                tx.commit()
                return Result.Success(Unit)
            }
        } catch (ex: NotFoundException) {
            return Result.Failure(OBJECT_NOT_FOUND, recipeId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun deleteRecipe(recipeId: String): Result<Unit> {
        try {
            neo4jService.db.beginTx().use { tx ->
                val existing = tx.findNode(recipeLabel, "recipeId", recipeId);
                if (existing != null) {
                    removeRecipe(tx, existing)
                    tx.commit()
                    return Result.Success(Unit)
                } else
                    return Result.Failure(OBJECT_NOT_FOUND, recipeId)
            }
        } catch (ex: NotFoundException) {
            return Result.Failure(OBJECT_NOT_FOUND, recipeId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    // ===================================================================================
    //  Node
    // ===================================================================================
    fun nodeExists(nodeType: String): Boolean {
        neo4jService.db.beginTx().use { tx ->
            val model = tx.findNode(NodeType.nodeTypeLabel, "type", nodeType)
            return model != null
        }
    }

    fun addNode(nodeDef: NodeType): Result<Unit> {
        logger.debug { "addNode() - ${nodeDef.type}" }
        try {
            neo4jService.db.beginTx().use { tx ->
                checkNotExists(tx.findNode(NodeType.nodeTypeLabel, "type", nodeDef.type))
                nodeDef.toNode(tx)
                tx.commit()
                nodeFlow.tryEmit(nodeDef)
                return Result.Success(Unit)
            }
        } catch (ex: AlreadyExistsException) {
            return Result.Failure(OBJECT_ALREADY_EXISTS, nodeDef.type)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun findAllNodeTypes(): Result<List<NodeType>> {
        logger.debug { "findAllNodeTypes" }
        try {
            neo4jService.db.beginTx().use { tx ->
                val list = tx.findNodes(NodeType.nodeTypeLabel)
                    .map { n -> NodeType.Companion.invoke(n) }.asSequence().toList()
                return Result.Success(list)
            }
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun findOneNodeImage(type: String): Result<ByteArray> {
        logger.debug { "findOneNodeImage() - $type" }
        try {
            neo4jService.db.beginTx().use { tx ->
                val model = checkExists(tx.findNode(NodeType.nodeTypeLabel, "type", type)?.let { p -> NodeType(p) })
                val plantsDir = File(configRoot, "nodes")
                val imagesDir = File(plantsDir, "images")
                val image = File(imagesDir, model.image).readBytes()
                return Result.Success(image)
            }
        } catch (ex: NotFoundException) {
            return Result.Failure(OBJECT_NOT_FOUND, type)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    // ===================================================================================
    //  Installations
    // ===================================================================================
    fun addInstallation(installation: InstallationModel): Result<Unit> {
        logger.debug { "addInstallation() ${installation.installationId} ${installation.name}" }

        try {
            neo4jService.db.beginTx().use { tx ->
                val x = tx.findNode(installationLabel, "name", installation.name)
                checkNotExists(x)
                installation.physicalNodes.forEach { pn ->
                    if (tx.findNode(physicalNodeLabel, "nodeId", pn.nodeId) != null)
                        return Result.Failure("", "")
                }
                installation.toNode(tx)
                installationFlow.tryEmit(installation.toView(tx))
                tx.commit()
                return Result.Success(Unit)
            }
        } catch (ex: AlreadyExistsException) {
            logger.info { "$OBJECT_ALREADY_EXISTS  ${installation.name} " }
            return Result.Failure(OBJECT_ALREADY_EXISTS, installation.name)
        } catch (ex: Exception) {
            logger.error { ex.message }
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun findAllInstallationViews(): Result<List<InstallationViewModel>> {
        logger.debug { "findAllInstallationViews()" }
        try {
            neo4jService.db.beginTx().use { tx ->
                return Result.Success(
                    tx.findNodes(installationLabel).map { i ->
                        val implNode = i.getSingleRelationship(INSTALLATION, INCOMING).startNode
                        val sysNode = implNode.getSingleRelationship(HydroponicsSystemModel.SYSTEM, OUTGOING).endNode
                        InstallationViewModel(i, implNode, sysNode)
                    }.asSequence().toList()
                )
            }
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun findAllInstallations(): Result<List<InstallationModel>> {
        logger.debug { "findAllInstallations()" }
        try {
            neo4jService.db.beginTx().use { tx ->
                return Result.Success(
                    tx.findNodes(installationLabel).map { i ->
                        InstallationModel(i)
                    }.asSequence().toList()
                )
            }
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun findOneInstallation(installationId: String): Result<InstallationModel> {
        logger.debug { "findOneInstallation() $installationId" }
        try {
            neo4jService.db.beginTx().use { tx ->
                val instNode = tx.findNode(installationLabel, "installationId", installationId)
                if (instNode != null)
                    return Result.Success(InstallationModel(instNode))
                else
                    return Result.Failure(OBJECT_NOT_FOUND, installationId)
            }
        } catch (ex: NotFoundException) {
            return Result.Failure(OBJECT_NOT_FOUND, installationId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun findOneInstallationNodes(installationId:  String) :  Result<List<InstallationNodeModel>> {
        logger.debug { "findOneInstallationNodes() $installationId" }
        try {
            neo4jService.db.beginTx().use { tx ->
                val installation = InstallationModel(
                    checkExists(tx.findNode(installationLabel, "installationId", installationId))
                )
                return Result.Success(installation.getNodes(tx))
            }
        } catch (ex: NotFoundException) {
            return Result.Failure(OBJECT_NOT_FOUND, installationId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun findOneSetpoint(installationId: String, variableId: String): Result<Double> {
        logger.debug { "findOneSetpoint() $installationId $variableId" }
        try {
            neo4jService.db.beginTx().use { tx ->
                val instNode = checkExists(tx.findNode(installationLabel, "installationId", installationId))
                val jobNode = checkExists(instNode.getSingleRelationship(JobModel.JOB, OUTGOING)).endNode
                val phaseNode = checkExists(jobNode.getSingleRelationship(PHASE, OUTGOING)).endNode
                val pvNode =
                    checkExists(tx.findNode(ProcessVariableModel.processVariableLabel, "variableId", variableId))
                val setPointNode = checkExists(
                    getOneNodeWithRelationships(
                        phaseNode, SET_POINT, OUTGOING,
                        pvNode, PROCESS_VARIABLE, INCOMING
                    )
                )
                return Result.Success(setPointNode.getProperty("setPoint") as Double)
            }
        } catch (ex: NotFoundException) {
            return Result.Failure(OBJECT_NOT_FOUND, variableId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun findOneSchedule(installationId: String, schedulerId: String): Result<ProcessScheduleModel> {
        logger.debug { "findOneSchedule() $installationId $schedulerId" }
        neo4jService.db.beginTx().use { tx ->
            try {
                val instNode = checkExists(tx.findNode(installationLabel, "installationId", installationId))
                val jobNode = checkExists(instNode.getSingleRelationship(JobModel.JOB, OUTGOING)).endNode
                val phaseNode = checkExists(jobNode.getSingleRelationship(PHASE, OUTGOING)).endNode
                val schedulerMode =
                    checkExists(tx.findNode(ProcessSchedulerModel.schedulerLabel, "schedulerId", schedulerId))
                val scheduleNode = checkExists(
                    getOneNodeWithRelationships(
                        phaseNode, PROCESS_SCHEDULE, OUTGOING,
                        schedulerMode, ProcessSchedulerModel.PROCESS_SCHEDULER, INCOMING
                    )
                )
                return Result.Success(ProcessScheduleModel(scheduleNode))
            } catch (ex: NotFoundException) {
                return Result.Failure(OBJECT_NOT_FOUND, schedulerId)
            } catch (ex: Exception) {
                logger.error { ex.stackTraceToString() }
                return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
            }
        }
    }

    fun findOneInstallationSystem(installationId: String): Result<HydroponicsSystemModel> {
        logger.debug { "findOneInstallationSystem() $installationId" }
        try {
            neo4jService.db.beginTx().use { tx ->
                val instNode = checkExists(tx.findNode(installationLabel, "installationId", installationId))
                val implNode = checkExists(instNode.getSingleRelationship(INSTALLATION, INCOMING)).startNode
                val systemNode = checkExists(implNode.getSingleRelationship(HydroponicsSystemModel.SYSTEM, OUTGOING)).endNode
                return Result.Success(HydroponicsSystemModel(systemNode, processRegistry))
            }
        } catch (ex: NotFoundException) {
            return Result.Failure(OBJECT_NOT_FOUND, installationId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    // ===================================================================================
    //  Jobs
    // ===================================================================================
    fun findOneJob(installationId: String): Result<JobContextModel> {
        logger.debug { "findOneJob() $installationId" }
        try {
            neo4jService.db.beginTx().use { tx ->
                val instNode = checkExists(tx.findNode(installationLabel, "installationId", installationId))
                val jobNode = checkAvailable(instNode.getSingleRelationship(CURRENTJOB, OUTGOING)?.endNode)
                val recipeNode = jobNode.getSingleRelationship(RECIPE, OUTGOING).endNode
                val plantNode = recipeNode.getSingleRelationship(PLANT, OUTGOING).endNode
                return Result.Success(JobContextModel(JobModel(jobNode), RecipeModel(tx, recipeNode), PlantModel(plantNode)))
            }
        } catch (ex: NotAvailableException) {
            logger.debug { "No job for installation $installationId" }
            return Result.Failure(OBJECT_NOT_AVAILABLE, installationId)
        } catch (ex: NotFoundException) {
            logger.warn { "Installation $installationId not found" }
            return Result.Failure(OBJECT_NOT_FOUND, installationId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            logger.error { "Installation $installationId error ${ex.message}" }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun newJobForInstallation(installationId: String, recipeId: String): Result<JobContextModel> {
        try {
            neo4jService.db.beginTx().use { tx ->
                val instNode = checkExists(tx.findNode(installationLabel, "installationId", installationId))
                val recipeNode = checkExists(tx.findNode(recipeLabel, "recipeId", recipeId))
                val plantNode = recipeNode.getSingleRelationship(PLANT, OUTGOING).endNode
                //val phaseId = recipeNode.getSingleRelationship(PHASE, OUTGOING).endNode.getProperty("phaseId") as String

                if (instNode.hasRelationship(CURRENTJOB))
                    return Result.Failure(OBJECT_ALREADY_EXISTS, installationId)

                val jobId = UUID.randomUUID().toString()
                val job = JobModel(
                    jobId = jobId,
                    state = JobState.Inactive,
                    startTime = ZonedDateTime.now(),
                    endTime = null,
                    installationId = installationId,
                    recipeId = recipeId,
                    phaseId = null,
                    phaseEnd = null
                )

                val jobNode = job.toNode(tx)
                instNode.createRelationshipTo(jobNode, CURRENTJOB)
                //val result = jobFlow.tryEmit(
                val ctx = JobContextModel(
                        job = JobModel(jobNode),
                        recipe = RecipeModel(tx, recipeNode),
                        plant = PlantModel(plantNode)
                    )
                //)
                tx.commit()
                return Result.Success(ctx)
            }
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }


    fun startJob(jobId: String, phaseId: String, end : ZonedDateTime?) : Result<JobModel> {
        try {
            neo4jService.db.beginTx().use { tx ->
                val jobNode = checkNotNull(tx.findNode(JobModel.jobLabel, "jobId", jobId))
                val phaseNode = checkNotNull(tx.findNode(PhaseModel.phaseLabel, "phaseId", phaseId))

                jobNode.createRelationshipTo(phaseNode, CURRENT_PHASE)
                jobNode.setProperty("state", JobState.Active.name)
                jobNode.setProperty("startTime", ZonedDateTime.now().toString())
                jobNode.setProperty("phaseEnd", end.toString())
                val job = JobModel(jobNode)
                tx.commit()
                return Result.Success(job)
            }
        } catch (ex: NotFoundException) {
            logger.warn { "Job $jobId not found" }
            return Result.Failure(OBJECT_NOT_FOUND, jobId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            logger.error { "Job $jobId error ${ex.message}" }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun setJobPhase(jobId: String, phaseId: String, end : ZonedDateTime?): Result<JobModel> {
        try {
            neo4jService.db.beginTx().use { tx ->
                val jobNode = checkNotNull(tx.findNode(JobModel.jobLabel, "jobId", jobId))
                val phaseNode =  checkNotNull(tx.findNode(PhaseModel.phaseLabel, "phaseId", phaseId))
                jobNode.setProperty("phaseEnd", end.toString())

                if(jobNode.hasRelationship(OUTGOING, CURRENT_PHASE)) {
                    jobNode.getSingleRelationship(CURRENT_PHASE, OUTGOING).delete()
                }
                jobNode.createRelationshipTo(phaseNode, CURRENT_PHASE)
                val job = JobModel(jobNode)
                tx.commit()
                return Result.Success(job)
            }
        } catch (ex: NotFoundException) {
            logger.warn { "Job $jobId not found" }
            return Result.Failure(OBJECT_NOT_FOUND, jobId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            logger.error { "Job $jobId error ${ex.message}" }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun completeJob(jobId: String) : Result<JobModel> {
        try {
            neo4jService.db.beginTx().use { tx ->
                val jobNode = checkNotNull(tx.findNode(JobModel.jobLabel, "jobId", jobId))
                jobNode.setProperty("phaseEnd", null)
                jobNode.setProperty("state", JobState.Complete)
                if(jobNode.hasRelationship(OUTGOING, CURRENT_PHASE)) {
                    jobNode.getSingleRelationship(CURRENT_PHASE, OUTGOING).delete()
                }
                val job = JobModel(jobNode)
                tx.commit()
                return Result.Success(job)
            }
        } catch (ex: NotFoundException) {
            logger.warn { "Job $jobId not found" }
            return Result.Failure(OBJECT_NOT_FOUND, jobId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            logger.error { "Job $jobId error ${ex.message}" }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun deleteJob(jobId: String) : Result<Unit> {
        try {
            neo4jService.db.beginTx().use { tx ->
                val jobNode = checkNotNull(tx.findNode(JobModel.jobLabel, "jobId", jobId))
                jobNode.getSingleRelationship(CURRENT_PHASE, OUTGOING)?.delete()
                jobNode.getSingleRelationship(RECIPE, OUTGOING).delete()
                jobNode.getSingleRelationship(JOB, INCOMING).delete() // from installation
                tx.commit()
                return Result.Success(Unit);
            }
        } catch (ex: NotFoundException) {
            logger.warn { "Job $jobId not found" }
            return Result.Failure(OBJECT_NOT_FOUND, jobId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            logger.error { "Job $jobId error ${ex.message}" }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun cancelJobForInstallation(installationId: String): Result<Unit> {
        try {
            neo4jService.db.beginTx().use { tx ->
                val instNode = checkExists(tx.findNode(installationLabel, "installationId", installationId))
                val jobNode = checkAvailable(instNode.getSingleRelationship(CURRENTJOB, OUTGOING)?.endNode)
                val job = JobModel(jobNode)
                if(job.state == JobState.Inactive) {
                    instNode.getSingleRelationship(CURRENTJOB, OUTGOING).delete()
                    jobNode.setProperty("endTime", ZonedDateTime.now().toString())
                    jobNode.setProperty("state", JobState.Aborted.name)
                    tx.commit()
                    //jobStateFlow.tryEmit(JobStateModel(job.jobId, JobState.Aborted))
                    return Result.Success(Unit)
                } else
                    return Result.Failure(ILLEGAL_STATE_CHANGE, installationId)
            }
        } catch (ex: NotAvailableException) {
            logger.debug { "No job for installation $installationId" }
            return Result.Failure(OBJECT_NOT_AVAILABLE, installationId)
        } catch (ex: NotFoundException) {
            logger.warn { "Installation $installationId not found" }
            return Result.Failure(OBJECT_NOT_FOUND, installationId)
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            logger.error { "Installation $installationId error ${ex.message}" }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    // ===================================================================================
    //  Master Config
    // ===================================================================================
    fun findOneMasterConfig() : Result<MasterConfig> {
        try {
            neo4jService.db.beginTx().use { tx ->
                val model = checkExists(tx.findNodes(masterConfigLabel).asSequence().firstOrNull())
                return Result.Success(MasterConfig(model))
            }
        } catch (ex: NotFoundException) {
            return Result.Failure(OBJECT_NOT_FOUND, "")
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun addMasterConfig(mc : MasterConfig) : Result<Unit> {
        logger.debug { "addMasterConfig() " }
        try {
            neo4jService.db.beginTx().use { tx ->

                checkNotExists(tx.findNodes(masterConfigLabel).asSequence().firstOrNull())
                mc.toNode(tx)
                tx.commit()
                logger.debug { "MasterConfig added " }
                masterConfigFlow.tryEmit(mc)
                return Result.Success(Unit)
            }
        } catch (ex: AlreadyExistsException) {
            return Result.Failure(OBJECT_ALREADY_EXISTS, "")
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }

    fun updateMasterConfig(mc : MasterConfig) : Result<Unit> {
        try {
            neo4jService.db.beginTx().use { tx ->
                val model = checkExists(tx.findNodes(masterConfigLabel).asSequence().firstOrNull())
                model.setProperty("hostId", mc.hostId)
                model.setProperty("groupId", mc.groupId)
                model.setProperty("timeZone", mc.timeZone)
                tx.commit()
                return Result.Success(Unit)
            }
        } catch (ex: NotFoundException) {
            return Result.Failure(OBJECT_NOT_FOUND, "")
        } catch (ex: Exception) {
            logger.error { ex.stackTraceToString() }
            return Result.Failure(INTERNAL_ERROR, ex.message ?: "Internal error")
        }
    }
}


