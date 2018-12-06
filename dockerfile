FROM ubuntu
WORKDIR /root

# system libs

### Some of these are probably not actually required?
RUN apt-get update
RUN apt-get install -y python2.7 python-gobject-2
RUN apt-get install -y python-lxml python-requests python-dbus
RUN apt-get install -y mosquitto mosquitto-clients

# Service code
COPY localsettings /root/localsettings
COPY dbus-systemcalc-py /root/dbus-systemcalc-py
COPY dbus-mqtt /root/dbus-mqtt
COPY dbus-recorder /root/dbus-recorder

### localsettings service
WORKDIR /root/localsettings
COPY settings.xml /data/conf/settings.xml

### dbus-systemcalc service
WORKDIR /root/dbus-systemcalc-py

### dbus-mqtt service
WORKDIR /root/dbus-mqtt

### dbus-recorder service
WORKDIR /root/dbus-recorder

# System service config 
RUN echo 'listener 9001' >> /etc/mosquitto/mosquitto.conf
RUN echo 'protocol websockets' >> /etc/mosquitto/mosquitto.conf
RUN echo 'listener 1883' >> /etc/mosquitto/mosquitto.conf
RUN echo 'protocol mqtt' >> /etc/mosquitto/mosquitto.conf

WORKDIR /root
# Run config
COPY run.sh /root
RUN chmod u+x run.sh

COPY bin/ /root/bin
RUN chmod u+x /root/bin/*

# Enable when script & recordings settings are done, until then build, run and attach to hack around.
# ENTRYPOINT [ "/root/run.sh" ]

EXPOSE 9001
EXPOSE 1883
