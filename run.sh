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
            shift # past argument
        ;;
    esac
done

if test -z "$SIMULATION"; then
    docker run -it --rm -p 9001:9001 -p 1883:1883 -p 3000:3000 mqtt
else
    if test -f simulations/$SIMULATION/setup; then
        docker run -d --rm -p 9001:9001 -p 1883:1883 -p 3000:3000 mqtt /root/run_with_simulation.sh $SIMULATION
    else
        echo "Simulation ($SIMULATION) does not exist in simulations/"
        available
    fi
fi