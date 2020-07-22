#! /usr/bin/env bash

source nipype_docker_mac_config.txt

docker run --interactive --tty --rm --user $user --name $name --workdir $workdir --volume $mount -p $p $image bash