# Hubot
The hubot bot for slack

## Requirements
To run hubot, you'll need Node installed or run it within docker.

### Run with node manually
Make sure node is >v11.0.0

1. Install the modules with `npm install`
1. Add the following to your PATH variable: `$(pwd)/node_modules/.bin/`
1. Run hubot: `hubot`

### Run with Docker
With Docker, make sure you have the latest Docker installed and build the image first. By default the container tries to use the slack adapter. For running the hubot shell, disable the adapter with `-l hubot`. 

1. Build the image: `docker build -t hubot .`
1. Run the container with `docker run -it --rm -v $(pwd)/scripts:/home/node/scripts hubot -l hubot`
