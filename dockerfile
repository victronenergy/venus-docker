# Build dbus-spy
FROM ubuntu:24.04 AS dbus-spy
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y --no-install-recommends qt6-base-dev libncurses-dev make g++
COPY dbus-spy /root/dbus-spy
WORKDIR /root/dbus-spy/software
RUN qmake6 && make

# Compile html5 app
FROM node:lts-alpine AS html5-app
COPY venus-html5-app/package.json .
COPY venus-html5-app/package-lock.json .
RUN npm install
COPY venus-html5-app .
ENV PUBLIC_URL=/
ENV REACT_APP_ENABLE_LANG_OVERRIDE=true
RUN npm run build 

# Build flashmq
FROM ubuntu:24.04 AS flashmq
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y --no-install-recommends g++ make cmake libssl-dev file docbook2x
COPY flashmq .
RUN nproc=$(nproc) && cmake -DCMAKE_BUILD_TYPE=Release && make -j "$nproc"

# Build dbus-flashmq
FROM ubuntu:24.04 AS dbus-flashmq
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y --no-install-recommends g++ make cmake pkg-config libdbus-1-dev libssl-dev
COPY dbus-flashmq .
RUN nproc=$(nproc) && cmake -DCMAKE_BUILD_TYPE=Release && make -j "$nproc"

# Venus-docker build
FROM ubuntu:24.04
WORKDIR /root
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y --no-install-recommends python3 python3-gi \
    python3-lxml python3-requests python3-dbus python3-paho-mqtt \
    python3-dnslib python3-pip python3-venv python3-psutil
RUN apt-get install -y --no-install-recommends vim daemontools dbus
RUN apt-get install -y --no-install-recommends libqt6core6t64 libqt6dbus6t64 libqt6xml6t64 libncurses6
RUN apt-get install -y nginx

# We need an old version of pymodbus
RUN pip install --break-system-packages pymodbus==2.5.3

# flashmq
COPY --from=flashmq flashmq /usr/bin/flashmq
COPY --from=dbus-flashmq libflashmq-dbus-plugin.so /usr/libexec/flashmq/libflashmq-dbus-plugin.so
COPY flashmq.conf /etc/flashmq/flashmq.conf

# dbus
COPY dbus-tools/dbus /usr/bin/dbus
COPY dbus-system.conf /etc/dbus-1/system.d/victron.conf

# dbus-spy
COPY --from=dbus-spy /root/dbus-spy/software/dbus-spy /usr/local/bin/dbus-spy

# Daemontools
RUN mkdir /log
COPY service /service

# DSE genset modbus simulator
COPY dse-modbus-simulator /opt/victronenergy/dse-modbus-simulator
RUN python3 -m venv /opt/victronenergy/dse-modbus-simulator/p
RUN /opt/victronenergy/dse-modbus-simulator/p/bin/pip install --no-cache-dir --upgrade pip && \
    /opt/victronenergy/dse-modbus-simulator/p/bin/pip install --no-cache-dir -r /opt/victronenergy/dse-modbus-simulator/requirements.txt
RUN chmod u+x /opt/victronenergy/dse-modbus-simulator/main.py

# Service code
COPY localsettings /opt/victronenergy/localsettings
COPY dbus-systemcalc-py /opt/victronenergy/dbus-systemcalc-py
COPY dbus-recorder /opt/victronenergy/dbus-recorder
COPY dbus_generator /opt/victronenergy/dbus-generator-starter
COPY dbus-modbus-client /opt/victronenergy/dbus-modbus-client
COPY settings.xml /data/conf/settings.xml
COPY settings.xml /data/conf/settings.xml.orig
COPY version /opt/victronenergy/version

# Run config
COPY scripts/start_services.sh /root
COPY scripts/run_with_simulation.sh /root
COPY scripts/run_recording.sh /root/bin/

RUN chmod u+x /root/bin/* /root/start_services.sh /root/run_with_simulation.sh

# Simulations
COPY scripts/simulate.sh /root
COPY simulations /root/simulations

# Html5 app
COPY venus_app.conf /etc/nginx/sites-available
COPY --from=html5-app ./dist/ /var/www/venus_app/
RUN ln -s /etc/nginx/sites-available/venus_app.conf /etc/nginx/sites-enabled
RUN rm /etc/nginx/sites-enabled/default

EXPOSE 80
EXPOSE 9001
EXPOSE 1883
EXPOSE 3000
EXPOSE 8000
EXPOSE 502
