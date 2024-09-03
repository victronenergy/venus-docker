#!/bin/bash

shopt -s nullglob

PLAY="/usr/bin/python3 /opt/victronenergy/dbus-recorder/play.py"
DBUS="/usr/bin/dbus"
RUN_DIR="/root"
SIMULATIONS="$RUN_DIR/simulations"

help() {
	echo "Usage: $0 simulation_name"
	echo
	echo "Available simulations:"
	for d in $SIMULATIONS/*; do
		echo -n `basename $d`": "
		cat $SIMULATIONS/`basename $d`/description
	done
}

settings_available() {
        python3 -c 'import sys, dbus; sys.exit("com.victronenergy.settings" not in dbus.SystemBus().list_names())'
}

# Handle options
extra=""
while :; do
	case "$1" in
		"--with-solarcharger")
			shift
			extra="$extra /opt/victronenergy/dbus-recorder/solarcharger.csv"
			;;
		"--with-pvinverter")
			shift
			extra="$extra /opt/victronenergy/dbus-recorder/pvinverter.csv"
			;;
		"--with-tanks")
			shift
			tanks=(/opt/victronenergy/dbus-recorder/tank_{fwater,fuel,oil,bwater}.csv)
			extra="$extra ${tanks[@]}"
			;;
		-*)
			help
			exit 1
			;;
		*)
			break
			;;
	esac
done

if test -z "$1"; then
	help
	exit 0
fi

sim=${1,,}

# First restore the default config
svc -d /service/localsettings
cp /data/conf/settings.xml.orig /data/conf/settings.xml
svc -u /service/localsettings

# Wait for localsettings
echo -n "Waiting for localsettings "
while ! settings_available; do
        echo -n '.'
        sleep 1
done; echo

# Perform any setup that might be required for this demo
if test -f $SIMULATIONS/$sim/setup; then
	echo "Applying settings for this simulation..."
	while read -r line; do
		read -r service path value <<< "$line"
		if $DBUS -y $service $path GetValue > /dev/null 2>&1; then
			echo "Setting $service $path to $value"
			$DBUS -y $service $path SetValue "$value" > /dev/null
		elif test "$service" = "com.victronenergy.settings"; then
			echo "Add setting ${path} to $service with default value $value"
			settings="%[{\"path\": \"${path#/Settings/}\", \"default\": ${value}}]"
			$DBUS -y $service /Settings AddSettings "${settings}" > /dev/null
		else
			echo "Unable to set $service $path to $value"
		fi
	done < $SIMULATIONS/$sim/setup
fi

echo "Starting the simulation, press ctrl+C to terminate."
if test "$sim" = "z"; then
  /opt/victronenergy/dbus-recorder/play.sh 3 &
elif test "$sim" = "dse"; then
  svc -u /service/dse-modbus-simulator
  sleep infinity
else
  $PLAY $SIMULATIONS/$sim/*.{dat,csv} $extra
fi
