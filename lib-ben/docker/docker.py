"""
Starts Docker, then starts the Docker image specified in config.json.

This process can be configured further by editing config.json.

Created 08/20 by Ben Velie.
veliebm@gmail.com

"""


import json
import subprocess
import os
import platform
import psutil
import pathlib
from copy import deepcopy
from time import sleep

CONFIG_NAME = "config.json"
ARGS_FLAG = "[arg]"
SPLIT_CHAR = "|"


def main():

    initialize_config_file()

    launch_xserver()

    launch_docker()

    launch_container()

# Functions to initialize the config file
def initialize_config_file():
    """
    Initialize the config file.

    """

    # If a config file exists, use it.
    try:
        with open(CONFIG_NAME, "r") as config_file:
            json.load(config_file)
        print(f"Loaded {CONFIG_NAME}")

    # If there's an error accessing the config file, then offer to make a new one.
    except:
        wants_config = input(f"Error accessing {CONFIG_NAME}. Create a fresh one? (y/n) ")
        if wants_config.lower() == "y":
            with open(CONFIG_NAME, 'w') as config_file:
                json.dump(OS_default_config(), config_file, indent="\t")
        else:
            raise Exception(f"You have chosen not to create a new {CONFIG_NAME}")
def OS_default_config():
    """
    Returns the default config dictionary for the current operating system.

    """

    home_directory = pathlib.Path(os.path.expanduser("~"))
    repository_directory = pathlib.Path().absolute().parent.parent

    default_config = {
        "Instructions": f"For each key containing {ARGS_FLAG}, its value will be appended to the command line in order. {SPLIT_CHAR} characters can be used to split one argument into as many as you'd like. Try adding your own! A full list of args is at https://docs.docker.com/engine/reference/commandline/run/",
        "path to docker": "C:/Program Files/Docker/Docker/Docker Desktop.exe",
        "path to x server": "C:/Program Files/VcXsrv/vcxsrv.exe",
        "name of x server process": "vcxsrv.exe",
        f"base docker command {ARGS_FLAG}": "docker|run",
        f"name the container {ARGS_FLAG}": "--name|nipype",
        f"make the container impermanent {ARGS_FLAG}": "--rm",
        f"make the container interactive {ARGS_FLAG}": "-it",
        f"mount home directory within container {ARGS_FLAG}": f"-v|{home_directory}:/readwrite/",
        f"mount repo into container {ARGS_FLAG}": f"-v|{repository_directory}:/csea-lab/",
        f"working directory inside container {ARGS_FLAG}": "-w=/csea-lab/",
        f"image to run {ARGS_FLAG}": "nipype/nipype",
        f"program to run within the container {ARGS_FLAG}": "bash",
    }

    windows_config = deepcopy(default_config)

    # Overwrite the default config with mac values.
    mac_overwrite = {
        "path to docker": "/Applications/Docker.app",
        "path to x server": "/Applications/Utilities/XQuartz.app",
        "name of x server process": "X11.bin",
        }
    mac_config = deepcopy(default_config)
    mac_config.update(mac_overwrite)

    # Overwrite the default config with linux values.
    linux_overwrite = {
        "path to docker": "",
        "path to x server": "",
        "name of x server process": "",
        }
    linux_config = deepcopy(default_config)
    linux_config.update(linux_overwrite)
    
    OS = get_OS()
    print(f"Using {OS} template for {CONFIG_NAME}")

    if OS == "Windows":
        return windows_config
    elif OS == "Mac":
        return mac_config
    elif OS == "Linux":
        return linux_config
    
# Functions to launch X Server
def launch_xserver():
    """
    Launch X Server if it isn't already running.
    
    """
    
    if not xserver_running():
        print("Starting X Server")
        while not xserver_running():
            start_xserver_process()
            sleep(2)

    if xserver_running():
        print("X Server is running")
def start_xserver_process():
    """
    Start whatever X Server you have on your OS.

    """

    xserver_path = read_config()["path to x server"]
    OS = get_OS()
    if OS == "Windows":
        subprocess.Popen([xserver_path, ":0", "-multiwindow", "-clipboard", "-wgl", "-ac"])
    elif OS == "Mac":
        subprocess.Popen(f"open -a {xserver_path}", shell=True)
    elif OS == "Linux":
        pass
def xserver_running():
    """
    Returns True if X Server is running.

    """

    xprocess = read_config()["name of x server process"]
    if xprocess in (process.name() for process in psutil.process_iter()):
        return True
    else:
        return False

# Functions to launch Docker
def launch_docker():
    """
    Launches Docker then waits until it's running.

    """

    if not docker_running():
        print("Starting Docker")
        while not docker_running():
            start_docker_process()
            sleep(2)
    print("Docker is running")
def start_docker_process():
    """
    Starts the Docker process.

    """

    docker_path = read_config()["path to docker"]
    OS = get_OS()
    if OS == "Windows":
        subprocess.Popen(docker_path)
    elif OS == "Mac":
        subprocess.Popen(f"open -a {docker_path}", shell=True)
    elif OS == "Linux":
        subprocess.Popen(docker_path)
def docker_running():
    """
    Returns true if docker is running.

    """

    process = subprocess.run(["docker", "ps"], capture_output=True)
    if process.returncode != 0:
        return False
    else:
        return True

# Functions to launch the container
def launch_container():
    """
    Launches the docker container.

    """

    docker_args = get_container_args()
    print("Executing the following command to launch the container:")
    print(docker_args)
    process = subprocess.Popen(docker_args)
    process.communicate()
def get_container_args():
    """
    Reads the config file and returns a list of arguments for the container.

    """

    config_dict = read_config()
    args_list = list()

    for key, value in config_dict.items():
        if ARGS_FLAG in key:
            next_args = value.split(SPLIT_CHAR)
            args_list += next_args

    return args_list

# Other functions
def get_OS():
    """
    Returns the operating system.

    """

    if "Windows" in platform.platform():
        return "Windows"
    elif "macOS" in platform.platform():
        return "Mac"
    else:
        return "Linux"
def read_config():
    """
    Returns the config file as a dictionary.

    """

    with open(CONFIG_NAME, "r") as config_file:
        return json.load(config_file)


if __name__ == "__main__":
    main()
