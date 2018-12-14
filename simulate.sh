#!/bin/bash

PLAY="/usr/bin/python /opt/victronenergy/dbus-recorder/play.py"
DBUS="/usr/bin/dbus"

help() {
	echo "Usage: $0 simulation_name"
	echo
	echo "Available simulations:"
	for d in simulations/*; do
		echo -n `basename $d`": "
		cat $d/description
	done
}

if test -z "$1"; then
	help
	exit 0
fi

sim=${1,,}

# Perform any setup that might be required for this demo
if test -f simulations/$sim/setup; then
	while read -r line; do
		read -r service path value <<< "$line"
		$DBUS -y $service $path SetValue $value > /dev/null
	done < simulations/$sim/setup
fi

if test "$sim" = "z"; then
  /opt/victronenergy/dbus-recorder/play.sh 3 &
else
  $PLAY simulations/$sim/*.dat
fi
