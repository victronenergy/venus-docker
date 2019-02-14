#!/bin/bash

available() {
    echo "Available simulations:"
    for d in simulations/*; do
        echo -n `basename $d`": "
        cat $d/description
    done
}

help() {
    echo "Usage: $0 [-h|--help] [-s|--simulation <simulation_name>]"
    available
}
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"
    
    case $key in
        -h|--help)
            help
            exit 0
        ;;
        -s|--simulation)
            SIMULATION="$2"
            shift # past argument
            shift # past value
        ;;
        *)  # unknown option
            POSITIONAL+=("$1")
            shift # past argument
        ;;
    esac
done

RUNNING_CONTAINERS=`docker ps | grep mqtt | wc -l`
APP_PORT=$((8080+$RUNNING_CONTAINERS))
WSPORT=$((9001+$RUNNING_CONTAINERS))
MQTTPORT=$((1883+$RUNNING_CONTAINERS))
DBUSTCPPORT=$((3000+$RUNNING_CONTAINERS))

echo "Html5 app available at: localhost:${APP_PORT}, websocket port: ${WSPORT}, mqtt port: ${MQTTPORT}, dbus port: ${DBUSTCPPORT}"

if test -n "$POSITIONAL"; then
    echo "Positional argument(s) ($POSITIONAL) passed. Did you mean to run with -s?"
    available
    exit 1
elif test -z "$SIMULATION"; then
    docker run -it --rm -p $WSPORT:9001 -p $MQTTPORT:1883 -p $DBUSTCPPORT:3000 -p $APP_PORT:80 mqtt
else
    if test -f simulations/$SIMULATION/setup; then
        docker run -d --rm -p $WSPORT:9001 -p $MQTTPORT:1883 -p $DBUSTCPPORT:3000 -p $APP_PORT:80 mqtt /root/run_with_simulation.sh $SIMULATION
    elif test "$SIMULATION" = "z"; then
        docker run -d --rm -p $WSPORT:9001 -p $MQTTPORT:1883 -p $DBUSTCPPORT:3000 -p $APP_PORT:80 mqtt /root/run_with_simulation.sh z
    else
        echo "Simulation ($SIMULATION) does not exist in simulations/"
        available
        exit 1
    fi
fi