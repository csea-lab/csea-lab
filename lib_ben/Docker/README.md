# Introduction

This document teaches you how to easily use Docker containers on your computer.

Please contact me on slack (preferably) or via email if you need help. I'm here anytime you need me 🙂

Created July 20, 2020  
Ben Velie  
veliebm@gmail.com


# Using Docker on Windows

Most people have Windows 10 Home Edition. Unfortunately, the version of Docker we use can't run on Home Edition. Instead, you need Windows Professional Edition or Education Edition. Luckily, Microsoft provides Windows Education Edition for free to UF students. I'll show you how to get it. Don't worry, Education Edition is strictly better than Home Edition. Also, you won't lose any of your files or settings, and you won't lose access to Windows after you're no longer a student.

Upgrading Windows was the hard part. It's easy to install the other software you'll need. First you'll install Docker, then you'll install Anaconda, then you'll install X Server. Anaconda is a bundle of Python and Python-related things. You need Python to start the script I'll provide you that launches Docker easily. Of course, if you wanna skip that step, you can always use Docker the old-fashioned way. It'll just be less convenient. X Server is a program that can allow you to view graphical interfaces for programs inside your containers. You'll want it if you plan on using the AFNI container to view neuroimaging files.

*In summary, please (A) upgrade to Windows 10 Education Edition (IF you don't have Windows 10 Professional Edition), (B) install Docker, (C) install Anaconda (IF you don't already have Python), and (D) install X Server (IF you want to use a GUI for certain programs).

### Upgrading Windows 10 Home Edition to Windows 10 Education Edition.

1) [Go to this website.](https://azureforeducation.microsoft.com/devtools)
2) Click "Sign in".
3) Login with your UF account.
4) Click "Download Software".
5) Search for "Windows 10 Education, Version 1809 (Updated Sept 2018)"
6) Click "Windows 10 Education, Version 1809 (Updated Sept 2018)". Do NOT click "Windows 10 Education N, Version 1809 (Updated Sept 2018)". That's the European version!
7) Click "View Key".
8) Copy the product key it gives you. Note that we are NOT downloading Education Edition from this website. We only need the product key!
9) Press the following keys on your keyboard at the same time: "Windows S"
10) Type in "Activation Settings".
11) Open "Activation Settings".
12) Click "Change product key".
13) Paste in the product key we got earlier.
14) Windows will now download and upgrade itself to education edition for you. How convenient!

### Installing Docker.

1) [Go to this website.](https://docs.docker.com/docker-for-windows/install/)
2) Click "Download from Docker Hub".
3) Click "Get Stable".
4) Install with default settings.

### Installing Anaconda.
1) [Go to this website.](https://www.anaconda.com/products/individual)
2) Download the Windows installer. Choose 32 bit or 64 bit depending on your computer.
3) Install with default settings except for one thing - make sure to check the box to add Anaconda stuff to your PATH variable.

### Installing X Server.

1) [Go to this website.](https://sourceforge.net/projects/vcxsrv/files/latest/download) 
2) Your download should start automatically.
3) Install with default settings.

# Using Docker on MacOS
TODO

# Running AFNI

So you want to run AFNI in a slick container, eh? Easy! Just launch [docker.py](docker.py) using Python! It'll generate a config file for you pre-configured to launch the container with desirable settings. Feel free to edit the config to your heart's content. Notice that the display is disabled by default in the config. If you'd like to use the GUI, you must first install an X Server. (See directions above.) Also, because of some quirks with Docker, enabling the GUI might cause some bugs for you with AFNI. *Might*. Keep an eye out for them if you continue down this path.

# More help

- (ANY OS) If you only have 8 GB of RAM on your computer, you might need to buy more RAM to use Docker. Yeah, I know it's annoying. Not everyone has to get more RAM, but I did.
- (ANY OS) Docker generally has good documentation. You should Google Docker commands when you want to learn what they do.
- (WINDOWS) If you don't know how to use PowerShell, you need to learn. It's the bees knees! You must know basic shell scripting if you want to use Docker. I used [this website](https://learnpythonthehardway.org/python3/appendixa.html) to learn the fundamentals.
