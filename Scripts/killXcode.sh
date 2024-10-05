#!/bin/bash

PROCESS="Xcode"

if pgrep -qxu "$USER" "$PROCESS"; then
    echo "Force-quitting Xcode"
    killall "$PROCESS"
fi
