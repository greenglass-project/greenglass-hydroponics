import org.jetbrains.kotlin.gradle.tasks.KotlinCompilationTask
plugins {
    alias(libs.plugins.jvm)
    alias(libs.plugins.dokka)
    alias(libs.plugins.ksp)
    alias(libs.plugins.jib)
    //alias(libs.plugins.oci)
    `maven-publish`
}

val sourcesJar by tasks.creating(Jar::class) {
    archiveClassifier.set("sources")
    from(sourceSets.getByName("main").allSource)
}

/*sourceSets {
    main {
        resources {
            srcDir("../configuration")
        }
    }
}*/

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
}

tasks.jar {
    manifest.attributes("Main-Class" to "io.greenglass.hydroponics.application.HydroponicsKt")
}

jib {
    to {
        image = "ghcr.io/greenglass-project/hydroponics:latest"

        auth {
            username = System.getenv("GREENGLASS_GITHUB_USERNAME") ?: error("Github username not found")
            password = System.getenv("GREENGLASS_GITHUB_TOKEN") ?: error("Github token not found")
        }
    }
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

kotlin {
    jvmToolchain(17)
}

tasks.named<KotlinCompilationTask<*>>("compileKotlin").configure {
    compilerOptions.freeCompilerArgs.add("-opt-in=kotlinx.coroutines.ExperimentalCoroutinesApi")
}

tasks.withType<Test> {
    useJUnitPlatform()
}

dependencies {
    implementation(project(":generator"))
    ksp(project(":generator"))

    implementation("io.greenglass.host:host-application:0.0.2")
    implementation("io.greenglass.host:host-control:0.0.2")
    implementation("io.greenglass.host:host-sparkplug:0.0.2")
    implementation("io.greenglass.host:sparkplug:0.0.2")

    //implementation(libs.logback)
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
    implementation(libs.jpy)
    implementation(libs.influxdb)
    testImplementation("org.jetbrains.kotlin:kotlin-test-junit5")
    testImplementation("org.junit.jupiter:junit-jupiter-engine:5.9.2")
}

