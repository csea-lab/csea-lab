"""
Starts Docker, then starts the Docker image specified in config.ini.

This process can be configured further by editing config.ini.

Created 08/20 by Ben Velie.
veliebm@gmail.com
"""

import configparser
import subprocess
import os
import platform
import psutil
import pathlib
from copy import deepcopy
from time import sleep


CONFIG_NAME = "config.ini"

def main():

    initialize_config_file()

    launch_xserver()

    launch_docker()

    launch_container()

# Functions to initialize the config file
def initialize_config_file():
    """
    Initialize a config file.
    """
    config = configparser.ConfigParser()

    # Get default config.
    config.read_dict(OS_default_config())

    # Overwrite default config with config file.
    config.read(CONFIG_NAME)

    # Save our changes to the config file.
    with open(CONFIG_NAME, 'w') as config_file:
        config.write(config_file)
def OS_default_config():
    """
    Returns the default config dictionary for the current operating system.
    """

    home_directory = os.getenv('USERPROFILE')
    repository_directory = pathlib.Path().absolute().parent.parent

    default_config = {
        "DEFAULT": {
            "image": "afni/afni",
            "name": "afni",
            "program to run inside container": "bash",
            "port": "8888:8888",
            "read/write directory": f"{home_directory}/Files/Development/Docker",
            "where to mount read/write directory inside container": "/readwrite/",
            "read-only directory": "C:/",
            "where to mount read-only directory inside container": "/readonly/",
            "working directory inside container": "/readwrite/",
            "path to repository": str(repository_directory),
            "path to docker": "C:/Program Files/Docker/Docker/Docker Desktop.exe",
            "path to x server": "C:/Program Files/VcXsrv/vcxsrv.exe",
            "name of x server process": "vcxsrv.exe",
            "display": "DISPLAY=host.docker.internal:0",
            }
        }

    windows_config = deepcopy(default_config)

    # Overwrite the default config with mac values.
    mac_overwrite = { "read/write directory": "$HOME/Docker",
        "read-only directory": "/",
        "path to docker": "/Applications/Docker.app",
        "path to x server": "/Applications/Utilities/XQuartz.app",
        "name of x server process": "X11.bin",
        "display": "DISPLAY=$DISPLAY"
        }
    mac_config = deepcopy(default_config)
    mac_config["DEFAULT"].update(mac_overwrite)

    # Overwrite the default config with linux values.
    linux_overwrite = { "read/write directory": "$HOME/Docker",
        "read-only directory": "/",
        "path to docker": "",
        "path to x server": "",
        "name of x server process": "",
        "display": "DISPLAY=$DISPLAY"
        }
    linux_config = deepcopy(default_config)
    linux_config["DEFAULT"].update(linux_overwrite)
    
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

    args_list = ["docker",
                 "run",
                 "--interactive", # Allow interaction with the container.
                 "--tty", # Connect the local shell to the container.
                 "--rm", # Remove the container when it's closed.
                 "--name", # Set the name of the container.
                 config_dict["name"],
                 "--volume", # Set the directory to read/write to.
                 config_dict["read/write directory"] + ":" + config_dict["where to mount read/write directory inside container"],
                 "--volume", # Set the directory to read from.
                 config_dict["read-only directory"] + ":" + config_dict["where to mount read-only directory inside container"] + ":ro",
                 "--volume", # Mount the csea-lab repository.
                 config_dict["path to repository"] + ":" + "/csea-lab/",
                 "--workdir", # Set the working directory in the container.
                 config_dict["working directory inside container"],
                 "-p", # Set the port.
                 config_dict["port"],
                 ]

    args_list.append(config_dict["image"]) # Set the image to run within the container.
    args_list.append(config_dict["program to run inside container"]) # Set the program to run within the container.

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
    config = configparser.ConfigParser()
    config.read(CONFIG_NAME)
    return {key: config["DEFAULT"][key] for key in config["DEFAULT"]}

if __name__ == "__main__":
    main()
