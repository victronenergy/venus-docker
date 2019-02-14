# Update submodules to HEAD one level deep
git submodule update --init --remote

# For each submodule, update nested submodules (not to HEAD).
git submodule foreach 'git submodule update --init'

# Update and build html5 app
git submodule update --init --remote venus-html5-app
cd venus-html5-app/
npm install
npm run compile
cd ..

docker build . -t mqtt
