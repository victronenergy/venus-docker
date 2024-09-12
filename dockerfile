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
FROM ubuntu:20.04 AS flashmq
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y g++ make cmake libssl-dev file docbook2x
COPY flashmq .
RUN nproc=$(nproc) && cmake -DCMAKE_BUILD_TYPE=Release && make -j "$nproc"

# Build dbus-flashmq
FROM ubuntu:20.04 AS dbus-flashmq
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y g++ make cmake pkg-config libdbus-1-dev
COPY dbus-flashmq .
RUN nproc=$(nproc) && cmake -DCMAKE_BUILD_TYPE=Release && make -j "$nproc"

# Venus-docker build
FROM ubuntu:20.04
WORKDIR /root

RUN apt-get update
RUN apt-get install -y python3 python3-gi
RUN apt-get install -y python3-lxml python3-requests python3-dbus python3-paho-mqtt
RUN apt-get install -y python3-pymodbus python3-dnslib python3-pip
RUN apt-get install -y vim daemontools
RUN apt-get install -y libqt5core5a libqt5dbus5 libqt5xml5 libncurses6
RUN apt-get install -y nginx

# flashmq
COPY --from=flashmq flashmq /usr/bin/flashmq
COPY --from=dbus-flashmq libflashmq-dbus-plugin.so /usr/libexec/flashmq/libflashmq-dbus-plugin.so
COPY flashmq.conf /etc/flashmq/flashmq.conf

# dbus
COPY dbus-tools/dbus /usr/bin/dbus
COPY dbus-system.conf /etc/dbus-1/system.d/victron.conf

# dbus-spy
COPY bin/dbus-spy /usr/local/bin/dbus-spy

# Daemontools
RUN mkdir /log
COPY service /service

# DSE genset modbus simulator
COPY dse-modbus-simulator /opt/victronenergy/dse-modbus-simulator
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r /opt/victronenergy/dse-modbus-simulator/requirements.txt
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
