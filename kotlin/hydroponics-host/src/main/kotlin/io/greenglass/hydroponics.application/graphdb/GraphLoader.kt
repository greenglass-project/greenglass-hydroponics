package io.greenglass.hydroponics.application.graphdb

import java.io.File
import java.nio.file.Files
import java.nio.file.Paths

import com.fasterxml.jackson.databind.MapperFeature
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.databind.module.SimpleModule
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory
import com.fasterxml.jackson.module.kotlin.KotlinFeature
import com.fasterxml.jackson.module.kotlin.KotlinModule
import com.fasterxml.jackson.module.kotlin.readValue
import io.github.oshai.kotlinlogging.KotlinLogging
import io.greenglass.host.application.microservice.StringValue
import io.greenglass.host.control.controlprocess.registry.ProcessRegistry
import io.greenglass.host.application.error.Result
import io.greenglass.host.application.error.Result.Success
import io.greenglass.host.application.error.Result.Failure
import io.greenglass.host.control.controlprocess.models.ProcessModel

import io.greenglass.hydroponics.application.models.implementation.ImplementationModel
import io.greenglass.hydroponics.application.models.recipe.PlantModel
import io.greenglass.hydroponics.application.models.system.HydroponicsSystemModel
import io.greenglass.sparkplug.models.NodeType

class GraphLoaderx(private val repository : GraphRepository,
                  private val configRoot : String,
                  private val processRegistry: ProcessRegistry
) {

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
    fun findSystemDefinitionFiles(): Result<List<StringValue>> {
        val fileList = Files.walk(Paths.get(configRoot, "systems"))
            .filter { f -> Files.isRegularFile(f) }
            .map { f -> f.toFile().name }
            .map { c -> StringValue(c) }
            .toList()
        return Success(fileList)
    }

    fun addSystemDefinition(fileName: String): Result<Unit> {
        logger.debug { "addSystemConfig() $fileName " }
        val directory = File(configRoot, "systems")

        if (directory.exists() && directory.isDirectory) {
            runCatching {
                val stream = File(directory, fileName).inputStream()
                val system: HydroponicsSystemModel = mapper.readValue(stream)
                if (!repository.systemExists(system.systemId))
                    repository.addSystem(system)
            }.onSuccess {
                return Success(Unit)
            }.onFailure { e ->
                e.printStackTrace()
            }
        } else {
            logger.error { "No such directory $directory" }
        }
        return Failure("", "")
    }

    fun findPlantDefinitionFiles(): Result<List<StringValue>> {

        val fileList = Files.walk(Paths.get(configRoot, "plants"))
            .filter { f -> Files.isRegularFile(f) }
            .map { f -> f.toFile()}
            .filter { f ->
                f.extension == "yaml" || f.extension == "YAML" ||
                        f.extension == "yml" || f.extension == "YML"
            }
            .map { c -> StringValue(c.name) }
            .toList()
        return Success(fileList)
    }

    fun addPlantDefinition(fileName: String): Result<Unit> {
        logger.debug { "addPlantDefinition() $fileName " }
        val directory = File(configRoot, "plants")

        if (directory.exists() && directory.isDirectory) {
            runCatching {
                val stream = File(directory, fileName).inputStream()
                val plantDef: PlantModel = mapper.readValue(stream)
                if(!repository.plantExists(plantDef.plantId))
                    repository.addPlant(plantDef)
            }.onSuccess {
                return Success(Unit)
            }.onFailure { e ->
                e.printStackTrace()
            }
        } else {
            logger.error { "No such directory $directory" }
        }
        return Failure("","")
    }

    fun findNodeTypeFiles(): Result<List<StringValue>> {

        val fileList = Files.walk(Paths.get(configRoot, "nodes"))
            .filter { f -> Files.isRegularFile(f) }
            .map { f -> f.toFile()}
            .filter { f ->
                f.extension == "yaml" || f.extension == "YAML" ||
                        f.extension == "yml" || f.extension == "YML"
            }
            .map { c -> StringValue(c.name) }
            .toList()
        return Success(fileList)
    }

    fun addNodeType(fileName: String): Result<Unit> {
        logger.debug { "addNodeDefinition() $fileName " }
        val directory = File(configRoot, "nodes")

        if (directory.exists() && directory.isDirectory) {
            runCatching {
                val stream = File(directory, fileName).inputStream()
                val node: NodeType = mapper.readValue(stream)
                val nodeType = NodeType(
                    type = node.type,
                    name = node.name,
                    description = node.description,
                    image = node.image,
                    metrics = node.metrics
                )

                if(!repository.nodeExists(node.type))
                    repository.addNode(nodeType)
            }.onSuccess {
                return Success(Unit)
            }.onFailure { e ->
                e.printStackTrace()
            }
        } else {
            logger.error { "No such directory $directory" }
        }
        return Failure("","")
    }

    fun findImplementationDefinitionFiles(): Result<List<StringValue>> {

        val fileList = Files.walk(Paths.get(configRoot, "implementations"))
            .filter { f -> Files.isRegularFile(f) }
            .map { f -> f.toFile()}
            .filter { f ->
                f.extension == "yaml" || f.extension == "YAML" ||
                        f.extension == "yml" || f.extension == "YML"
            }
            .map { c -> StringValue(c.name) }
            .toList()
        return Success(fileList)
    }

    fun addImplementationDefinition(fileName: String): Result<Unit> {
        logger.debug { "addImplementationDefinition() $fileName " }
        val directory = File(configRoot, "implementations")

        if (directory.exists() && directory.isDirectory) {
            runCatching {
                val stream = File(directory, fileName).inputStream()
                val implementation: ImplementationModel = mapper.readValue(stream)
                if(!repository.implementationExists((implementation.implementationId)))
                    repository.addImplementation(implementation)
            }.onSuccess {
                return Success(Unit)
            }.onFailure { e ->
                e.printStackTrace()
            }
        } else {
            logger.error { "No such directory $directory" }
        }
        return Failure("","")
    }

    private fun processModeldeserialiser() : SimpleModule {
        val module = SimpleModule()
        module.addDeserializer(ProcessModel::class.java, ProcessModelDeserializer(processRegistry))
        return module
    }
}