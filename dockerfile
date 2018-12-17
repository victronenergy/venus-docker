# dbus-spy build
FROM ubuntu as dbus-spy-build

RUN apt-get update
RUN apt-get install -y libqt4-dev libqt4-dev-bin libncurses5-dev make g++
COPY dbus-spy /root/dbus-spy
WORKDIR /root/dbus-spy/software
RUN qmake && make && make install

# venus-docker build
FROM ubuntu
WORKDIR /root

### Some of these are probably not actually required?
RUN apt-get update
RUN apt-get install -y python2.7 python-gobject-2
RUN apt-get install -y python-lxml python-requests python-dbus
RUN apt-get install -y mosquitto mosquitto-clients vim daemontools
RUN apt-get install -y libqtcore4 libqtdbus4 libncurses5

# dbus
COPY dbus-tools/dbus /usr/bin/dbus
COPY dbus-system.conf /etc/dbus-1/system.d/victron.conf

# dbus-spy
COPY --from=dbus-spy-build /usr/local/bin/dbus-spy /usr/local/bin/dbus-spy

# Daemontools
RUN mkdir /log
COPY service /service

# Service code
COPY localsettings /opt/victronenergy/localsettings
COPY dbus-systemcalc-py /opt/victronenergy/dbus-systemcalc-py
COPY dbus-mqtt /opt/victronenergy/dbus-mqtt
COPY dbus-recorder /opt/victronenergy/dbus-recorder
COPY settings.xml /data/conf/settings.xml

# System service config 
RUN echo 'listener 9001' >> /etc/mosquitto/mosquitto.conf
RUN echo 'protocol websockets' >> /etc/mosquitto/mosquitto.conf
RUN echo 'listener 1883' >> /etc/mosquitto/mosquitto.conf
RUN echo 'protocol mqtt' >> /etc/mosquitto/mosquitto.conf

# Run config
COPY run.sh /root
COPY run_with_simulation.sh /root
COPY bin/ /root/bin

RUN chmod u+x /root/bin/* /root/run.sh /root/run_with_simulation.sh

# Simulations
COPY simulate.sh /root
COPY simulations /root/simulations

EXPOSE 9001
EXPOSE 1883
EXPOSE 3000
