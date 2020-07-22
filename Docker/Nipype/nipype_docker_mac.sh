#! /usr/bin/env bash

# Image to run inside the container.
image="nipype/nipype"
# Name of the container.
name="nipype"
# Directory to mount to the container.
source="/Volumes/volume"
# Sets the location of the mounted directory inside the container.
destination="/volume"
# If you set $user = "root", then you'll login with root access.
user="neuro"
# Sets the working directory within the container.
workdir="/volume"
# Sets the port the container runs on.
p="8888:8888"


docker run --interactive --tty --rm --user $user --name $name --workdir $workdir --volume $mount -p $p $image bash