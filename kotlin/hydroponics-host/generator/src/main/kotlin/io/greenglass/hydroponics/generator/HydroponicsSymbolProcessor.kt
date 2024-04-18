package io.greenglass.hydroponics.generator

import com.google.devtools.ksp.processing.*
import com.google.devtools.ksp.symbol.*
import com.squareup.kotlinpoet.*
import com.squareup.kotlinpoet.ParameterizedTypeName.Companion.parameterizedBy
import com.squareup.kotlinpoet.ksp.toClassName
import com.squareup.kotlinpoet.ksp.writeTo

import kotlinx.coroutines.CloseableCoroutineDispatcher
import org.neo4j.graphdb.Node
import org.neo4j.graphdb.Transaction
import java.io.OutputStream
import kotlin.reflect.KClass

import io.greenglass.host.application.error.NotFoundException
import io.greenglass.host.control.controlprocess.process.Process
import io.greenglass.host.control.controlprocess.models.ProcessModel
import io.greenglass.host.control.controlprocess.providers.MetricProvider
import io.greenglass.host.control.controlprocess.providers.ProcessStateProvider
import io.greenglass.host.control.controlprocess.providers.SetpointProvider
import io.greenglass.host.control.controlprocess.registry.ProcessRegistry
import io.greenglass.host.sparkplug.SparkplugService
import io.greenglass.iot.host.registry.RegisterProcess

class HydroponicsSymbolProcessor(
    private val options: Map<String, String>,
    private val logger: KSPLogger,
    private val codeGenerator: CodeGenerator,
) : SymbolProcessor {

    private var firstPass = true
    private var file: OutputStream? = null

    val nameToModelMap : HashMap<String, String> = hashMapOf()
    val nameToProcessMap : HashMap<String, String> = hashMapOf()

    private fun toClassName(fullName : String) : ClassName {
        val pkg = fullName.substring(0, fullName.indexOfLast { c -> c =='.'})
        val clazz = fullName.substring(fullName.indexOfLast { c -> c =='.'})
        return ClassName(pkg,clazz)
    }

    override fun process(resolver: Resolver): List<KSAnnotated> {
        logger.warn("IN PROCESSOR")

        if (firstPass) {
            firstPass = false


            val processes = resolver
                .getSymbolsWithAnnotation(RegisterProcess::class.java.canonicalName)
                .filterIsInstance<KSClassDeclaration>()

            for (process in processes) {
                var name: String? = null
                var model: String? = null
                val proc = process.toClassName().toString()

                val registerProc = process.annotations
                    .first {
                        it.annotationType.resolve().toClassName() == RegisterProcess::class.asClassName()
                    }
                for (arg in registerProc.arguments) {
                    when (arg.name?.asString()) {
                        "name" -> name = arg.value as? String
                        "model" -> model = arg.value
                            ?.let { it as? KSType }
                            ?.declaration
                            ?.qualifiedName
                            ?.asString()
                    }
                }
                if (name != null && model != null) {
                    nameToModelMap[name] = model
                    nameToProcessMap[name] = proc
                }
                logger.warn("name=$name proc=$proc model=$model")
            }
            generateRegistry(resolver)
        }
        return emptyList()
    }

    private fun generateRegistry(resolver: Resolver) {
        val registryClass = ClassName(
            "io.greenglass.application.hydroponics",
            "HydroponicsProcessRegistry")

        // ========================================================================================
        // modelClassForName()
        // ========================================================================================
        val modelClassForName = FunSpec.builder("modelClassForName")
            .addModifiers(KModifier.OVERRIDE)
            .addAnnotation(AnnotationSpec.builder(Throws::class).addMember("%T::class", NotFoundException::class).build())
            .returns(KClass::class.asClassName()
                .parameterizedBy(WildcardTypeName.producerOf(ProcessModel::class.asClassName())))
                .addParameter("name", String::class)
                .beginControlFlow(" return when(name)")

        nameToModelMap.entries.forEach { e ->
            modelClassForName.addStatement("\"${e.key}\" -> %T::class", toClassName(e.value))
        }
        modelClassForName
            .addStatement("else -> throw %T()", NotFoundException::class)
            .endControlFlow().build()

        /*
           open fun processForName(name : String,
                       systemInstance : SystemInstance,
                       processModel : ProcessModel,
                       metricProvider : MetricProvider,
                       setpointProvider : SetpointProvider,
                       processStateProvider : ProcessStateProvider,
                       sparkplugService: SparkplugService,) : Process {
        throw NotImplementedError()
         */

        // ========================================================================================
        // processForName()
        // ========================================================================================
        val processForName = FunSpec.builder("processForName")
            .addModifiers(KModifier.OVERRIDE)
            .addAnnotation(AnnotationSpec.builder(Throws::class).addMember("%T::class", NotFoundException::class).build())

        .returns(Process::class)
            .addParameter("name", String::class)
            .addParameter("instanceId", String::class)
            .addParameter("processModel", ProcessModel::class)
            .addParameter("metricProvider", MetricProvider::class)
            .addParameter("setpointProvider", SetpointProvider::class)
            .addParameter("processStateProvider", ProcessStateProvider::class)
            .addParameter("sparkplugService", SparkplugService::class)
            .addParameter("dispatcher",  CloseableCoroutineDispatcher::class)
            .beginControlFlow(" return when(name)")
        nameToProcessMap.entries.forEach { e ->
            processForName
                .addStatement("\"${e.key}\" -> %T(instanceId, processModel as %T, metricProvider, setpointProvider, processStateProvider, sparkplugService, dispatcher)",
                    toClassName(e.value), toClassName(nameToModelMap[e.key]!!))
        }
        processForName
            .addStatement("else -> throw %T()", NotFoundException::class)
            .endControlFlow().build()


        /*fun ProcessModel.toNode(tx: Transaction, processRegistry : ProcessRegistry): Node {


            val modelClass = processRegistry.modelClassForName(process)
            val functions = modelClass.functions
            for(function in functions) {
                if(function.name == "toNode") {
                    function.call(tx)
                }
            }
            //modelClass.cast(this).toNode(tx)
            throw IllegalStateException()
        }*/

        // ========================================================================================
        // ProcessModel.toNode()
        // ========================================================================================
        val toNode = FunSpec.builder("toNode")
            .receiver(ProcessModel::class)
            .returns(Node::class)
            .addParameter("tx", Transaction::class)
            .beginControlFlow("return when(process)")
        nameToModelMap.entries.forEach { e ->
            toNode.addStatement("\"${e.key}\" -> (this as %T).toNode(tx)", toClassName(e.value))
        }
        toNode
            .addStatement("else -> throw %T()", NotFoundException::class)
            .endControlFlow().build()


        FileSpec.builder(registryClass)
            .addType(TypeSpec.classBuilder(registryClass).superclass(ProcessRegistry::class)
                .addFunction(modelClassForName.build())
                .addFunction(processForName.build())
                .build())
            //.build()
            .addFunction(toNode.build())
            .build()
            .writeTo(codeGenerator,
                dependencies = Dependencies(false, *resolver.getAllFiles().toList().toTypedArray())
            )
    }
}

class HydroponicsSymbolProcessorProvider  : SymbolProcessorProvider {
    override fun create(environment: SymbolProcessorEnvironment) =
        HydroponicsSymbolProcessor(environment.options, environment.logger, environment.codeGenerator)
}