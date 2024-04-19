rootProject.name = "hydroponics-host"
include("hydroponics-host")
include("generator")

pluginManagement {
    repositories {
        gradlePluginPortal()
        mavenCentral()
    }
}

dependencyResolutionManagement {
    repositories {
        mavenLocal()
        mavenCentral()
    }
    versionCatalogs {
        create("libs") {
            from("io.greenglass:version-catalog:0.0.2")
        }
    }
}



