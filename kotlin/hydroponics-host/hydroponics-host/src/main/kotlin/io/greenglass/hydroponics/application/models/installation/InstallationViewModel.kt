package io.greenglass.hydroponics.application.models.installation

import io.greenglass.hydroponics.application.models.implementation.ImplementationNodeModel
import io.greenglass.hydroponics.application.models.implementation.ImplementationNodeModel.Graph.implNodeLabel
import io.greenglass.hydroponics.application.models.installation.PhysicalNodeModel.Graph.PHYSICAL_NODE
import org.neo4j.graphdb.Direction
import org.neo4j.graphdb.Node

class InstallationViewModel(
    val installationId : String,
    val instanceName : String,
    val implementationId : String,
    val implementationName : String,
    val systemId : String,
    val systemName : String,
) {
    constructor(instNode: Node, implNode: Node, sysNode: Node) : this(
        instNode.getProperty("installationId") as String,
        instNode.getProperty("name") as String,
        implNode.getProperty("implementationId") as String,
        implNode.getProperty("name") as String,
        sysNode.getProperty("systemId") as String,
        sysNode.getProperty("name") as String,
    )
}
