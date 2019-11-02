FROM openjdk:8-jre-slim

ARG ANDROID_SDK_SHA1SUM=8c7c28554a32318461802c1291d76fccfafde054
ARG ANDROID_SDK_VERSION=4333796
ARG SUPERCRONIC_SHA1SUM=5ddf8ea26b56d4a7ff6faecdd8966610d5cb9d85
ARG SUPERCRONIC_VERSION=v0.1.9

ENV ANDROID_HOME=/var/android-sdk

USER root

RUN apt-get update && apt-get install -y unzip wget && \
    # get android sdk
    wget https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip -O sdk-tools-linux.zip && \
    echo "${ANDROID_SDK_SHA1SUM}  sdk-tools-linux.zip" | sha1sum -c - && \
    unzip sdk-tools-linux.zip -d ${ANDROID_HOME} && \
    ln -s ${ANDROID_HOME}/emulator/emulator /usr/local/bin && \
    ln -s ${ANDROID_HOME}/tools/bin/avdmanager /usr/local/bin && \
    ln -s ${ANDROID_HOME}/tools/bin/sdkmanager /usr/local/bin && \
    (yes | sdkmanager --licenses) && \
    sdkmanager "platform-tools" && \
    ln -s ${ANDROID_HOME}/platform-tools/adb /usr/local/bin && \
    rm sdk-tools-linux.zip && \
    echo "5 4 * * * /usr/bin/find /tmp/android* -mtime +3 -exec rm -rf {} \;" > ${ANDROID_HOME}/cleanup.cron && \
    # get supercronic
    wget https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-amd64 -O /usr/local/bin/supercronic && \
    echo "${SUPERCRONIC_SHA1SUM}  /usr/local/bin/supercronic" | sha1sum -c - && \
    chmod +x /usr/local/bin/supercronic && \
    # cleanup and get runtime dependencies
    apt-get remove -y unzip wget && apt-get auto-remove -y && \
    apt-get install -y libfontconfig libglu1 libnss3-dev libxcomposite1 libxcursor1 libpulse0 libasound2 socat && \
    rm -rf /var/lib/apt/lists/* && \
    # create unprivileged user
    addgroup --gid 1000 android && \
    useradd -u 1000 -g android -ms /bin/sh android && \
    chown -R android:android ${ANDROID_HOME}


ARG ANDROID_DEVICE="Nexus One"
ARG ANDROID_VERSION=29

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
