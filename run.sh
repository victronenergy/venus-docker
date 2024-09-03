#!/bin/bash

available() {
    echo "Available simulations:"
    for d in simulations/*; do
        echo -n `basename $d`": "
        cat $d/description
    done
}

kill_others() {
    echo "Killing previous dockers:"
    docker ps -q --filter "ancestor=mqtt" | xargs -r docker kill
    echo ""
}

help() {
    echo "Usage: $0 [-h|--help] [-s|--simulation <simulation_name>]"
    available
}
POSITIONAL=()
ARGS=()
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
        --kill)
            KILL=true
            shift # past argument
        ;;
		--with-*)
			ARGS+=("$1")
			shift
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
DSE_SIMULATOR_WEBUI_PORT=$((8000+$RUNNING_CONTAINERS))
DSE_SIMULATOR_MODBUS_PORT=$((502+$RUNNING_CONTAINERS))

if test -n "$POSITIONAL"; then
    echo "Positional argument(s) ($POSITIONAL) passed. Did you mean to run with -s?"
    available
    exit 1
elif test -z "$SIMULATION"; then
    if test "$KILL" = "true"; then kill_others; fi
    cat << EndOfMessage 
After running ./start_services.sh, the following comes available:
  - Web interfaces
    - Html5 app at http://localhost:${APP_PORT}
    - DSE genset simulator at http://localhost:${DSE_SIMULATOR_WEBUI_PORT}
  - Other services
    - websocket at port ${WSPORT}
    - mqtt at port      ${MQTTPORT}
    - dbus at port      ${DBUSTCPPORT}

EndOfMessage
    docker run -it --rm -p $WSPORT:9001 -p $MQTTPORT:1883 -p $DBUSTCPPORT:3000 -p $APP_PORT:80 -p $DSE_SIMULATOR_WEBUI_PORT:8000 mqtt || exit 1
    exit 0
else
    if test -f simulations/$SIMULATION/setup; then
        if test "$KILL" = "true"; then kill_others; fi
        docker run -d --rm -p $WSPORT:9001 -p $MQTTPORT:1883 -p $DBUSTCPPORT:3000 -p $APP_PORT:80 mqtt /root/run_with_simulation.sh ${ARGS[@]} $SIMULATION || exit 1
    elif test "$SIMULATION" = "z"; then
        if test "$KILL" = "true"; then kill_others; fi
        docker run -d --rm -p $WSPORT:9001 -p $MQTTPORT:1883 -p $DBUSTCPPORT:3000 -p $APP_PORT:80 mqtt /root/run_with_simulation.sh z || exit 1
    elif test "$SIMULATION" = "dse"; then
        if test "$KILL" = "true"; then kill_others; fi
        docker run -d --rm -p $DSE_SIMULATOR_WEBUI_PORT:8000 -p 0.0.0.0:$DSE_SIMULATOR_MODBUS_PORT:502 mqtt /root/run_with_simulation.sh dse || exit 1
        echo "DSE simulator web ui available at localhost:${DSE_SIMULATOR_WEBUI_PORT} and its modbus server at 0.0.0.0:${DSE_SIMULATOR_MODBUS_PORT} (unit id 1)"
        exit 0
    else
        echo "Simulation ($SIMULATION) does not exist in simulations/"
        available
        exit 1
    fi
    echo "Html5 app available at: localhost:${APP_PORT}, websocket port: ${WSPORT}, mqtt port: ${MQTTPORT}, dbus port: ${DBUSTCPPORT}"
fi


