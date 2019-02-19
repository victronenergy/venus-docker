# Update submodules to HEAD one level deep
git submodule update --init --remote

# For each submodule, update nested submodules (not to HEAD).
git submodule foreach 'git submodule update --init'

docker build . -t mqtt
