plugins {
    alias(libs.plugins.jvm)
    alias(libs.plugins.dokka)
    `maven-publish`
    application
}

repositories {
    mavenLocal()
    //maven("https://maven.pkg.jetbrains.space/public/p/compose/dev")
    mavenCentral()
}

tasks.withType<Test> {
    useJUnitPlatform()
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
    kotlinOptions.jvmTarget = "17"
}

application {
    mainClass.set("io.greenglass.hydroponics.node.HydroponicsNodeKt")
    applicationDefaultJvmArgs = listOf(
        "--add-opens=java.base/jdk.internal.misc=ALL-UNNAMED",
        "--add-opens=java.base/java.nio=ALL-UNNAMED",
        "--add-opens=java.base/sun.nio.ch=ALL-UNNAMED",
        "-Dio.netty.tryReflectionSetAccessible=true"
    )
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



tasks {
    val fatJar = register<Jar>("fatJar") {
        dependsOn.addAll(listOf("compileJava", "compileKotlin", "processResources"))
        archiveClassifier.set("runtime")
        duplicatesStrategy = DuplicatesStrategy.EXCLUDE
        manifest { attributes(mapOf("Main-Class" to application.mainClass)) }
        val sourcesMain = sourceSets.main.get()
        val contents = configurations.runtimeClasspath.get()
            .map { if (it.isDirectory) it else zipTree(it) } +
                sourcesMain.output
        from(contents)
    }
    build {
        dependsOn(fatJar)
    }
}

dependencies {

    implementation(project(":configuration"))
    implementation(libs.greenglass.node.core)
    implementation(libs.greenglass.sparkplug)

    implementation(libs.kotlin.stdlib)
    implementation(libs.kotlin.reflect)
    implementation(libs.kotlin.coroutines)
    implementation(libs.logback)
    implementation(libs.kotlin.logging)
    implementation(libs.tahu)

    implementation(libs.pi4j.core)
    implementation(libs.pi4j.pi)
    implementation(libs.pi4j.linuxfs)
    implementation(libs.pi4j.pigpio)

    testImplementation("org.jetbrains.kotlin:kotlin-test-junit5")
    testImplementation("org.junit.jupiter:junit-jupiter-engine:5.9.2")
}

