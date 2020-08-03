#! /usr/bin/env bash

#Image to run inside the container.
image="afni/afni"
# Name of the container.
name="afni"
# Writeable directory to mount to the container.
write_source="/Volumes/volume/"
# Sets the location of the writeable directory within the container.
write_destination="/write_host/"
# Read-only directory to mount to the container.
read_source=$userprofile
# Sets the location of the read-only directory within the container.
read_destination="/read_host/"
# Sets the working directory within the container.
workdir="/write_host/"
# Sets the port the container runs on.
p="8889:8889"
# Sets whether the AFNI GUI is enabled.
enableGUI=False
# Sets the settings to make X Quartz work
GUI="DISPLAY=docker.for.mac.host.internal:0"

if [ $enableGUI = True ]
then
    echo "The GUI is enabled, which can make the container buggy"
    echo "Please run the container without the GUI unless you're using the AFNI viewer"
    docker run --interactive --tty --rm --name $name --volume $write_mount --volume $read_mount --workdir $workdir -p $p --env $GUI $image bash
else
    echo "The GUI is disabled"
    echo "To enable the GUI, launch this script with the flag -enableGUI"
    docker run --interactive --tty --rm --name $name --volume $write_mount --volume $read_mount --workdir $workdir -p $p $image bash
fi