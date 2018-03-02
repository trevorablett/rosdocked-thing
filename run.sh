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
# --privileged and -v /dev/bus/usb:/dev/bus/usb are meant to give access to USB
# devices. See
# https://stackoverflow.com/questions/24225647/docker-any-way-to-give-access-to-host-usb-or-serial-device
docker run\
  --net=host\
  -e SHELL\
  -e DISPLAY\
  -e DOCKER=1\
  -e TERM\
  --privileged\
  --device /dev/dri\
  -v "/dev/bus/usb:/dev/bus/usb"\
  -v "$HOME:$HOME:rw"\
  -v "/home/linuxbrew:/home/linuxbrew:ro"\
  -v "/tmp/.X11-unix:/tmp/.X11-unix:rw"\
  -it $(cat image_name.txt) $SHELL
