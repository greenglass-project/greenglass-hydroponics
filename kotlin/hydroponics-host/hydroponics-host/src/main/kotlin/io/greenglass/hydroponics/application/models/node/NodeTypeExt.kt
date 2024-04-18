/******************************************************************************
 *  Copyright 2023 Steve Hopkins
 *
 *  Use of this source code is governed by an MIT-style
 *  license that can be found in the LICENSE file or at
 *  https://opensource.org/licenses/MIT.
 *
 *****************************************************************************/
package io.greenglass.hydroponics.application.models.node

import org.neo4j.graphdb.Direction.*
import org.neo4j.graphdb.Label
import org.neo4j.graphdb.Node
import org.neo4j.graphdb.Transaction
import org.neo4j.graphdb.RelationshipType
import io.greenglass.sparkplug.models.Metric
import io.greenglass.sparkplug.models.NodeType

operator fun NodeType.Companion.invoke(node : Node) : NodeType {
    return NodeType(
        node.getProperty("type") as String,
        node.getProperty("name") as String,
        node.getProperty("description") as String,
        node.getProperty("image") as String,
        node.getRelationships(OUTGOING, Metric.METRIC).map { r -> Metric(r.endNode) }
    )
}

fun NodeType.toNode(tx: Transaction): Node {
        val node = tx.createNode(NodeType.nodeTypeLabel)
        node.setProperty("type", type)
        node.setProperty("name", name)
        node.setProperty("description", description)
        node.setProperty("image", image)
        metrics.forEach { f -> node.createRelationshipTo(f.toNode(tx), Metric.METRIC) }
        return node
}

val NodeType.Companion.nodeTypeLabel : Label
    get() = Label.label("NodeTypeLabel")
val NodeType.Companion.NODE_TYPE : RelationshipType
    get() = RelationshipType.withName("EON_NODE")
