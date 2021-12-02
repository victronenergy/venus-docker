# Compile html5 app
FROM node:lts-alpine as html5-app
COPY venus-html5-app/package.json .
COPY venus-html5-app/package-lock.json .
RUN npm install
COPY venus-html5-app .
ENV PUBLIC_URL=/
ENV REACT_APP_ENABLE_LANG_OVERRIDE=true
RUN npm run build 

# Venus-docker build
FROM ubuntu:20.04
WORKDIR /root

RUN apt-get update
RUN apt-get install -y python3 python3-gi
RUN apt-get install -y python3-lxml python3-requests python3-dbus python3-paho-mqtt
RUN apt-get install -y mosquitto mosquitto-clients vim daemontools
RUN apt-get install -y libqt5core5a libqt5dbus5 libqt5xml5 libncurses6
RUN apt-get install -y nginx

# dbus
COPY dbus-tools/dbus /usr/bin/dbus
COPY dbus-system.conf /etc/dbus-1/system.d/victron.conf

# dbus-spy
COPY bin/dbus-spy /usr/local/bin/dbus-spy

# Daemontools
RUN mkdir /log
COPY service /service

# Service code
COPY localsettings /opt/victronenergy/localsettings
COPY dbus-systemcalc-py /opt/victronenergy/dbus-systemcalc-py
COPY dbus-mqtt /opt/victronenergy/dbus-mqtt
COPY dbus-recorder /opt/victronenergy/dbus-recorder
COPY dbus_generator /opt/victronenergy/dbus-generator-starter
COPY settings.xml /data/conf/settings.xml
COPY settings.xml /data/conf/settings.xml.orig
COPY version /opt/victronenergy/version

# System service config 
RUN echo 'listener 9001' >> /etc/mosquitto/mosquitto.conf
RUN echo 'protocol websockets' >> /etc/mosquitto/mosquitto.conf
RUN echo 'listener 1883' >> /etc/mosquitto/mosquitto.conf
RUN echo 'protocol mqtt' >> /etc/mosquitto/mosquitto.conf

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
