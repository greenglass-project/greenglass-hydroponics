package io.greenglass.hydroponics.application.graphdb

import com.fasterxml.jackson.core.JsonParser
import com.fasterxml.jackson.core.TreeNode
import com.fasterxml.jackson.databind.DeserializationContext
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.databind.deser.std.StdDeserializer
import com.fasterxml.jackson.databind.node.TextNode
import io.greenglass.host.control.controlprocess.models.ProcessModel
import io.greenglass.host.control.controlprocess.registry.ProcessRegistry

class ProcessModelDeserializer : StdDeserializer<ProcessModel> {
    constructor() : this(null)
    constructor(vc: Class<*>?) : super(vc)
    constructor(registry : ProcessRegistry) : this() {
        this.registry = registry
    }

    private lateinit var registry : ProcessRegistry

    override fun deserialize(p: JsonParser, ctxt: DeserializationContext?): ProcessModel {
        val mapper = p.codec as ObjectMapper
        val modelNode : TreeNode = mapper.readTree(p)

        check(modelNode["process"] is TextNode)
        val name = (modelNode["process"] as TextNode).textValue()
        val modelClass = registry.modelClassForName(name)
        return  mapper.treeToValue(modelNode, modelClass.java)
    }
}