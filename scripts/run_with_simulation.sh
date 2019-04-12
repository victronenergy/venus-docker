#!/bin/bash

RUN_DIR="/root"
SIMULATIONS="$RUN_DIR/simulations"

ARGS=""
while [ -n "$1" ]; do
	case "$1" in
		--*)
			ARGS="$ARGS $1";
			shift
		;;
		*) 
			break
		;;
	esac
done

if [ $# -ne 0 ] && test -d $SIMULATIONS/$1; then
    echo "Running with simulation ($1)"
    $RUN_DIR/start_services.sh
    $RUN_DIR/simulate.sh $ARGS $1 &
    sleep infinity
fi
