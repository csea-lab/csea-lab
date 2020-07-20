# Introduction
Follow these directions to get your very own snazzy copy of AFNI inside of a docker container on Windows! Email or slack me if you need help!

Created July 17, 2020  
Ben Velie, veliebm@ufl.edu

# Gathering Your Software
1) Update Windows to professional or education edition. Get a free education serial key by logging into [this website](https://azureforeducation.microsoft.com/devtools) with your UF account. You don't need to actually download the copy of Windows located on this website. Just get the serial key for Windows Education Edition, then replace your current Windows serial key with the new one. Windows will automatically upgrade itself. Don't worry, you won't lose any of your files or settings 🙂
2) [Download and install Docker.](https://docs.docker.com/docker-for-windows/install/)
3) [Download and install X Server for Windows.](https://sourceforge.net/projects/vcxsrv/files/latest/download)

# Starting AFNI with launch_afni_docker.ps1
1) Just launch the script from PowerShell! It'll automatically start X Server, Docker, and your AFNI container. Hopefully it saves you a bunch of time!

# Starting AFNI without launch_afni_docker.ps1
1) Start XLaunch. Just click next a bunch of times when it asks - the default settings are fine. Explanation: XLaunch enables our AFNI GUI in case we want to visualize datasets.
2) Launch Docker.
3) Enter the following command into PowerShell: "docker run --interactive --tty --rm --name afni --mount source=volume,destination=/volume -p 8888:8888 --env DISPLAY=host.docker.internal:0 afni/afni bash"
3) A shell should open up. This is a bash shell connected to your docker container.
4) If you want to make sure everything's working, type "afni" (without the quotes!) into the shell. The AFNI GUI should pop up with a beautiful brain for you to look at.
5) Celebrate your victory over esoteric neuroimaging software!

# Moving files into or out of your container
A docker container is self-contained. Also, you don't usually permanently change the files inside of it - most of the time they reset each time you start the container. This makes our AFNI container very safe and protects us from accidentally hurting our computer. But at some point you'll probably need to load external datasets into AFNI and permanently change them. To move data to and from your container, you should use something called a volume.

Volumes are magic storage boxes managed by Docker. When you mount a volume to a container, the container can access it like a regular folder. However, you CANNOT access a volume from your computer like a regular folder. To move files between your computer and a volume (or vice versa!), you MUST use Docker to do it. First, mount the volume to a container. Then, use the command "docker cp" to copy files into or out the volume's location inside the container. "docker cp" can also be used to copy files to and from other places in the container as well. You can basically think of a volume as a bridge. To get stuff from your computer into your container, copy the stuff into a volume and mount the volume to your container. To get stuff from your container into your computer, first put the files you want to move into your volume, then copy them out of the volume into your computer.

If you followed the directions I gave you about starting your AFNI container, you should have a volume named "volume" on your computer that mounts into the container at the path "/volume". Thus, to copy a file into "/volume" on the container, just type "docker cp path/to/file afni:/volume". Alternatively, to copy files out of the volume, type "docker cp afni:/volume path/on/your/computer". You can learn more about volumes [here](https://docs.docker.com/storage/volumes/) and "docker cp" [here](https://docs.docker.com/engine/reference/commandline/cp/)

You might have noticed that volumes are pretty annoying to navigate. I agree. There's another option to move files between your computer and a container called bind mounting. Bind mounting is one of the Dark Arts. In some ways bind mounts are easier to use, but Docker seems to be phasing out support for them. They're also buggy as heck. That being said, if you're anti-volume and want to access your files in a more convenient (but buggy!) way, [read more here.](https://docs.docker.com/storage/bind-mounts/)

Please reach out to me on slack or email if you'd like to learn more about any of this. I'm here anytime you need me 🙂