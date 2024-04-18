package io.greenglass.hydroponics.application.control.processes.fuzzylogic

import io.github.oshai.kotlinlogging.KotlinLogging
import io.greenglass.sparkplug.datatypes.MetricValue
import kotlinx.coroutines.CloseableCoroutineDispatcher
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

suspend fun StateFlow<MetricValue>.publishToFLCVariable(flc : FuzzyLogicController, name : String) : Nothing =
    collect { m -> if(m.isDouble) flc.setVariable(name, m.double) }

fun subscribeToFLCVariable(flc : FuzzyLogicController, variableName : String) = flc.subscribeToVariable(variableName)

class FuzzyLogicController(processModel : FuzzyLogicProcessModel,
                           private val calculateTrigger : SharedFlow<Boolean>,
                           private val processScope : CoroutineScope,
                           private val dispatcher : CloseableCoroutineDispatcher,

                           ) {
    private val logger = KotlinLogging.logger {}


    init {
        //val python = processModel.python

        //val value =  checkNotNull(polyglotService.context).eval("python", python);
    }
    private val processVariables = processModel.processVariables?.associate {
        pv -> Pair(pv.name, pv)
    } ?: mapOf()
    private val manipulatedValiables = processModel.manipulatedVariables?.associate {
        mv -> Pair(mv.name, MutableSharedFlow<MetricValue>(1))
    } ?: mapOf()

    init {
        logger.debug { "FuzzyLogicController() : python = \n${processModel.script}"}
    }

    suspend fun run() {
        logger.debug { "FuzzyLogicController run()"}

        processScope.launch(dispatcher) {
            calculateTrigger.collect { calculate() }
        }
    }

    fun subscribeToVariable(name : String) = checkNotNull(manipulatedValiables[name]).asSharedFlow()
    fun setVariable(name : String, value : Double) {} // fb.setVariable(name, value)

    private suspend fun calculate() {
        //fis.evaluate()
       /* manipulatedValiables
            .entries
            .asFlow()
            .map { e -> Pair(fb.getVariable(e.key).value, e.value) }
            .filter { p -> p.first == 0.0 }
            .collect { v -> v.second.emit(MetricValue(v.first))
        }*/
    }
}