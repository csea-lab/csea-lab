#! /usr/bin/env bash

# Image to run inside the container.
image="afni/afni"
# Name of the container.
name="afni"
# Directory to mount to the container.
source="/Volumes/volume"
# Sets the location of the mounted directory inside the container.
destination="/volume"
# Sets the working directory within the container.
workdir="/volume"
# Sets the port the container runs on.
p="8889:8889"


docker run --interactive --tty --rm --name $name --volume $mount --workdir $workdir -p $p --env DISPLAY=host.docker.internal:0 $image bash