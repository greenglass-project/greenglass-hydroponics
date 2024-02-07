plugins {
    alias(libs.plugins.jvm)
    `maven-publish`
}


repositories {
	mavenLocal()
	mavenCentral()
}

publishing {
	publications {
		create<MavenPublication>("sparkplug") {
			from(components["java"])
		}
	}
}

