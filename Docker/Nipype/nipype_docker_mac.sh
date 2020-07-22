#! /usr/bin/env bash

source config_nipype_docker_mac.sh

docker run --interactive --tty --rm --user $user --name $name --workdir $workdir --volume $mount -p $p $image bash