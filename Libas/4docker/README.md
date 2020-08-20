# Introduction

WIP!

This document teaches you how to get the software you need to use our Docker containers on your computer. Please install everything here before you try to use the docker projects located in our repository.

Please contact me on slack or email if you need help. I'm here anytime you need me 🙂

Created July 20, 2020  
Ben Velie  
veliebm@ufl.edu

# Windows

Most people have Windows 10 Home Edition. Unfortunately, the version of Docker we use can't run on Home Edition. Instead, you need Windows Professional Edition or Education Edition. Luckily, Microsoft provides Windows Education Edition for free to UF students. I'll show you how to get it. Don't worry, Education Edition is strictly better than Home Edition. Also, you won't lose any of your files or settings, and you won't lose access to Windows after you're no longer a student.

Upgrading Windows was the hard part. It's easy to install the other software you'll need. First you'll download and install Docker, then you'll download and install X Server for Windows. X Server allows us to have GUI's for applications running in Docker containers. You'll need it if you want to use AFNI's snazzy neuroimaging viewer.

*In summary, to use Docker you must (A) upgrade to Windows 10 Education Edition, (B) install Docker, and (C) install X Server.*

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

### Installing X Server.

1) [Go to this website.](https://sourceforge.net/projects/vcxsrv/files/latest/download) 
2) Your download should start automatically.
3) Install with default settings.

# Mac

It's way easier to use OS X for this stuff. All you need to do is install Docker and install XQuartz. XQuartz lets you use a GUI within your containers.

1) [Install Docker.](
https://docs.docker.com/docker-for-mac/install/)
2) [Install XQuartz.](https://www.xquartz.org/)

# More help

- (ANY OS) If you only have 8 GB of RAM on your computer, you might need to buy more RAM to use Docker. Yeah, I know it's annoying. Not everyone has to get more RAM, but I did.
- (ANY OS) Docker generally has good documentation. You should Google Docker commands when you want to learn what they do.
- (WINDOWS) If you don't know how to use PowerShell, you need to learn. It's the bees knees! You must know basic shell scripting if you want to use Docker. I used [this website](https://learnpythonthehardway.org/python3/appendixa.html) to learn the fundamentals.
