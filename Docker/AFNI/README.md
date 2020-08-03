# Introduction
Follow these instructions to get a slick copy of AFNI inside a Docker container! Note: You must install some things before you begin. You can learn what to install by reading the directions in "csea-lab/Docker/README.md".

Please contact me on Slack or email if you need help. I'm here anytime you need me 🙂

Created July 17, 2020  
Ben Velie  
veliebm@ufl.edu

# Windows
1) Just launch "afni_docker_windows.ps1" from PowerShell! (It'll automatically start XServer, Docker, and your AFNI container.)
2) Your powershell session should become a bash shell. This bash shell is connected to your docker container. You can now access AFNI.

# Mac
WIP. I can't guarantee this will work.
1) Start XQuartz.
2) Start Docker.
3) Launch "afni_docker_mac.sh" from a bash shell.
4) Your shell should transform into a new bash shell connected to your docker container. You can now access AFNI.

# Enabling the GUI

Dont use the GUI while you're processing images. Unfortunately, enabling the GUI *might* make AFNI buggy. I've disabled the GUI by default. To enable it and view some beautiful brain images, on Windows you can launch "./afni_docker_windows.ps1" with the flag "-enableGUI". Try it and see! Just navigate in PowerShell to the folder the .ps1 script is in, then type "./afni_docker_windows.ps1 -enableGUI". When your container opens, you can launch the viewer by typing "afni".

On Mac, you need to manually edit $enableGUI inside "afni_docker_mac.sh". Set it to True. I know this is a hassle. I'm sorry.

# Moving files into or out of your container
A docker container is self-contained. You also don't usually permanently change the files inside of it - they usually reset whenever you start the container. This makes our AFNI container very safe and protects us from accidentally hurting our computer. But eventually you'll probably need to load external datasets into AFNI and permanently change them. To move data to and from your container, you'll use a snazzy little thing called a bind mount.

When you bind mount a folder on your computer to a container, the container is able to access that folder. The folder basically becomes a bridge between your computer and the container. If you want to slurp files out of the container, move them from the container to the folder. If you want to get files into your container, move them from your computer to the folder. Bind mounts are very convenient.

If you followed the directions I gave you about starting your AFNI container, you should have a folder at "/c/Volumes/volume/" (WINDOWS) or "/Volumes/volume/" (MAC) on your computer that bind mounts into the container at the path "/write_host/". Thus you can access anything you plop into "/c/Volumes/volume/" (WINDOWS) or "/Volumes/volume/" (MAC) from within your container by navigating to "/write_host/". This is the ONLY folder on your computer your AFNI container can edit by default.

However! Your AFNI container also bind mounts your computer's home directory in read-only mode. (Wow!) For example, my home directory is "/c/Users/Ben/", so my container can read any file or subfolder in "/c/users/Ben/". Your home directory is the directory labelled with your username that typically contains folders like "Desktop" or "Documents". To access your home directory from within your container, navigate to "/read_host/".

But you have other options besides bind mounts. You can also move files between your computer and container using something called a volume. Volumes are Dark Majick. Docker prefers that you use them, but they're *really hecking hard to use*. That being said, if you're curious or you're having trouble with bind mounts, [read more here about volumes here.](https://docs.docker.com/storage/volumes/)
