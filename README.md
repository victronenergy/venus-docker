# WIP dockerized dbus playback + mqtt service

Use this docker to run an mqtt broker that serves recorded dbus data. Main use case would be to run this instead of having a real Venus GX device or VenusOs running in a raspberry pi, making local development work much easier, but also more realistic. The goal is to have the container able to run different configurations (different sets of devices connected to it) of the VenusGX by running different sets of recordings with a simple commandline api.

Thus far the resulting container is large, has some funky dependencies which would be nice to clean up and maybe to even use alpine to reduce the container size abit. Also doesn't run as a daemon, still required run.sh to "main loop" to keep container alive.

## Usage

- Install Docker
- Create container with `./build.sh`
- Run container with `docker run -it --rm -p 9001:9001 -p 1883:1883 mqtt`. This opens an interactive shell and removes the container when disconnected. If you want to hack around and keep your work in the container for now, remove the `--rm` option.
- Run `./run.sh` within the container to start the mqtt service and the dbus recorder playback.
  * `run.sh` has a single parameter which defines the mosquitto keepAlive in seconds. Message publishing will stop after this many seconds. Default value is 60.

## Working inside the container

### Add / remove dbus channel messages from mqtt

If you want to test removing certain dbus messages you can do it by killing some playback services. Do it by finding the playback desired with `ps aux` and using kill on the process. To restart the service or to start a new one use `~/bin/run_recording.sh <filename>` where filename is the recording file name in the dbus-recorder directory. Note it's just the file name, not a path! The script is for convenience since it gets the dbus unix address before running the python script. You can also find the unix address in /tmp/dbus_session_address if you want to do things manually. For reference check run_recording.sh.
