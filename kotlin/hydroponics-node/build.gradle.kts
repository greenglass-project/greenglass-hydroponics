plugins {
    alias(libs.plugins.jvm)
    alias(libs.plugins.dokka)
    alias(libs.plugins.kotlin.serialisation)
    `maven-publish`
    application
    distribution
}
kotlin {
    jvmToolchain(17)
}

repositories {
    mavenLocal()
    //maven("https://maven.pkg.jetbrains.space/public/p/compose/dev")
    mavenCentral()
}

tasks.withType<Test> {
    useJUnitPlatform()
}

group = "io.greenglass.hydroponics"
version = "0.0.2"

application {
    mainClass.set("io.greenglass.hydroponics.node.HydroponicsNodeKt")
    applicationDefaultJvmArgs = listOf(
        "--add-opens=java.base/jdk.internal.misc=ALL-UNNAMED",
        "--add-opens=java.base/java.nio=ALL-UNNAMED",
        "--add-opens=java.base/sun.nio.ch=ALL-UNNAMED",
        "-Dio.netty.tryReflectionSetAccessible=true"
    )
    //applicationDistribution.from("../configuration/nodes") {
    //    into("config")
    //}
    applicationDistribution.from("../../flutter/hydroponics_node_setup/build/web") {
        into("web")
    }
}

distributions {
    main {
        contents {
            from("../../flutter/hydroponics_node_setup/build/web") to("web")
        }
    }
}

val sourcesJar by tasks.creating(Jar::class) {
	archiveClassifier.set("sources")
	from(sourceSets.getByName("main").allSource)
}

publishing {
	publications {
		create<MavenPublication>("sparkplug") {
			from(components["java"])
			artifact(sourcesJar)
		}
	}
}

dependencies {

    implementation("io.greenglass.node:node-core:0.0.2")
    implementation("io.greenglass.node:sparkplug:0.0.2")

    implementation(libs.kotlin.stdlib)
    //implementation(libs.kotlin.reflect)
    implementation(libs.kotlin.coroutines)
    implementation(libs.kotlin.serialization.json)

    //implementation(libs.logback)
    //implementation(libs.kotlin.logging)
    implementation(libs.klogging)
    implementation(libs.slf4j)

    implementation(libs.tahu)
    implementation(libs.pi4j.core)
    implementation(libs.pi4j.pi)
    implementation(libs.pi4j.linuxfs)
    implementation(libs.pi4j.pigpio)

    implementation(libs.javalin)
    testImplementation("org.jetbrains.kotlin:kotlin-test-junit5")
    testImplementation("org.junit.jupiter:junit-jupiter-engine:5.9.2")
}
