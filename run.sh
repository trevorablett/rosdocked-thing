#!/usr/bin/env bash

# Check that file containing the image name exists.
if ! [ -f image_name.txt ]; then
  echo "Could not find image_name.txt."
  exit 1
fi

# Get this script's path
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

set -e

# Run the container with shared X11
docker run\
  --net=host\
  -e SHELL\
  -e DISPLAY\
  -e DOCKER=1\
  -e TERM\
  --device /dev/dri\
  -v "$HOME:$HOME:rw"\
  -v "/home/linuxbrew:/home/linuxbrew:ro"\
  -v "/tmp/.X11-unix:/tmp/.X11-unix:rw"\
  -it $(cat image_name.txt) $SHELL
