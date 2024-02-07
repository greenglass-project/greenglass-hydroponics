import org.jetbrains.kotlin.gradle.tasks.KotlinCompilationTask
plugins {
    alias(libs.plugins.jvm)
    alias(libs.plugins.dokka)
    alias(libs.plugins.ksp)
    alias(libs.plugins.jib)
    `maven-publish`
}

val sourcesJar by tasks.creating(Jar::class) {
    archiveClassifier.set("sources")
    from(sourceSets.getByName("main").allSource)
}

publishing {
    publications {
        create<MavenPublication>("application") {
            from(components["java"])
            artifact(sourcesJar)
        }
    }
}

repositories {
    mavenLocal()
    mavenCentral()
    maven {
        url = uri("https://oss.sonatype.org/content/repositories/snapshots")
    }
}

jib {
    to.image = "elnor.local:5005/greenglass/hydroponics:latest"
    from {
        image = "openjdk:17-jdk-slim-buster"
        platforms {
            platform {
                architecture = "arm64"
                os = "linux"
            }
        }
    }
}

tasks.named<KotlinCompilationTask<*>>("compileKotlin").configure {
    compilerOptions.freeCompilerArgs.add("-opt-in=kotlinx.coroutines.ExperimentalCoroutinesApi")
}

tasks.withType<Test> {
    useJUnitPlatform()
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
    kotlinOptions.jvmTarget = "17"
}

dependencies {
    implementation(project(":generator"))
    ksp(project(":generator"))

    implementation(project(":configuration"))

    implementation(libs.greenglass.host.application)
    implementation(libs.greenglass.host.control)
    implementation(libs.greenglass.host.sparkplug)
    implementation(libs.greenglass.sparkplug)

    implementation(libs.logback)
    implementation(libs.tahu)
    implementation(libs.kotlin.stdlib)
    implementation(libs.kotlin.reflect)
    implementation(libs.kotlin.coroutines)
    implementation(libs.kotlin.datetime)
    implementation(libs.commons.math3)
    implementation(libs.google.guava)
    implementation(libs.kotlin.logging)
    implementation(libs.jackson.core)
    implementation(libs.jackson.kotlin)
    implementation(libs.jackson.jsr310)
    implementation(libs.jackson.yaml)
    implementation(libs.neo4j)
    implementation(libs.neo4j.bolt)
    implementation(files("../libs/jFuzzyLogic.jar"))

    testImplementation("org.jetbrains.kotlin:kotlin-test-junit5")
    testImplementation("org.junit.jupiter:junit-jupiter-engine:5.9.2")
}

