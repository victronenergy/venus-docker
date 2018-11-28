# WIP dockerized dbus playback + mqtt service

Use this docker to run an mqtt broker that serves recorded dbus data. Thus far the resulting container is large, has some funky dependencies which would be nice to clean up and maybe to even use alpine to reduce the container size abit. Also doesn't run as a daemon, still required run.sh to "main loop" to keep container alive.

## Usage

- Create container with `docker build . -t mqtt`
- Run container with `docker run -it --rm -p 9001:9001 mqtt`. This opens an interactive shell and removes the container when disconnected. If you want to hack around and keep your work in the container for now, remove the `--rm` option.
- Run `./run.sh` within the container to start the mqtt service and the dbus recorder playback.
