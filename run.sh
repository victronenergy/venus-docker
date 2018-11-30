#!/bin/bash

keepAlive=60
if [ $# -gt 0 ]; then
    keepAlive=$1
fi

cd
export DBUS_SESSION_BUS_ADDRESS=$(dbus-daemon --syslog --fork --print-address --session)
echo $DBUS_SESSION_BUS_ADDRESS > /tmp/dbus_session_address
service mosquitto start
python localsettings/localsettings.py &
python dbus-systemcalc-py/dbus_systemcalc.py &
python dbus-mqtt/dbus_mqtt.py -k $keepAlive &
./dbus-recorder/play.sh &

# wait that messaging is initialized
sleep 2

# subscribe to the system/0/Serial to get the portal ID and then issue a read to that ID 
mosquitto_pub -t R/"$(mosquitto_sub -v -C 1 -t 'N/+/system/0/Serial' | cut -d'"' -f4)"/system/0/Serial -m "dummy"
