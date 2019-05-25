
## Start Android Emulator

    # make use of hardware acceleration
    docker run --name android-emulator -d -p 5555:5555 --device /dev/kvm chrisss404/android-emulator:latest

    # use software rendering
    docker run --name android-emulator -d -p 5555:5555 chrisss404/android-emulator:latest


## List Connected Devices

    $ adb devices -l
    List of devices attached
    emulator-5554          device product:sdk_gphone_x86 model:Android_SDK_built_for_x86 device:generic_x86 transport_id:1


## Run Instrumentation Tests

    ./gradlew connectedAndroidTest

