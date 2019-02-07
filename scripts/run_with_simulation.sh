#!/bin/bash

RUN_DIR="/root"
SIMULATIONS="$RUN_DIR/simulations"

if [ $# -ne 0 ] && test -d $SIMULATIONS/$1; then
    echo "Running with simulation ($1)"
    $RUN_DIR/start_services.sh
    $RUN_DIR/simulate.sh $1 &
    sleep infinity
fi
