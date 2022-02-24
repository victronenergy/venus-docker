# Dockerized dbus playback + mqtt service

The purpose of this docker is to facilitate UI development, by being simulating
real Victron system(s).

The type of UI development meant here are UIs that relate to Venus OS: the OS on
the Victron GX range of monitoring products.

For example the VRM Portal or the HTML5 App.

Within Venus OS, all data readings gathered by the various drivers (canbus, serial,
and so forth) are made available in its internal databus, D-Bus.

This docker contains D-Bus recordings of several system types, see below. Once installed you can select
one of them. That data is then played back on D-Bus. Its also available on mqtt, since this
Docker includes the same D-Bus to MQTT translation service that is also within Venus OS.

The container can simulate different configurations (different sets of devices connected to it)
of the VenusGX by running different sets of recordings with a simple commandline api.

## Usage

- Install Docker
- Create container with `./build.sh`
- Run the container as an interactive shell with `./run.sh`
  - run `./start_services.sh` within the container to start the mqtt and other services.
  - run `./simulate.sh <simulation>` to start playback.
- Run the container in the background with a simulation with `./run.sh -s <simulation_name>`
  - to kill the container (and to remove it because of the `--rm` option) use `docker kill <container id>`
  - get the container id from the output of the run script or with `docker ps`
  - multiple can be run in parallel in which case the ports are incremented and printed by the script
- For more info run `./run.sh -h`

### Additional arguments

Additional arguments you can pass to `simulate.sh` or `run.sh` include:

  * `--with-solarcharger`: Add a solarcharger to the simulation
  * `--with-pvinverter`: Add a pvinverter to the simulation
  * `--with-tanks`: Add tank sensors to the simulation

### Working inside the container

You can see what data is available in the mqtt by using `mosquitto_sub -t N/#` or use an mqtt spy application. To change values manually use `mosquitto_pub`, but these values are likely to be overridden by an active recording quite quickly.

## Modifying recordings

Recordings can be modified with the following steps:

1. Get the recording desired as a tsv file: `./get_recording_tsv.sh <simulation>`. Simulation must be a simulation in ./simulations/X/\<simulation>.dat
2. Edit acquired tsv
3. Recompile the simulation and replace local simulation file with `./recompile_and_replace_simulation.sh <edited_simulation>.tsv <simulation>` where \<simulation> must be the same simulation file as in step 1

## Systems (simulations)

Battery selection should always be on auto; unless specified differently.

### A) Absolut Navetta 68 installation

2 x Skylla-i chargers
2 x VE.Bus Phoenix Inverter 24/3000 (230V and 120V for USA)
1 x BMV-700

And a few more devices, but they won't be connected to Venus:

1 x Phoenix charger 24/25 (for engines)
1 x BlueSmart 12/30 IP22 (for generators) Which electrical parameters can be monitored with these machines? (device by device) Is it possible to set alarms or change device functions via the interface with Garmin?"
AC Input 1 & 2 settings are (probably) to be configured as not available; we'll find out once we start working on the gui-overview for this.

Show in html5app:

- battery box
- dc loads
- inverter/charger; adjustable mode
- charger; adjustable mode + current limit

### B) Single BMV-700

Settings:

- DC system enabled

Show in html5app:

- battery box
- dc loads

### C) Single BMV-702

BMV configured to measure starter battery voltage.

Settings:

- DC-system enabled

Show in html5app:

- battery box
- dc loads

### D) Multi + BMV - Off-grid with generator

VE.Bus:

- CurrentlimitIsAdjustable = false.
- Mode is adjustable = true.

Settings:

- AC input type 1 = Generator
- AC input type 2 = Not available
- DC system disabled

Show in html5app:

- battery box
- dc loads
- ac loads
- inverter/charger; adjustable mode
- generator

### E) Multi + BMV - Boat without generator

VE.Bus:

- CurrentlimitIsAdjustable = true.
- Mode is adjustable = true.

Settings:

- AC input type 1 = Shore
- AC input type 2 = Not available
- DC system enabled

Show in html5app:

- battery box
- dc loads
- ac loads
- inverter/charger; adjustable mode + input current
- shore power

### F) Quattro + BMV - boat with generator - single phase

VE.Bus:

- AcIn/0/CurrentlimitIsAdjustable-ac-input = false.
- AcIn/1/CurrentlimitIsAdjustable-ac-input = true.
- Mode is adjustable = true.

Settings:

- AC input type 1 = Generator
- AC input type 2 = Shore
- DC system enabled

Show in html5app:

- battery box
- dc loads
- ac loads
- inverter/charger; adjustable mode + input current
- shore power
- generator

### G) Charger + BMV - simple boat

Settings:

- AC input type 1 = shore
- AC input type 2 = not available
- DC system enabled

Show in html5app:

- battery box
- dc loads
- charger; adjustable mode + input current

### H) VE.Direct Inverter + BMV - typical simple vehicle - only charged from alternator

Settings:

- AC input types both on not available
- DC system enabled

Show in html5app:

- battery box
- dc loads
- inverter; adjustable mode (on/off/eco)

### I) Quattro without BMV - Hybrid generator - single phase

VE.Bus:

- AcIn/0/CurrentlimitIsAdjustable-ac-input = false.
- AcIn/1/CurrentlimitIsAdjustable-ac-input = true.
- Mode is adjustable = true.

Settings:

- AC Input type 1 = generator
- AC input type 2 = grid
- DC system disabled

Show in html5app:

- battery box
- dc loads
- ac loads
- inverter/charger; adjustable mode + input current
- grid
- generator

### J) 4 x BMV-700

Settings:

- DC system enabled

Show in html5app:

- battery box
- dc loads

### K) Quattro without BMV - Hybrid generator - three phase

VE.Bus:

- AcIn/0/CurrentlimitIsAdjustable-ac-input = false.
- AcIn/1/CurrentlimitIsAdjustable-ac-input = true.
- Mode is adjustable = true.

Settings:

- AC Input type 1 = generator
- AC input type 2 = grid
- DC system disabled

Show in html5app:

- battery box
- ac loads
- inverter/charger; adjustable mode + input current
- generator; 3-phase
- grid; 3-phase

### L) Quattro + BMV - boat with generator - three phase

VE.Bus:

- AcIn/0/CurrentlimitIsAdjustable-ac-input = false.
- AcIn/1/CurrentlimitIsAdjustable-ac-input = true.
- Mode is adjustable = true.

Settings:

- AC input type 1 = Generator
- AC input type 2 = Shore
- DC system enabled

Show in html5app:

- battery box
- dc loads
- ac loads
- inverter/charger; adjustable mode + input current
- generator; 3-phase
- shore; 3-phase

### M) Multi with a VE.Bus BMS

Note https://github.com/victronenergy/venus-private/issues/86. The demo mode is now
not how reality is. And how reality will be is unknown as of yet.

VE.Bus:

- AcIn/0/CurrentlimitIsAdjustable-ac-input = false.
- AcIn/1/CurrentlimitIsAdjustable-ac-input = false.
- Mode is adjustable = false.

Settings:

- AC input type 1 = Grid
- AC input type 2 = Not available
- DC system disabled

Show in html5app:

- battery box
- ac loads
- inverter/charger; read-only mode + input current
- shore

### N) Fischer Panda Generator - Genset - three phase

Settings:

- AC input type 1 = Generator

Show in html5app:

- generator control panel

### O) Quattro + BMV - boat with generator  (single phase) + Fischer Panda Generator (three phase) (Simulations F + N)

### P) Multi + BMV + tanks - RV with 4 tanks and without generator

VE.Bus:

- CurrentlimitIsAdjustable = true.
- Mode is adjustable = true.

Settings:

- AC input type 1 = Shore
- AC input type 2 = Not available
- DC system enabled

Show in html5app:

- battery box
- dc loads
- ac loads
- inverter/charger; adjustable mode + input current
- shore power
- 4 tanks

### Q) Multi + 3 x SmartShunt + Solar - Yacht without generator

VE.Bus:

- CurrentlimitIsAdjustable = true.
- Mode is adjustable = true.

Settings:

- AC input type 1 = Shore
- AC input type 2 = Not available
- DC system enabled

### R) 35ft yacht - 12V MultiPlus 12/1600

### S) 50ft yacht – 24V Quattro 24/5000

## Using venus-docker with a real Venus device

- On the Venus device, edit your `/etc/ssh/sshd_config` to allow remote
  connections to forwarded ports:

      GatewayPorts clientspecified

- Restart openssh to make the above take effect:

      svc -t /service/openssh

- On the venus device, stop mosquitto:

      svc -d /service/mosquitto

- On the machine that hosts the venus-docker setup, start a venus-docker
  simulation as you normally would.

- Forward the port to the venus device using ssh. Note the leading `:`:

      ssh -R :9001:localhost:9001 root@192.168.22.75

- Browse to the web application: http://192.168.22.75/app

## Building dbus-spy

A binary copy of dbus-spy is already included in this repo, but should you need
to rebuild it, these are the steps:

    git clone git@github.com:victronenergy/dbus-spy.git
    cd dbus-spy
    git submodule update --init
    cd ..
    docker build -f dockerfile.dbus-spy . -t dbus-spy

Then copy dbus-spy out of a throwaway container by first starting a container:

    docker run -it --rm dbus-spy

Then copy dbus-spy to bin:

    docker cp <container>:/usr/local/bin/dbus-spy bin/dbus-spy
