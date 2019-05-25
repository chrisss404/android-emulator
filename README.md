
CI images of the Android emulator ready for instrumentation tests.

| Tag              | Device        | Size    | Resolution | Density |
| ---------------- | ------------- | -------:| ----------:| -------:|
| latest-nexus-one | Nexus One     | 3.4''   | 480x800    | hdpi    |
| latest-nexus-5x  | Nexus 5x      | 5.2''   | 1080x1920  | 420dpi  |
| latest-nexus-7   | Nexus 7       | 7.02''  | 1200x1920  | xhdpi   |
| latest-nexus-10  | Nexus 10      | 10.05'' | 2560x1600  | xhdpi   |


## Start Android Emulator

    # hardware accelerated
    docker run --name nexus-one -d -p 5555:5555 --privileged chrisss404/android-emulator:latest-nexus-one
    docker run --name nexus-one -d -p 5555:5555 --device /dev/kvm chrisss404/android-emulator:latest-nexus-one

    # software rendered
    docker run --name nexus-one -d -p 5555:5555 chrisss404/android-emulator:latest-nexus-one


## List Connected Devices

    $ adb devices -l
    List of devices attached
    emulator-5554          device product:sdk_gphone_x86 model:Android_SDK_built_for_x86 device:generic_x86 transport_id:1


## Run Instrumentation Tests

    ./gradlew connectedAndroidTest

