<#
.SYNOPSIS
Launches AFNI within a Docker container.
.DESCRIPTION
This program launches AFNI within a Docker container. It also mounts into the container the directory "/c/Volumes/volume".
Contact me via email or Slack if you need help. I'm here whenever you need me :)
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

    # Directory to mount to the container.
    [CmdletBinding(PositionalBinding=$False)]
    [String]
    $source = "/c/Volumes/volume",

    # Sets the location of the mounted directory inside the container.
    [CmdletBinding(PositionalBinding=$False)]
    [String]
    $destination = "/volume",

    # Sets the working directory within the container.
    [CmdletBinding(PositionalBinding=$False)]
    [String]
    $workdir = "/volume",

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

#region Launch Docker
Open-Docker
#endregion

#region Set mount location
Write-Output "Mounting the directory '$source'"
$mount = $source + ":" + $destination
Write-Output "You can access that directory from inside your container by navigating to '$destination'"
#endregion

#region Launch the container
docker run --interactive --tty --rm --name $name --volume $mount --workdir $workdir -p $p $image bash
#endregion