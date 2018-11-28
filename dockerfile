FROM ubuntu

######################## system libs
WORKDIR /root

# Some of these are probably not actualyl required?
RUN apt-get update
RUN apt-get install -y git 
RUN apt-get install -y python2.7 
RUN apt-get install -y python-pip 
RUN apt-get install -y dbus-x11
RUN apt-get install -y pkg-config
RUN apt-get install -y mosquitto

######################## service libs
#  Why?
RUN apt-get install -y libdbus-1-dev
RUN apt-get install -y libperl-dev
RUN apt-get install -y libgtk2.0-dev
# /Why

RUN pip install lxml requests dbus-python 

# Probably all of the seds should be fixed in a smarter way.
######################## localsettings service
RUN git clone https://github.com/victronenergy/localsettings.git
WORKDIR /root/localsettings
RUN git submodule init
RUN git submodule update
RUN sed -i 's/from gobject/from gi.repository.GObject/g' *.py
COPY settings.xml /data/conf/settings.xml

######################## dbus-systemcalc service
WORKDIR /root
RUN git clone https://github.com/victronenergy/dbus-systemcalc-py.git
WORKDIR /root/dbus-systemcalc-py
RUN git submodule init
RUN git submodule update
RUN sed -i 's/import gobject/from gi.repository import GObject as gobject/g' *.py
RUN sed -i 's/from gobject/from gi.repository.GObject/g' ext/velib_python/*.py
RUN sed -i 's/import gobject/from gi.repository import GObject as gobject/g' delegates/*.py

######################## dbus-mqtt service
WORKDIR /root
RUN git clone https://github.com/victronenergy/dbus-mqtt.git
WORKDIR /root/dbus-mqtt
RUN git submodule init
RUN git submodule update
RUN sed -i 's/import gobject/from gi.repository import GObject as gobject/g' *.py

######################## dbus-recorder service
WORKDIR /root
RUN git clone https://github.com/victronenergy/dbus-recorder.git
WORKDIR /root/dbus-recorder
RUN sed -i 's/from gobject/from gi.repository.GObject/g' *.py

######################## system service config 
RUN echo 'listener 9001' >> /etc/mosquitto/mosquitto.conf
RUN echo 'protocol websockets' >> /etc/mosquitto/mosquitto.conf
RUN echo 'listener 1883' >> /etc/mosquitto/mosquitto.conf
RUN echo 'protocol mqtt' >> /etc/mosquitto/mosquitto.conf


WORKDIR /root
######################## run config
COPY run.sh /root
RUN chmod u+x run.sh

# Enable when script & recordings settings are done, until then build, run and attach to hack around.
# ENTRYPOINT [ "/root/run.sh" ]

EXPOSE 9001
EXPOSE 1883
