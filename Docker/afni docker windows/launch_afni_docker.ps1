# Currently this program must be run from the command line.
# This program launches AFNI as a docker image. It also mounts into the container the directory "volume".
# Remember to place start_docker_process.py in the same folder.
# Also, remember to start XLaunch if you want to use AFNI's GUI.
# I began writing this on July 17, 2020. Please feel free to ask me any questions 🙂
# Ben Velie, veliebm@gmail.com
#-----------------------------------------------------------------------------------------------------------#

# Each of these parameters can be set from the command line, but they default to the values here.
Param(
    [String]
    $image = "afni/afni",

    [CmdletBinding(PositionalBinding=$False)]
    [String]
    $source = "$PSScriptRoot/volume",

    [CmdletBinding(PositionalBinding=$False)]
    [String]
    $destination = "/volume"
)


# start_docker_process.py launches docker as an administrator if it isn't already running. You must run docker
# as an administrator on Windows. If you don't, then you won't be able to connect to the server.
python ./start_docker_process.py

# Launch the server. The directory you set as $source will be visible within the container under the directory you
# set as $destination. Because I used $PSScriptRoot/volume for $source, this program will mount the directory "volume"
# in the directory it is located in.
$mount = $source + ":" + $destination
Write-Output "Mounting $source to $destination"

docker run --interactive --tty --rm --volume $mount -p 8888:8888 --env DISPLAY=host.docker.internal:0 $image bash