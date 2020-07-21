<#
.SYNOPSIS
Launches nipype within a Docker container.
.DESCRIPTION
This program launches nipype within a Docker container. It also mounts into the container the directory "/c/Volumes/volume".
Contact me via email or Slack if you need help. I'm here whenever you need me :)
Created July 19, 2020
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
    Opens Docker as an administrator if it's not already running.
    You must open Docker as an administrator on Windows.
    If you don't, then you won't be able to connect to Jupyter Notebook.
    #>
    if (!(Test-Docker)) {
        Write-Output "Starting Docker as an administrator"
        Start-Process 'C:/Program Files/Docker/Docker/Docker Desktop.exe' -Verb runAs
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

#region Set mount location
Write-Output "Mounting the directory '$source'"
$mount = $source + ":" + $destination
Write-Output "You can access that directory from inside your container by navigating to '$destination'"
#endregion

#region Launch the container
docker run --interactive --tty --rm --user $user --name nipype --volume $mount -p 8888:8888 --env DISPLAY=host.docker.internal:0 $image bash
#endregion