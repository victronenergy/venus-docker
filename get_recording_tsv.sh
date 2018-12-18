#!/bin/bash

SIMULATION=$1
CONTAINER=`docker ps -aqf ancestor=mqtt`

if test -z "$CONTAINER"; then
    echo "Starting container"
    ./run.sh -s a
    CONTAINER=`docker ps -aqf ancestor=mqtt`
fi

if test -n "$SIMULATION" && test -f $SIMULATION; then
    FILENAME=`basename $1`
    docker cp $SIMULATION $CONTAINER:/root/$FILENAME
    FILENAME="${FILENAME%.*}"
    docker exec $CONTAINER sh -c "python /opt/victronenergy/dbus-recorder/tools/dump.py /root/$FILENAME.dat > /root/$FILENAME.tsv"
    docker cp $CONTAINER:/root/$FILENAME.tsv .
else
    echo "usage: $0 simulation"
    echo "Simulation must be a .dat file in simulations/x/"
fi
