#!/bin/bash

/root/run.sh

if [ $# -ne 0 ] && test -d /root/simulations/$1; then
    echo "Running simulation ($1)"
    /root/simulate.sh $1 &
    sleep infinity
fi
