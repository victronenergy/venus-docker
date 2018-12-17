# WIP dockerized dbus playback + mqtt service

Use this docker to run an mqtt broker that serves recorded dbus data. Main use
case would be to run this instead of having a real Venus GX device or VenusOs
running in a raspberry pi, making local development work much easier, but also
more realistic. The goal is to have the container able to run different
configurations (different sets of devices connected to it) of the VenusGX by
running different sets of recordings with a simple commandline api.

Thus far the resulting container doesn't run as a daemon, it still requires
run.sh to "main loop" to keep container alive.

## Usage

- Install Docker
- Create container with `./build.sh`
- Run container with `docker run -it --rm -p 9001:9001 -p 1883:1883 -p 3000:3000 mqtt`. This opens an interactive shell and removes the container when disconnected. If you want to hack around and keep your work in the container for now, remove the `--rm` option.
- Run `./run.sh` within the container to start the mqtt service and other services.
- Run `./simulate.sh <name>` to play back a simulation. Call it with no arguments to get a list of options.

## Modifying recordings

Recordings can be modified (and created) using the dump and assemble tools in
the [dbus-recorder][1] repo.

[1]: https://github.com/victronenergy/dbus-recorder
