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

# since this script needs to be run with sudo, allow manual setting of these variables
DOCKER_USER=tablett
DOCKER_UID=1010
DOCKER_HOME=/home/tablett

docker build\
  --build-arg user=$DOCKER_USER\
  --build-arg uid=$DOCKER_UID\
  --build-arg home=$DOCKER_HOME\
  --build-arg workspace=$SCRIPTPATH\
  --build-arg shell=$SHELL\
  -t $(cat image_name.txt) .


# Build the docker image
# docker build\
#   --build-arg user=$USER\
#   --build-arg uid=$UID\
#   --build-arg home=$HOME\
#   --build-arg workspace=$SCRIPTPATH\
#   --build-arg shell=$SHELL\
#   -t $(cat image_name.txt) .
