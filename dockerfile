FROM ubuntu
WORKDIR /root

# system libs

### Some of these are probably not actually required?
RUN apt-get update
RUN apt-get install -y python2.7 
RUN apt-get install -y python-pip 
RUN apt-get install -y pkg-config
RUN apt-get install -y mosquitto mosquitto-clients

# Service libs
###  Why?
RUN apt-get install -y libdbus-1-dev
RUN apt-get install -y libperl-dev
RUN apt-get install -y libgtk2.0-dev
### /Why

RUN pip install lxml requests dbus-python 

# Service code
### Probably all of the seds should be fixed in a smarter way.

COPY localsettings /root/localsettings
COPY dbus-systemcalc-py /root/dbus-systemcalc-py
COPY dbus-mqtt /root/dbus-mqtt
COPY dbus-recorder /root/dbus-recorder

### localsettings service
WORKDIR /root/localsettings
RUN sed -i 's/from gobject/from gi.repository.GObject/g' *.py
COPY settings.xml /data/conf/settings.xml

### dbus-systemcalc service
WORKDIR /root/dbus-systemcalc-py
RUN sed -i 's/import gobject/from gi.repository import GObject as gobject/g' *.py
RUN sed -i 's/from gobject/from gi.repository.GObject/g' ext/velib_python/*.py
RUN sed -i 's/import gobject/from gi.repository import GObject as gobject/g' delegates/*.py

### dbus-mqtt service
WORKDIR /root/dbus-mqtt
RUN sed -i 's/import gobject/from gi.repository import GObject as gobject/g' *.py

### dbus-recorder service
WORKDIR /root/dbus-recorder
RUN sed -i 's/from gobject/from gi.repository.GObject/g' *.py

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
