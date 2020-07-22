# Introduction
Follow these instructions to get a slick copy of AFNI inside a Docker container! Note: You must install some things before you begin. You can learn what to install by reading the directions in "csea-lab/Docker/README.md".

Please contact me on Slack or email if you need help. I'm here anytime you need me 🙂

Created July 17, 2020  
Ben Velie  
veliebm@ufl.edu

# Windows
1) Just launch "afni_docker_windows.ps1" from PowerShell! (It'll automatically start XServer, Docker, and your AFNI container.)
2) Your powershell session should become a bash shell. This bash shell is connected to your docker container.
3) If you want to make sure everything's working, type "afni" (without the quotes!) into the shell. The AFNI GUI should pop up with a beautiful brain for you to look at.

# Mac
WIP. I can't guarantee this will work.
1) Start XQuartz.
2) Start Docker.
3) Launch "afni_docker_mac.sh" from a bash shell.
4) Your shell should transform into a new bash shell connected to your docker container.
5) If you want to make sure everything's working, type "afni" (without the quotes!) into the new shell. The AFNI GUI should pop up with a beautiful brain for you to look at.

# Moving files into or out of your container
A docker container is self-contained. You also don't usually permanently change the files inside of it - they usually reset whenever you start the container. This makes our AFNI container very safe and protects us from accidentally hurting our computer. But eventually you'll probably need to load external datasets into AFNI and permanently change them. To move data to and from your container, you'll use a snazzy little thing called a bind mount.

When you bind mount a folder on your computer to a container, the container is able to access that folder. The folder basically becomes a bridge between your computer and the container. If you want to slurp files out of the container, move them from the container to the folder. If you want to get files into your container, move them from your computer to the folder. Bind mounts are very convenient.

If you followed the directions I gave you about starting your AFNI container, you should have a folder at "/c/Volumes/volume" (WINDOWS) or "/Volumes/volume" (MAC) on your computer that bind mounts into the container at the path "/volume". Thus you can access anything you plop into "/c/Volumes/volume" (WINDOWS) or "/Volumes/volume" (MAC) from within your container by navigating to "/volume". This is how you move files between your AFNI setup and your computer.

But you have other options besides bind mounts. You can also move files between your computer and container using something called a volume. Volumes are Dark Majick. Docker prefers that you use them, but they're *really hecking hard to use*. That being said, if you're curious or you're having trouble with bind mounts, [read more here about volumes here.](https://docs.docker.com/storage/bind-mounts/)
