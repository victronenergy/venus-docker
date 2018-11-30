#!/bin/bash

# Use this to run killed/new recordings in a running container

if [ $# -eq 0 ]; then
    echo "Usage: $0 <recording_file_name>. The recording file must exist in /root/dbus-recorder"
    echo "e.g. $0 vebus-marine.dat"
    exit 1
fi

export DBUS_SESSION_BUS_ADDRESS=$(cat /tmp/dbus_session_address)
python /root/dbus-recorder/dbusrecorder.py -p --file=/root/dbus-recorder/$1 &
