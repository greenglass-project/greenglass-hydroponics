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
   // maven {
   //     url = uri("https://oss.sonatype.org/content/repositories/snapshots")
   //}
}

tasks.jar {
    manifest.attributes("Main-Class" to "io.greenglass.hydroponics.application.HydroponicsKt")
}

/*oci {
    registries {
        registry("xyx")
        dockerHub {
            credentials()
        }
    }
    imageDefinitions.register("main") {
        allPlatforms {
            parentImages {
                add("library:eclipse-temurin:17.0.7_7-jre-jammy")
            }
            config {
                entryPoint.set(listOf("java", "-jar", "app.jar"))
            }
            layers {
                layer("jar") {
                    contents {
                        from(tasks.jar)
                        rename(".*", "app.jar")
                    }
                }
            }
        }
    }
    imageDependencies.forTest(tasks.test) {
        add(project)
    }
}*/


jib {
    to {
        image = "ghcr.io/greenglass-project/hydroponics:latest"

        auth {
            username = "steve.hopkins@kathris.com"
            password = "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".trim()
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
    implementation(libs.jpy)
    implementation(libs.influxdb)
    testImplementation("org.jetbrains.kotlin:kotlin-test-junit5")
    testImplementation("org.junit.jupiter:junit-jupiter-engine:5.9.2")
}

