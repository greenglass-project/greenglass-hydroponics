rootProject.name = "hydroponics"
include("hydroponics-host")
include("hydroponics-node")
include("generator")
include("configuration")



pluginManagement {
    repositories {
        gradlePluginPortal()
        mavenCentral()
    }
}


