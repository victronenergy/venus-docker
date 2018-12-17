# WIP dockerized dbus playback + mqtt service

Use this docker to run an mqtt broker that serves recorded dbus data. Main use case would be to run this instead of having a real Venus GX device or VenusOs running in a raspberry pi, making local development work much easier but also more realistic. The container can run different configurations (different sets of devices connected to it) of the VenusGX by running different sets of recordings with a simple commandline api.

## Usage

- Install Docker
- Create container with `./build.sh`
- Run container with `docker run -it --rm -p 9001:9001 -p 1883:1883 -p 3000:3000 mqtt`. This opens an interactive shell and removes the container when disconnected. If you want to hack around and keep your work in the container for now, remove the `--rm` option.
- Run `./run.sh` within the container to start the mqtt and other services.
- Run `./simulate.sh <simulation>` to start playback.
  - `<simulation>` must be a folder in `simulations/<simulation>`
  - Call it with no arguments to get a list of options.

### Working inside the container

You can see what data is available in the mqtt by using `mosquitto_sub -t N/#` or use an mqtt spy application. To change values manually use `mosquitto_pub`, but these values are likely to be overridden by an active recording quite quickly.

## Advanced usage

This section is noted as advanced since it may require more docker skills than running the container. All pretty basic stuff anyway.

To run the container in the background with a simulation do the following:

- run `docker run -d --rm -p 9001:9001 -p 1883:1883 mqtt /root/run_with_simulation.sh <simulation>`
  - `<simulation>` must be a folder in `simulations/<simulation>` or the `run.sh` will fail and the container will exit **without errors**
- to kill the container (and to remove it because of the `--rm` option) use `docker kill <container id>`
  - get the container id from - output of the run script - `docker ps`

## Modifying recordings

Recordings can be modified (and created) using the dump and assemble tools in
the [dbus-recorder][1] repo.

[1]: https://github.com/victronenergy/dbus-recorder
