# Introduction
Follow these directions to get your very own snazzy copy of AFNI inside of a docker container on Windows! Email me if you need help!

Created July 17, 2020  
Ben Velie, veliebm@ufl.edu

# Gathering Your Software
1) Update Windows to professional or education edition. Get a free education serial key from here by logging in with your UF account:
https://azureforeducation.microsoft.com/devtools You don't need to install the copy of Windows located on this website. Get the serial key, then replace your current Windows serial key with the new one. Windows will automatically upgrade itself. Don't worry, you won't lose any of your files or settings 🙂
2) Download and install Docker. See: https://docs.docker.com/docker-for-windows/install/
3) Download and install X Server for Windows.
https://sourceforge.net/projects/vcxsrv/files/latest/download

# Starting AFNI
On Windows, ALWAYS start Docker as an administrator. Otherwise, you won't be able to connect to your container. launch_afni_docker.ps1 will automatically start docker as an administrator if it's not already running. Then it'll launch your AFNI container with the right settings. Here's how you use it:
1) Start XLaunch. Just click next a bunch of times when it asks - the default settings are fine. Explanation: XLaunch enables our AFNI GUI in case we want to visualize datasets.
2) Launch launch_afni_docker.ps1. If Windows asks you for administrator permission, say yes. Currently the script must be run from the command line to work. I want to fix that soon though!
3) A shell should open up. This is a bash shell connected to your docker container.
4) If you want to make sure it's working, you can type "afni" (without the quotes!) into the shell. The AFNI GUI should pop up.
5) Celebrate your glorious victory over esoteric neuroimaging software!

# Some Notes
A docker container is self-contained. Also, you can't permanently change the files inside of it - they reset each time you start the container. This makes our AFNI container very safe and protects us from accidentally hurting our computer. But at some point you'll probably need to load external datasets into AFNI and permanently change them. Luckily for you, our container mounts the folder "volume" as permanent storage. "volume" is the ONLY part of your computer AFNI will have access to and it's the ONLY folder you can permanently change from within the container. Use "volume" as a bridge between your computer and the container.