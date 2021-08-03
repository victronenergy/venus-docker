#!/bin/bash

# Use this to run killed/new recordings in a running container

if [ $# -eq 0 ]; then
    echo "Usage: $0 <recording_file_name>. The recording file must exist in /opt/victronenergy/dbus-recorder"
    echo "e.g. $0 vebus-marine.dat"
    exit 1
fi

python3 /opt/victronenergy/dbus-recorder/dbusrecorder.py -p --file=/opt/victronenergy/dbus-recorder/$1 &
