#!/bin/bash

# Create dummy relays before systemcalc is started
mkdir -p /dev/gpio/relay_1 && touch /dev/gpio/relay_1/value

service dbus start
service mosquitto start
svscan /service &

# wait that messaging is initialized
sleep 2

# subscribe to the system/0/Serial to get the portal ID and then issue a read to that ID
mosquitto_pub -t R/"$(mosquitto_sub -v -C 1 -t 'N/+/system/0/Serial' | cut -d'"' -f4)"/system/0/Serial -m "dummy"
