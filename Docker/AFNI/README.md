# Introduction
Follow these instructions to get a slick copy of AFNI inside a Docker container! Note: You must install some things before you begin. You can learn what to install by reading the README in the Docker directory.

Please contact me on Slack or email if you need help. I'm here anytime you need me 🙂

Created July 17, 2020  
Ben Velie  
veliebm@ufl.edu

# Windows

### Starting AFNI with afni_docker_windows.ps1
1) Just launch the script from PowerShell! It'll automatically start X Server, Docker, and your AFNI container. Hopefully it saves you a bunch of time!

### Starting AFNI without afni_docker_windows.ps1
1) Start XLaunch. Just click next a bunch of times when it asks - the default settings are fine. Explanation: XLaunch starts something called an X Server, which lets us access the AFNI GUI in case we want to visualize datasets.
2) Launch Docker.
3) Enter the following command into PowerShell: "docker run --interactive --tty --rm --name afni --mount source=volume,destination=/volume -p 8888:8888 --env DISPLAY=host.docker.internal:0 afni/afni bash"
3) Your powershell session should become a bash shell. This bash shell is connected to your docker container.
4) If you want to make sure everything's working, type "afni" (without the quotes!) into the shell. The AFNI GUI should pop up with a beautiful brain for you to look at.
5) Celebrate your victory over esoteric neuroimaging software!

# Mac

[TODO]

# Moving files into or out of your container
A docker container is self-contained. You also don't usually permanently change the files inside of it - they usually reset whenever you start the container. This makes our AFNI container very safe and protects us from accidentally hurting our computer. But eventually you'll probably need to load external datasets into AFNI and permanently change them. To move data to and from your container, you'll use a snazzy little thing called a bind mount.

When you bind mount a folder on your computer to a container, the container is able to access that folder. The folder basically becomes a bridge between your computer and the container. If you want to slurp files out of the container, move them from the container to the folder. If you want to get files into your container, move them from your computer to the folder. Bind mounts are very convenient.

If you followed the directions I gave you about starting your AFNI container, you should have a folder at "/c/Volumes/volume" on your computer that bind mounts into the container at the path "/volume". Thus you can access anything you plop into "/c/Volumes/volume" from within your container by navigating to "/volume". This is how you move files between your AFNI setup and your computer.

But you have other options besides bind mounts. You can also move files between your computer and container using something called a volume. Volumes are Dark Majick. Docker prefers that you use them, but they're *really hecking hard to use*. That being said, if you're curious or you're having trouble with bind mounts, [read more here about volumes here.](https://docs.docker.com/storage/bind-mounts/)
