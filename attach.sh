#!/usr/bin/env bash

# Check that file containing the image name exists.
if ! [ -f image_name.txt ]; then
  echo "Could not find image_name.txt."
  exit 1
fi

image=$(cat image_name.txt)
container=$(docker ps --filter ancestor=$image --latest --quiet)

# Attach to the container.
docker exec -it $container $SHELL
