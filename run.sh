#!/bin/bash

cd
export $(dbus-launch)
service mosquitto start
python localsettings/localsettings.py &
python dbus-systemcalc-py/dbus_systemcalc.py &
python dbus-mqtt/dbus_mqtt.py &
./dbus-recorder/play.sh &
