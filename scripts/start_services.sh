#!/bin/bash

# Create dummy relays before systemcalc is started
mkdir -p /dev/gpio/relay_1 && touch /dev/gpio/relay_1/value

cd /opt/victronenergy/dbus-systemcalc-py/ || exit
vrmid=$(python3 -c 'from ext.velib_python.ve_utils import get_vrm_portal_id; print(get_vrm_portal_id())')
mkdir -p /data/venus && echo "$vrmid" > /data/venus/unique-id

service dbus start
service mosquitto start
svscan /service &
