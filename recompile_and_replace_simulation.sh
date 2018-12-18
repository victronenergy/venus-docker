#!/bin/bash

TSV=$1
REPLACE_FILE=$2
CONTAINER=`docker ps -aqf ancestor=mqtt`

if test -z "$CONTAINER"; then
    echo "Starting container"
    ./run.sh -s a
    CONTAINER=`docker ps -aqf ancestor=mqtt`
fi

if test -n "$TSV" && test -n "$REPLACE_FILE" && test -f $REPLACE_FILE; then
    docker cp $TSV $CONTAINER:/root
    REPLACE_FILE_NAME=`basename $REPLACE_FILE`
    docker exec $CONTAINER sh -c "python /opt/victronenergy/dbus-recorder/tools/assemble.py /root/$TSV /root/$REPLACE_FILE_NAME"
    docker cp $CONTAINER:/root/$REPLACE_FILE_NAME .
    mv $REPLACE_FILE_NAME $REPLACE_FILE
else
    echo "usage: $0 <altered tsv file> <dat file to replace>"
    echo "Replace file must be a .dat file in simulations/x/"
fi
