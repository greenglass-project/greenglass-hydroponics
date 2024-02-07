package io.greenglass.hydroponics.application.models.recipe

import io.greenglass.host.application.components.scheduling.periodic.duration.DailyDurationEvent
import kotlinx.datetime.LocalTime
import org.neo4j.graphdb.*

import io.greenglass.hydroponics.application.models.recipe.phase.PhaseModel
import io.greenglass.hydroponics.application.models.system.ProcessSchedulerModel

class ProcessScheduleModel(
    val phaseId : String,
    val schedulerId : String,
    val start : Int?,
    val end : Int?,
    val frequency : Int?,
    val duration : Int? ) {

    constructor(node: Node) : this(
        node.getSingleRelationship(PROCESS_SCHEDULE, Direction.INCOMING).startNode.getProperty("phaseId") as String,
        node.getSingleRelationship(ProcessSchedulerModel.PROCESS_SCHEDULER, Direction.OUTGOING).endNode.getProperty("schedulerId") as String,
        node.getProperty("start", null) as? Int,
        node.getProperty("end", null) as? Int,
        node.getProperty("frequency", null) as? Int,
        node.getProperty("duration", null) as? Int,
        )

    fun toNode(tx : Transaction) : Node {
        val phaseNode = checkNotNull(tx.findNode(PhaseModel.phaseLabel, "phaseId", this.phaseId))
        val scheduleNode = checkNotNull(tx.findNode(ProcessSchedulerModel.schedulerLabel, "schedulerId", this.schedulerId))
        val node = tx.createNode(scheduleLabel)

        phaseNode.createRelationshipTo(node, PROCESS_SCHEDULE)
        node.createRelationshipTo(scheduleNode, ProcessSchedulerModel.PROCESS_SCHEDULER)

        this.start?.let { s -> node.setProperty("start", s) }
        this.end?.let { e -> node.setProperty("end", e) }
        this.frequency?.let { f -> node.setProperty("frequency", f) }
        this.duration?.let { d -> node.setProperty("duration", d) }
        return node
    }

    fun toDailyDurationEventList() : List<DailyDurationEvent> {
        val events : ArrayList<DailyDurationEvent> = arrayListOf()
        if (start != null && end != null) {
            events.add(DailyDurationEvent(LocalTime(start, 0), LocalTime(end, 0)))
        } else {
            checkNotNull(frequency)
            checkNotNull(duration)
            var hour = 0;
            while (hour < 24 - duration) {
                val start = LocalTime(hour, 0).toSecondOfDay()
                val end = start + duration*60*60
                events.add(DailyDurationEvent(LocalTime.fromSecondOfDay(start), LocalTime.fromMillisecondOfDay(end)))
                hour += frequency
            }
        }
        return events
    }

    companion object Graph {
        val PROCESS_SCHEDULE : RelationshipType = RelationshipType.withName("PROCESS_SCHEDULE")
        val scheduleLabel : Label = Label.label("ProcessSchedule")
    }
}