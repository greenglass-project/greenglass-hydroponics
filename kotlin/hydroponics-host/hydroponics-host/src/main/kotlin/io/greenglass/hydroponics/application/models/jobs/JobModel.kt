package io.greenglass.hydroponics.application.models.jobs

import io.greenglass.host.application.neo4j.GraphNode
import org.neo4j.graphdb.*
import java.time.ZonedDateTime

import io.greenglass.hydroponics.application.models.installation.InstallationModel
import io.greenglass.hydroponics.application.models.recipe.phase.ControlledPhaseModel.Graph.PHASE
import io.greenglass.hydroponics.application.models.recipe.RecipeModel
import io.greenglass.hydroponics.application.models.recipe.RecipeModel.Graph.RECIPE
import io.greenglass.hydroponics.application.models.recipe.phase.PhaseModel
import io.greenglass.hydroponics.application.models.recipe.phase.PhaseModel.Graph.CURRENT_PHASE

enum class JobState {
    Inactive,
    Active,
    Paused,
    Error,
    Aborted,
    Complete
}

class JobModel(
    val jobId : String,
    val state : JobState,
    val startTime : ZonedDateTime,
    val endTime : ZonedDateTime?,
    val installationId : String,
    val recipeId : String,

    val phaseId : String?,
    val phaseEnd : ZonedDateTime?
) : GraphNode {

    constructor(node : Node) : this(
        node.getProperty("jobId") as String,
        JobState.valueOf(node.getProperty("state") as String),
        ZonedDateTime.parse(node.getProperty("startTime") as String),
        if(node.getProperty("startTime") as? String != null)
            ZonedDateTime.parse(node.getProperty("startTime") as String)
        else
            null,
        node.getSingleRelationship(JOB, Direction.INCOMING).startNode.getProperty("installationId") as String,
        node.getSingleRelationship(RECIPE, Direction.OUTGOING).endNode.getProperty("recipeId") as String,
        node.getSingleRelationship(CURRENT_PHASE, Direction.OUTGOING)?.endNode?.getProperty("phaseId") as? String,
        if(node.getProperty("phaseEnd", null) as? String != null)
            ZonedDateTime.parse(node.getProperty("phaseEnd") as String)
        else
            null
    )

    override fun toNode(tx: Transaction): Node {
        val node = tx.createNode(jobLabel)
        node.setProperty("jobId", jobId)
        node.setProperty("state", state.name)
        node.setProperty("startTime", startTime.toString())
        if(endTime != null)
            node.setProperty("endTime", endTime.toString())
        val installationNode = tx.findNode(InstallationModel.installationLabel, "installationId", installationId)
        installationNode.createRelationshipTo(node, JOB)

        val recipeNode = tx.findNode(RecipeModel.recipeLabel, "recipeId", recipeId)
        node.createRelationshipTo(recipeNode, RECIPE)

        if(phaseId != null) {
            val phaseNode = tx.findNode(PhaseModel.phaseLabel, "phaseId", phaseId)
            node.createRelationshipTo(phaseNode, PHASE)

        }
        if(endTime != null)
            node.setProperty("phaseEnd", endTime.toString())
        return node
    }

    /*
    Point.measurement("input")
                    .addTag("processId", processId)
                    .addTag("pv", pv)
                    .addField(value.type.name, value.value as Boolean)
                    .time(value.timestamp, WritePrecision.MS)
     */
    companion object Graph {
        val jobLabel = Label.label("Job")
        val JOB: RelationshipType = RelationshipType.withName("JOB")
        val CURRENTJOB: RelationshipType = RelationshipType.withName("CURRENTJOB")
    }
}