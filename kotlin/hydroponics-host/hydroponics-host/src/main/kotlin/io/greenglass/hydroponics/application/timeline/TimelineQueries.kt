package io.greenglass.hydroponics.application.timeline

import io.greenglass.host.application.influxdb.InfluxDbService

class TimelineQueries(private val influxDbService: InfluxDbService) {

    fun queryNodeMetricNameValue(nodeId : String, metricName : String ) {

        val fluxQuery = ("from(bucket: \"${influxDbService.bucket}\")\n"
                + " |> range(start: -1d)"
                + " |> filter(fn: (r) => (r[\"_measurement\"] == \"cpu\" and r[\"_field\"] == \"usage_system\"))")

        val results = influxDbService.client.getQueryKotlinApi().query(fluxQuery)

    }
}