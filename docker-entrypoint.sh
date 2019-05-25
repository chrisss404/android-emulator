#!/bin/sh
set -e

# forward adb port
for ip in $(hostname -I); do
    socat tcp-listen:5555,bind=${ip},fork tcp:127.0.0.1:5555 &
done

if [ "$1" = "emulator" ]; then
    # disable hardware acceleration if not available
    if ! emulator -accel-check | grep 'is installed and usable'; then
        exec "$@" -accel off -gpu swiftshader_indirect
    fi
fi

exec "$@"
