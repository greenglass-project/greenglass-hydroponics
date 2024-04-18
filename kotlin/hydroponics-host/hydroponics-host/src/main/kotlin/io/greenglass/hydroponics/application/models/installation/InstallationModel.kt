package io.greenglass.hydroponics.application.models.installation

import org.neo4j.graphdb.*

import io.greenglass.host.application.neo4j.GraphNode
import io.greenglass.hydroponics.application.models.jobs.JobModel.Graph.CURRENTJOB
import io.greenglass.hydroponics.application.models.jobs.JobModel.Graph.jobLabel
import io.greenglass.hydroponics.application.models.implementation.ImplementationModel.Graph.implementationLabel
import io.greenglass.hydroponics.application.models.implementation.ImplementationNodeModel.Graph.IMPLEMENTATION_NODE
import io.greenglass.hydroponics.application.models.installation.PhysicalNodeModel.Graph.PHYSICAL_NODE
import io.greenglass.hydroponics.application.models.node.METRIC
import io.greenglass.hydroponics.application.models.node.NODE_TYPE
import io.greenglass.hydroponics.application.models.node.invoke
import io.greenglass.hydroponics.application.models.system.HydroponicsSystemModel
import io.greenglass.sparkplug.models.Metric
import io.greenglass.sparkplug.models.NodeType


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
        val instNode = tx.findNode(installationLabel, "installationId", this.installationId)
        val implNode = tx.findNode(implementationLabel, "implementationId", implementationId)
        val sysNode =  implNode.getSingleRelationship(HydroponicsSystemModel.SYSTEM, Direction.OUTGOING).endNode
        return InstallationViewModel(instNode, implNode, sysNode)
    }

    fun getNodes(tx: Transaction) : List<InstallationNodeModel> =
        tx.findNode(installationLabel, "installationId", this.installationId)
            .getRelationships(Direction.OUTGOING, PHYSICAL_NODE)
            .map { pnr -> nodeModel(pnr.endNode) }

    private fun nodeModel(physicalNode : Node) : InstallationNodeModel{
        val nodeId = physicalNode.getProperty("nodeId") as String
        val implNode = physicalNode.getSingleRelationship(IMPLEMENTATION_NODE, Direction.OUTGOING).endNode
        val implName = implNode.getProperty("description") as String
        val nodeTypeNode = implNode.getSingleRelationship(NodeType.NODE_TYPE, Direction.OUTGOING).endNode
        val nodeType = nodeTypeNode.getProperty("type") as String
        val nodeName = nodeTypeNode.getProperty("name") as String
        val nodeDescription = nodeTypeNode.getProperty("description") as String
        val nodeImage = nodeTypeNode.getProperty("image") as String
        val metrics = nodeTypeNode.getRelationships(Direction.OUTGOING, Metric.METRIC).map { n -> Metric.Companion.invoke(n.endNode)}

        return InstallationNodeModel(
            nodeId = nodeId,
            implName = implName,
            nodeType = nodeType,
            nodeName = nodeName,
            nodeDescription = nodeDescription,
            nodeImage = nodeImage,
            metrics = metrics
        )
    }

    companion object Graph {
        val installationLabel = Label.label("Installation")
        val INSTALLATION: RelationshipType = RelationshipType.withName("INSTALLATION")
    }
}
