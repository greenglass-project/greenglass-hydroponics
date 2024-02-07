package io.greenglass.hydroponics.application.models.system

class ProcessSchedulerEvent(val installationId : String,
                            val processId : String,
                            val schedulerId : String,
                            val event : Boolean)