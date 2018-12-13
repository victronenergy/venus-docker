#!/bin/bash

PLAY="/usr/bin/python /opt/victronenergy/dbus-recorder/play.py"

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

$PLAY simulations/$sim/*.dat
