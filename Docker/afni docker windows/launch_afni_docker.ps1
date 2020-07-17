# This program launches AFNI in a docker container. It also mounts into the container the directory "volume".
# start_docker_process.py must be in the same folder as this script.
# Also, if you want a GUI, don't forget to start XLaunch before you run this script!
# I began writing this on June 17, 2020. Please feel free to ask me any questions 🙂
# Ben Velie, veliebm@gmail.com
#-----------------------------------------------------------------------------------------------------------#


# These variables can be set from the command line when you launch the script,
# but they default to the values you see here.
Param(
    [String]
    $image = "afni/afni",

    # The directory you set as $source will be visible within the container under the directory you set as $destination.
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

# Because I used $PSScriptRoot/volume for $source, this program will mount the directory "volume"
# in the directory the script is located in.
$mount = $source + ":" + $destination
Write-Output "Mounting $source to $destination"

# Run the docker container! Yay!
docker run --interactive --tty --rm --volume $mount -p 8888:8888 --env DISPLAY=host.docker.internal:0 $image bash