#!/bin/bash

# Update submodules
git submodule update --init --recursive || exit

# Update all the submodules and its dependencies
git submodule foreach git pull --ff origin master --recurse-submodules || exit

# Build a new mqtt Docker image
docker build . -t mqtt --no-cache