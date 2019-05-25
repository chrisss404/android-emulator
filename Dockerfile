FROM openjdk:8-jre-slim

ARG ANDROID_SDK_VERSION=4333796
ENV ANDROID_HOME=/var/android-sdk

USER root

RUN apt-get update && apt-get install -y unzip wget libglu1 libpulse0 socat && \
    wget https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip -O sdk-tools-linux.zip && \
    unzip sdk-tools-linux.zip -d ${ANDROID_HOME} && \
    ln -s ${ANDROID_HOME}/emulator/emulator /usr/local/bin && \
    ln -s ${ANDROID_HOME}/tools/bin/avdmanager /usr/local/bin && \
    ln -s ${ANDROID_HOME}/tools/bin/sdkmanager /usr/local/bin && \
    (yes | sdkmanager --licenses) && \
    sdkmanager "platform-tools" && \
    ln -s ${ANDROID_HOME}/platform-tools/adb /usr/local/bin && \
    rm sdk-tools-linux.zip && \
    apt-get remove -y unzip wget && \
    rm -rf /var/lib/apt/lists/* && \
    addgroup --gid 1000 android && \
    useradd -u 1000 -g android -ms /bin/sh android && \
    chown -R android:android ${ANDROID_HOME}


ARG ANDROID_DEVICE="Nexus One"
ARG ANDROID_VERSION=28

USER android

RUN sdkmanager "platforms;android-${ANDROID_VERSION}" "system-images;android-${ANDROID_VERSION};google_apis;x86" && \
    rm ${ANDROID_HOME}/emulator/qemu/linux-x86_64/qemu-system-aarch64* && \
    rm ${ANDROID_HOME}/emulator/qemu/linux-x86_64/qemu-system-armel* && \
    rm ${ANDROID_HOME}/emulator/qemu/linux-x86_64/qemu-system-i386* && \
    avdmanager create avd --name 'Emulator' --package "system-images;android-${ANDROID_VERSION};google_apis;x86" --device "${ANDROID_DEVICE}"


COPY ./docker-entrypoint.sh /usr/bin/

EXPOSE 5555

HEALTHCHECK CMD \[ $(adb shell getprop sys.boot_completed) \] || exit 1
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["emulator", "@Emulator", "-use-system-libs", "-read-only", "-no-boot-anim", "-no-window", "-no-audio", "-no-snapstorage", "-verbose"]
