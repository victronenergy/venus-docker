# WIP dockerized dbus playback + mqtt service

Use this docker to run an mqtt broker that serves recorded dbus data. Main use case would be to run this instead of having a real Venus GX device or VenusOs running in a raspberry pi, making local development work much easier but also more realistic. The container can run different configurations (different sets of devices connected to it) of the VenusGX by running different sets of recordings with a simple commandline api.

## Usage

- Install Docker
- Create container with `./build.sh`
- Run the container as an interactive shell with `./run.sh`
- Run the container in the background with a simulation with `./run.sh -s <simulation_name>`
  - run `./run.sh -h` for more info

### Working inside the container

You can see what data is available in the mqtt by using `mosquitto_sub -t N/#` or use an mqtt spy application. To change values manually use `mosquitto_pub`, but these values are likely to be overridden by an active recording quite quickly.

## Advanced usage

This section is noted as advanced since it may require more docker skills than running the container. All pretty basic stuff anyway.

To run the container and simulations as an interactive shell:

- Run container with `docker run -it --rm -p 9001:9001 -p 1883:1883 -p 3000:3000 mqtt`. This opens an interactive shell and removes the container when disconnected. If you want to hack around and keep your work in the container for now, remove the `--rm` option.
- Run `./run.sh` within the container to start the mqtt and other services.
- Run `./simulate.sh <simulation>` to start playback.
  - `<simulation>` must be a folder in `simulations/<simulation>`
  - Call it with no arguments to get a list of options.

To run the container in the background with a simulation do the following:

- run `docker run -d --rm -p 9001:9001 -p 1883:1883 mqtt /root/run_with_simulation.sh <simulation>`
  - `<simulation>` must be a folder in `simulations/<simulation>` or the `run.sh` will fail and the container will exit **without errors**
- to kill the container (and to remove it because of the `--rm` option) use `docker kill <container id>`
  - get the container id from - output of the run script - `docker ps`

## Modifying recordings

Recordings can be modified (and created) using the dump and assemble tools in
the [dbus-recorder][1] repo.

[1]: https://github.com/victronenergy/dbus-recorder

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

- main battery box
- simple battery box with only voltage (the starter battery)
- dc loads

### D) Multi + BMV - Off-grid with generator

VE.Bus:

- CurrentlimitIsAdjustable = false.
- Mode is adjustable = true.

Settings:

- AC input type 1 = Generator
- AC input type 2 = Not available
- DC system disabled

### E) Multi + BMV - Boat without generator

VE.Bus:

- CurrentlimitIsAdjustable = true.
- Mode is adjustable = true.

Settings:

- AC input type 1 = Shore
- AC input type 2 = Not available
- DC system enabled

### F) Quattro + BMV - boat with generator - single phase

VE.Bus:

- AcIn/0/CurrentlimitIsAdjustable-ac-input = false.
- AcIn/1/CurrentlimitIsAdjustable-ac-input = true.
- Mode is adjustable = true.

Settings:

- AC input type 1 = Generator
- AC input type 2 = Shore
- DC system enabled

### G) Charger + BMV - simple boat

Settings:

- AC input type 1 = shore
- AC input type 2 = not available
- DC system enabled

### H) VE.Direct Inverter + BMV - typical simple vehicle - only charged from alternator

Settings:

- AC input types both on not available
- DC system enabled

### I) Quattro without BMV - Hybrid generator - single phase

VE.Bus:

- AcIn/0/CurrentlimitIsAdjustable-ac-input = false.
- AcIn/1/CurrentlimitIsAdjustable-ac-input = true.
- Mode is adjustable = true.

Settings:

- AC Input type 1 = generator
- AC input type 2 = grid
- DC system disabled

### J) 4 x BMV-700

Settings:

- DC system enabled

### K) Quattro without BMV - Hybrid generator - three phase

VE.Bus:

- AcIn/0/CurrentlimitIsAdjustable-ac-input = false.
- AcIn/1/CurrentlimitIsAdjustable-ac-input = true.
- Mode is adjustable = true.

Settings:

- AC Input type 1 = generator
- AC input type 2 = grid
- DC system disabled

### L) Quattro + BMV - boat with generator - three phase

VE.Bus:

- AcIn/0/CurrentlimitIsAdjustable-ac-input = false.
- AcIn/1/CurrentlimitIsAdjustable-ac-input = true.
- Mode is adjustable = true.

Settings:

- AC input type 1 = Generator
- AC input type 2 = Shore
- DC system enabled

### M) Multi with a VE.Bus BMS

Note https://github.com/victronenergy/venus-private/issues/86. The demo mode is now
not how reality is. And how reality will be is unknown as of yet.

VE.Bus:

- AcIn/0/CurrentlimitIsAdjustable-ac-input = false.
- AcIn/1/CurrentlimitIsAdjustable-ac-input = false.
- Mode is adjustable = false.

Settings:

- AC input type 1 = Generator
- AC input type 2 = Shore
- DC system disabled
