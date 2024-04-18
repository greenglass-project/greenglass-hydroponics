# Building Greenglass Hydroponics



## Greenglass Frameworks

```
cd greenglass-frameworks
./gradlew clean
./gradlew assemble
./gradlew publishToMavenlocal
```



## Greenglass Hydroponics

### Build the node-setup web app

This is automatically copied into the node distribution file

```
cd flutter/hydroponics_node_setup
flutter clean
flutter build web --web-renderer html
```



### Build the mac app

```
cd flutter/hydroponics_panel
flutter build macos
```

The app is in :

```
greenglass-hydroponics/flutter/hydroponics_panel/build/macos/Build/Products/Release
```



### Build the host Docker image and the Node distribution file

```
cd kotlin
./gradlew clean
./gradlew assemble
./gradlew jibDockerBuild
docker push ghcr.io/greenglass-project/hydroponics:latest
```

