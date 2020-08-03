<#
.SYNOPSIS
Launches AFNI within a Docker container.
.DESCRIPTION
First, this program launches X Server and Docker if they aren't running. Then, it launches AFNI within a Docker container.
Contact me via email or Slack if you need help. I'm here whenever you need me 🙂
Created July 17, 2020
Ben Velie
veliebm@ufl.edu
.LINK
Check out our repository!
https://github.com/csea-lab/csea-lab/
#>

#region Parameters 
Param(
    # Image to run inside the container.
    [String]
    $image = "afni/afni",

    # Name of the container.
    [String]
    $name = "afni",

    # Writeable directory to mount to the container.
    [CmdletBinding(PositionalBinding=$False)]
    [String]
    $write_source = "/c/Volumes/volume",

    # Sets the location of the writeable directory within the container.
    [CmdletBinding(PositionalBinding=$False)]
    [String]
    $write_destination = "/write_host",

    # Read-only directory to mount to the container.
    [CmdletBinding(PositionalBinding=$False)]
    [String]
    $read_source = "/c/users/$env:UserName",

    # Sets the location of the read-only directory within the container.
    [CmdletBinding(PositionalBinding=$False)]
    [String]
    $read_destination = "/read_host/",

    # Sets the working directory within the container.
    [CmdletBinding(PositionalBinding=$False)]
    [String]
    $workdir = "/write_host",

    # Sets the port the container runs on.
    [CmdletBinding(PositionalBinding=$False)]
    [String]
    $p = "8889:8889"
)
#endregion

#region Test-Process()
function Test-Process{
    <#
    .DESCRIPTION
    Returns true if $process is running.
    #>
    Param($process)
    return Get-Process $process -ErrorAction SilentlyContinue
}
#endregion

#region Test-Docker()
function Test-Docker{
    <#
    .DESCRIPTION
    Returns true if Docker is running.
    .NOTES
    We use this function instead of Test-Process because Test-Process doesn't work well for Docker.
    #>
    docker ps 2>&1 | Out-Null
    return $?
}
#endregion

#region Open-XServer()
function Open-XServer {
    <#
    .DESCRIPTION
    Launches X Server if it isn't running.
    #>
    if (!(Test-Process vcxsrv)) {
        C:\"Program Files"\VcXsrv\vcxsrv.exe :0 -multiwindow -clipboard -wgl
        Write-Output "Starting X Server"
    }
}
#endregion

#region Open-Docker()
function Open-Docker() {
    <#
    .DESCRIPTION
    Opens Docker if it's not already running.
    #>
    if (!(Test-Docker)) {
        Write-Output "Starting Docker"
        Start-Process 'C:/Program Files/Docker/Docker/Docker Desktop.exe'
    }
    while (!(Test-Docker)) {
        Start-Sleep 5
    }
    Write-Output "Docker is running"
}
#endregion

#region Launch Docker and XServer
Open-XServer
Open-Docker
#endregion

#region Set mount locations
Write-Output "From within your container, you can READ anything in $read_source by navigating to $read_destination"
$read_mount = $read_source + ":" + $read_destination + ":ro"
Write-Output "From within your container, you can read OR write anything in $write_source by navigating to $write_destination"
$write_mount = $write_source + ":" + $write_destination
#endregion

#region Launch the container
docker run --interactive --tty --rm --name $name --volume $write_mount --volume $read_mount --workdir $workdir -p $p --env DISPLAY=host.docker.internal:0 $image bash
#endregion