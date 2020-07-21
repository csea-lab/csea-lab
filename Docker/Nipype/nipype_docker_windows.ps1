# This program must be run from the command line.
# This program launches nipype as a docker image. It also mounts into the container the directory "/c/Volumes/volume".
# I began writing this on July 19, 2020. Please feel free to ask me any questions 🙂
# Ben Velie, veliebm@gmail.com
#-----------------------------------------------------------------------------------------------------------#

#region Parameters 
Param(
    # Image to run inside the container.
    [String]
    $image = "nipype/nipype",

    # Directory to mount to the container.
    [CmdletBinding(PositionalBinding=$False)]
    [String]
    $source = "/c/Volumes/volume",

    # Sets the location of the mounted directory inside the container.
    [CmdletBinding(PositionalBinding=$False)]
    [String]
    $destination = "/volume",

    # If you set $user = "root", then you'll login with root access.
    [CmdletBinding(PositionalBinding=$False)]
    [String]
    $user = "neuro"
)
#endregion

#region Test-Process
function Test-Process {
    Param(
        [String]
        $process
    )
    Get-Process $process -ErrorAction SilentlyContinue
}
#endregion

#region Start X Server if it isn't running
if (!(Test-Process vcxsrv)) {
    C:\"Program Files"\VcXsrv\vcxsrv.exe :0 -multiwindow -clipboard -wgl
    Write-Output "Starting X Server"
}
#endregion

#region Start Docker if it isn't running
# You must run Docker as an administrator on Windows. If you don't, then you won't be able to connect to Jupyter Notebook.
# docker ps throws an error if Docker isn't running. 2>&1 | Out-Null hides the error message.
docker ps 2>&1 | Out-Null
# $? returns false if the previous command threw an error.
$docker_running = $?
if (!$docker_running) {
    Write-Output "Starting Docker as an administrator"
    Start-Process 'C:/Program Files/Docker/Docker/Docker Desktop.exe' -Verb runAs
}
while (!$docker_running) {
    Start-Sleep 5
    docker ps 2>&1 | Out-Null
    $docker_running = $?
}
Write-Output "Docker is running"
#endregion

#region Set mount location
Write-Output "Mounting the directory '$source'"
$mount = $source + ":" + $destination
Write-Output "You can access that directory from inside your container by navigating to '$destination'"
#endregion

#region Launch container
docker run --interactive --tty --rm --user $user --name nipype --volume $mount -p 8888:8888 --env DISPLAY=host.docker.internal:0 $image bash
#endregion