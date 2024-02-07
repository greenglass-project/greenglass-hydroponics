package io.greenglass.hydroponics.application.models.installation

import org.neo4j.graphdb.*

import io.greenglass.host.application.neo4j.GraphNode
import io.greenglass.hydroponics.application.models.jobs.JobModel.Graph.CURRENTJOB
import io.greenglass.hydroponics.application.models.jobs.JobModel.Graph.jobLabel
import io.greenglass.hydroponics.application.models.implementation.ImplementationModel.Graph.implementationLabel
import io.greenglass.hydroponics.application.models.installation.PhysicalNodeModel.Graph.PHYSICAL_NODE
import io.greenglass.hydroponics.application.models.system.HydroponicsSystemModel


class InstallationModel(
    val installationId : String,
    val implementationId : String,
    val name : String,
    val description : String,
    val physicalNodes : List<PhysicalNodeModel>,
    val currentJobId : String?
) : GraphNode {

    constructor(node : Node) : this(
        node.getProperty("installationId") as String,
        node.getSingleRelationship(INSTALLATION, Direction.INCOMING)
            .startNode
            .getProperty("implementationId") as String,
        node.getProperty("name") as String,
        node.getProperty("description") as String,
        node.getRelationships(Direction.OUTGOING, PHYSICAL_NODE, )
            .map { r -> PhysicalNodeModel(r.endNode) },
        if(node.hasRelationship(Direction.OUTGOING, CURRENTJOB))
             node.getSingleRelationship(CURRENTJOB, Direction.OUTGOING).endNode.getProperty("jobId") as String
        else
            null
    )
    override fun toNode(tx: Transaction): Node {
        val node = tx.createNode(installationLabel)
        val implNode = checkNotNull(
            tx.findNode(
                implementationLabel, "implementationId", implementationId
            )
        )
        implNode.createRelationshipTo(node, INSTALLATION)
        node.setProperty("installationId", installationId)
        node.setProperty("name", name)
        node.setProperty("description", description)
        physicalNodes.forEach { pn -> node.createRelationshipTo(pn.toNode(tx), PHYSICAL_NODE) }
        if (currentJobId != null) {
            val jobNode = checkNotNull(tx.findNode(jobLabel, "jobId", currentJobId))
            node.createRelationshipTo(jobNode, CURRENTJOB)
        }
        return node
    }

    fun toView(tx: Transaction) : InstallationViewModel {
        val impl = tx.findNode(implementationLabel, "implementationId", implementationId)
        val sys =  impl.getSingleRelationship(HydroponicsSystemModel.SYSTEM, Direction.OUTGOING).endNode

        return InstallationViewModel(
            installationId = this.installationId,
            instanceName = this.name,
            implementationId = impl.getProperty("implementationId") as String,
            implementationName = impl.getProperty("name") as String,
            systemId = sys.getProperty("systemId") as String,
            systemName = sys.getProperty("name") as String,
        )
    }

    companion object Graph {
        val installationLabel = Label.label("Installation")
        val INSTALLATION: RelationshipType = RelationshipType.withName("INSTALLATION")
    }
}
