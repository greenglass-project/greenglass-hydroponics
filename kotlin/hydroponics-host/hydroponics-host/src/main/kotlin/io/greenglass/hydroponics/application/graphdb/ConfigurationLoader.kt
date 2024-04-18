package io.greenglass.hydroponics.application.graphdb

import com.fasterxml.jackson.databind.MapperFeature
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.databind.module.SimpleModule
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory
import com.fasterxml.jackson.module.kotlin.KotlinFeature
import com.fasterxml.jackson.module.kotlin.KotlinModule
import com.fasterxml.jackson.module.kotlin.readValue
import io.github.oshai.kotlinlogging.KotlinLogging
import io.greenglass.host.control.controlprocess.models.ProcessModel
import io.greenglass.host.control.controlprocess.registry.ProcessRegistry
import io.greenglass.hydroponics.application.models.implementation.ImplementationModel
import io.greenglass.hydroponics.application.models.recipe.PlantModel
import io.greenglass.hydroponics.application.models.system.HydroponicsSystemModel
import io.greenglass.sparkplug.models.NodeType
import java.io.File

class ConfigurationLoader(private val repository : GraphRepository,
                          private val configRoot : String,
                          private val processRegistry: ProcessRegistry
) {

    private val classLoader = ConfigurationLoader::class.java.classLoader
    private val mapper = ObjectMapper(YAMLFactory())
    private val logger = KotlinLogging.logger {}

    init {
        mapper.registerModule(
            KotlinModule.Builder()
                .withReflectionCacheSize(512)
                .configure(KotlinFeature.NullToEmptyCollection, false)
                .configure(KotlinFeature.NullToEmptyMap, false)
                .configure(KotlinFeature.NullIsSameAsDefault, false)
                .configure(KotlinFeature.SingletonSupport, false)
                .configure(KotlinFeature.StrictNullChecks, false)
                .build()
        )
        mapper.enable(MapperFeature.ACCEPT_CASE_INSENSITIVE_ENUMS)
        mapper.registerModule(processModeldeserialiser())
    }

    fun load() {


        //var path = File(checkNotNull(classLoader.getResource("systems")?.file))
        var path = File(configRoot, "systems")

        path.walk().forEach { f ->
            if(f.isFile && f.extension == "yaml") {
                val system: HydroponicsSystemModel = mapper.readValue(f)
                logger.debug { "Found system ${system.systemId}" }
                if (!repository.systemExists(system.systemId))
                    repository.addSystem(system)
            }
        }
        path = File(configRoot, "nodes")
        path.walk().forEach { f ->
            if(f.isFile && f.extension == "yaml") {
                val node: NodeType = mapper.readValue(f)
                logger.debug { "Found node type ${node.type}" }
                if (!repository.nodeExists(node.type))
                    repository.addNode(node)
            }
        }
        path = File(configRoot, "implementations")
        path.walk().forEach { f ->
            if(f.isFile && f.extension == "yaml") {
                //logger.debug { "Found file $f"}
                val implementation: ImplementationModel = mapper.readValue(f)
                logger.debug { "Found implementation ${implementation.implementationId}" }
                if (!repository.implementationExists((implementation.implementationId)))
                    repository.addImplementation(implementation)
            }
        }

        path = File(configRoot, "plants")
        path.walk().forEach { f ->
            if(f.isFile && f.extension == "yaml") {
                val plantDef: PlantModel = mapper.readValue(f)
                logger.debug { "Found plant ${plantDef.plantId}" }
                if (!repository.plantExists(plantDef.plantId))
                    repository.addPlant(plantDef)
            }
        }
    }

    private fun processModeldeserialiser() : SimpleModule {
        val module = SimpleModule()
        module.addDeserializer(ProcessModel::class.java, ProcessModelDeserializer(processRegistry))
        return module
    }
}