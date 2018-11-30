#!/bin/bash

cd
export DBUS_SESSION_BUS_ADDRESS=$(dbus-daemon --syslog --fork --print-address --session)
echo $DBUS_SESSION_BUS_ADDRESS > /tmp/dbus_session_address
service mosquitto start
python localsettings/localsettings.py &
python dbus-systemcalc-py/dbus_systemcalc.py &
python dbus-mqtt/dbus_mqtt.py &
./dbus-recorder/play.sh &
