package io.greenglass.hydroponics.application.models.recipe.phase

import com.fasterxml.jackson.core.JsonParser
import com.fasterxml.jackson.core.TreeNode
import com.fasterxml.jackson.databind.DeserializationContext
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.databind.deser.std.StdDeserializer
import com.fasterxml.jackson.databind.module.SimpleModule
import com.fasterxml.jackson.databind.node.TextNode
import io.greenglass.host.application.microservice.logger
import io.greenglass.host.application.neo4j.GraphNode
import io.greenglass.hydroponics.application.models.recipe.phase.ControlledPhaseModel.Graph.controlPhaseLabel
import io.greenglass.hydroponics.application.models.recipe.phase.ManualPhaseModel.Graph.manualPhaseLabel
import io.greenglass.hydroponics.application.models.recipe.phase.SequencePhaseModel.Graph.sequencePhaseLabel
import org.neo4j.graphdb.Label
import org.neo4j.graphdb.Node
import org.neo4j.graphdb.RelationshipType
import org.neo4j.graphdb.Transaction


enum class PhaseType {
    Phase,
    ControlPhase,
    ManualPhase,
    SequencePhasse
}

class PhaseModelDeserialiser : StdDeserializer<PhaseModel> {
    constructor() : this(null)
    constructor(vc: Class<*>?) : super(vc)

    init {
        logger.debug { "PhaseModelDeserialiser() "}
    }

    override fun deserialize(p: JsonParser, ctxt: DeserializationContext?): PhaseModel {
        val mapper = p.codec as ObjectMapper
        val phaseNode : TreeNode = mapper.readTree(p)

        check(phaseNode["type"] is TextNode)
        val type = PhaseType.valueOf((phaseNode["type"] as TextNode).textValue())

        logger.debug { "PhaseModel type ${phaseNode["type"]} $type "}

        return when(type) {
            PhaseType.ControlPhase -> mapper.treeToValue(phaseNode, ControlledPhaseModel::class.java)
            PhaseType.ManualPhase -> mapper.treeToValue(phaseNode, ManualPhaseModel::class.java)
            PhaseType.SequencePhasse -> mapper.treeToValue(phaseNode, SequencePhaseModel::class.java)
            else ->  mapper.treeToValue(phaseNode, PhaseModel::class.java)
        }
    }
}

open class PhaseModel(
    val type : PhaseType,
    var phaseId : String,
    val name : String,
    val description : String,
    val duration : Int
) : GraphNode {
    constructor(node : Node) : this(
        PhaseType.Phase,
        node.getProperty("phaseId") as String,
        node.getProperty("name") as String,
        node.getProperty("description") as String,
        node.getProperty("duration") as Int,
        )
    override fun toNode(tx : Transaction) : Node {
        val node = tx.createNode(phaseLabel)
        node.setProperty("phaseId", this.phaseId)
        node.setProperty("name", this.name)
        node.setProperty("description", this.description)
        node.setProperty("duration", this.duration)
        return node
    }

    companion object Graph {
        val phaseLabel = Label.label("Phase")
        val PHASE : RelationshipType = RelationshipType.withName("PHASE")
        val CURRENT_PHASE : RelationshipType = RelationshipType.withName("CURRENT_PHASE")

        fun factory(node : Node) : PhaseModel {
            return when {
                node.hasLabel(controlPhaseLabel) -> ControlledPhaseModel(node)
                node.hasLabel(manualPhaseLabel) -> ManualPhaseModel(node)
                node.hasLabel(sequencePhaseLabel) -> SequencePhaseModel(node)
                else -> PhaseModel(node)
            }
        }

        fun deserialiser() : SimpleModule {
            val module = SimpleModule()
            module.addDeserializer(PhaseModel::class.java, PhaseModelDeserialiser())
            return module
        }
    }
}
