rootProject.name = "hydroponics"
include("hydroponics-host")
include("hydroponics-test")
include("hydroponics-node")
include("generator")



pluginManagement {
    repositories {
        gradlePluginPortal()
        mavenCentral()
    }
}


