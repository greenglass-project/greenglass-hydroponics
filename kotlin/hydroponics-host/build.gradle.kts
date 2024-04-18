plugins {
    alias(libs.plugins.jvm)
    alias(libs.plugins.ksp)
}

repositories {
    mavenLocal()
    mavenCentral()
}
allprojects {
    group = "io.greenglass.hydroponics"
    version = "0.0.2"
}
