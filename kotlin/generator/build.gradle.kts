import org.jetbrains.kotlin.gradle.tasks.KotlinCompilationTask

plugins {
    alias(libs.plugins.jvm)
    alias(libs.plugins.dokka)
    `maven-publish`
}

val sourcesJar by tasks.creating(Jar::class) {
    archiveClassifier.set("sources")
    from(sourceSets.getByName("main").allSource)
}

tasks.named<KotlinCompilationTask<*>>("compileKotlin").configure {
    compilerOptions.freeCompilerArgs.add("-opt-in=kotlinx.coroutines.ExperimentalCoroutinesApi")
}

repositories {
    mavenLocal()
    mavenCentral()
    maven {
        url = uri("https://oss.sonatype.org/content/repositories/snapshots")
    }
}

publishing {
    publications {
        create<MavenPublication>("-generator") {
            from(components["java"])
            artifact(sourcesJar)
        }
    }
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
    kotlinOptions.jvmTarget = "17"
}
dependencies {

    implementation(libs.kotlin.stdlib)
    implementation(libs.kotlin.coroutines)
    implementation(libs.kotlin.logging)
    implementation(libs.logback)
    implementation(libs.kotlin.reflect)

    implementation(libs.ksp)
    implementation(libs.kotlin.poet.ksp)
    implementation(libs.kotlin.poet)

    implementation(libs.greenglass.host.application)
    implementation(libs.greenglass.host.control)
    implementation(libs.greenglass.host.sparkplug)
    implementation(libs.greenglass.host.control)
    implementation(libs.neo4j)

    testImplementation("org.jetbrains.kotlin:kotlin-test-junit5")
    testImplementation("org.junit.jupiter:junit-jupiter-engine:5.9.2")
}

