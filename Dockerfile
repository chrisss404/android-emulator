FROM openjdk:11-jre-slim

ARG ANDROID_COMMAND_LINE_TOOLS_SHA256_SUM=124f2d5115eee365df6cf3228ffbca6fc3911d16f8025bebd5b1c6e2fcfa7faf
ARG ANDROID_COMMAND_LINE_TOOLS_VERSION=7583922_latest
ARG SUPERCRONIC_SHA1SUM=5ddf8ea26b56d4a7ff6faecdd8966610d5cb9d85
ARG SUPERCRONIC_VERSION=v0.1.9

ENV ANDROID_SDK_ROOT=/var/android-sdk

USER root

RUN apt-get update && apt-get install -y unzip wget && \
    mkdir -p ${ANDROID_SDK_ROOT} && \
    # get android command line tools
    wget https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_COMMAND_LINE_TOOLS_VERSION}.zip -O commandlinetools-linux.zip && \
    echo "${ANDROID_COMMAND_LINE_TOOLS_SHA256_SUM} commandlinetools-linux.zip" | sha256sum -c - && \
    unzip commandlinetools-linux.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    ln -s ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/avdmanager /usr/local/bin && \
    ln -s ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager /usr/local/bin && \
    (yes | sdkmanager --licenses) && \
    sdkmanager "emulator" "platform-tools" && \
    ln -s ${ANDROID_SDK_ROOT}/emulator/emulator /usr/local/bin && \
    ln -s ${ANDROID_SDK_ROOT}/platform-tools/adb /usr/local/bin && \
    rm commandlinetools-linux.zip && \
    echo "5 4 * * * /usr/bin/find /tmp/android* -mtime +3 -exec rm -rf {} \;" > ${ANDROID_SDK_ROOT}/cleanup.cron && \
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
    chown -R android:android ${ANDROID_SDK_ROOT}


ARG ANDROID_DEVICE="pixel_5"
ARG ANDROID_API_VERSION=30

USER android

RUN sdkmanager "platforms;android-${ANDROID_API_VERSION}" "system-images;android-${ANDROID_API_VERSION};google_apis;x86" && \
    rm ${ANDROID_SDK_ROOT}/emulator/qemu/linux-x86_64/qemu-system-aarch64* && \
    rm ${ANDROID_SDK_ROOT}/emulator/qemu/linux-x86_64/qemu-system-armel* && \
    rm ${ANDROID_SDK_ROOT}/emulator/qemu/linux-x86_64/qemu-system-i386* && \
    avdmanager create avd --name 'Emulator' --package "system-images;android-${ANDROID_API_VERSION};google_apis;x86" --device "${ANDROID_DEVICE}"


COPY ./docker-entrypoint.sh /usr/bin/

EXPOSE 5555

HEALTHCHECK CMD \[ $(adb shell getprop sys.boot_completed) \] || exit 1
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["emulator", "@Emulator", "-use-system-libs", "-read-only", "-no-boot-anim", "-no-window", "-no-audio", "-no-snapstorage", "-verbose"]
