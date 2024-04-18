
# build the node setup web app
cd flutter/hydroponics_node_setup
flutter clean
flutter build web --web-renderer html
cd ../..
pwd

# build node apps
cd kotlin/hydroponics-node
./gradlew clean
./gradlew assemble
./gradlew build
cd ../..

