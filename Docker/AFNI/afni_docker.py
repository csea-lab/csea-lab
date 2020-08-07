import configparser
import subprocess
import os
import platform
from time import sleep


CONFIG_NAME = "config.ini"

DOCKER_PATH_WINDOWS = "C:/Program Files/Docker/Docker/Docker Desktop.exe"
DOCKER_PATH_MAC = ""
DOCKER_PATH_LINUX = ""

XSERVER_PATH_WINDOWS = "C:/Program Files/VcXsrv/vcxsrv.exe"
XSERVER_PATH_MAC = ""
XSERVER_PATH_MAC = ""


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
    # If a config file doesn't exist, make one.
    if not os.path.exists(CONFIG_NAME):
        with open(CONFIG_NAME, "w") as config_file:
            pass

    # Read the config file.
    config = configparser.ConfigParser()
    config.read(CONFIG_NAME)

    # If any config values aren't already set, set them.
    fill_in_config(config)

    # Save our changes to the config file.
    with open('config.ini', 'w') as config_file:
        config.write(config_file)
def fill_in_config(config_obj):
    """
    Fills missing values in our config object.
    """
    default_config_dict = get_OS_config_dict()
    for key, value in default_config_dict.items():
        set_if_empty(config_obj, key, value)
def get_OS_config_dict():
    """
    Returns the config dictionary for the current operating system.
    """
    windows_config_dict = {"image": "afni/afni",
                           "name": "afni",
                           "host directory to read OR write to": "/c/Volumes/volume/",
                           "read/write directory in container": "/write_host/",
                           "host directory to read from": "/c/",
                           "read directory in container": "/read_host/",
                           "working directory": "/write_host/",
                           "port": "8889",
                           "display": "DISPLAY=host.docker.internal:0",
                           "enable display": "False"}

    mac_config_dict = {"image": "afni/afni",
                       "name": "afni",
                       "host directory to read OR write to": "/",
                       "read/write directory in container": "/write_host/",
                       "host directory to read from": "/",
                       "read directory in container": "/read_host/",
                       "working directory": "/write_host/",
                       "port": "8889",
                       "display": "",
                       "enable display": "False"}

    linux_config_dict = {"image": "afni/afni",
                         "name": "afni",
                         "host directory to read OR write to": "/",
                         "read/write directory in container": "/write_host/",
                         "host directory to read from": "/",
                         "read directory in container": "/read_host/",
                         "working directory": "/write_host/",
                         "port": "8889",
                         "display": "",
                         "enable display": "False"}

    if "Windows" in platform.platform():
        return windows_config_dict
    elif "Mac" in platform.platform():
        return mac_config_dict
    else:
        return linux_config_dict
def set_if_empty(config_obj, option: str, value: str, section="DEFAULT"):
    """
    Sets an option to the specified value if it doesn't exist.

    Can optionally specify the section of the configparser to search.
    """
    if config_obj.has_option(section, option):
        return
    else:
        config_obj.set(section, option, value)

# Functions to launch X Server
def launch_xserver():
    """
    Launch X Server if it isn't already running.
    """
    print(xserver_running())
def xserver_running():
    """
    Returns True if X Server is running.
    """
    OS = get_OS()
    if OS == "Windows":
        if XSERVER_PATH_WINDOWS in (process.name() for process in psutil.process_iter()):
            return True
    elif OS == "Mac":
        pass
    elif OS == "Linux":
        pass
    return False
def start_xserver_process():
    """
    Start whatever X Server you have on your OS.
    """
    OS = get_OS()
    if OS == "Windows":
        subprocess.Popen([XSERVER_PATH_WINDOWS, ":0", "-multiwindow", "-clipboard", "-wgl"])
    elif OS == "Mac":
        pass
    elif OS == "Linux":
        pass

# Functions to launch Docker
def launch_docker():
    """
    Launches Docker then waits until it's running.
    """
    if not docker_running():
        print("Starting Docker")
        while not docker_running():
            start_docker_process()
            sleep(5)
    print("Docker is running")
def start_docker_process():
    """
    Starts the Docker process.
    """
    OS = get_OS()
    if OS == "Windows":
        subprocess.Popen(DOCKER_PATH_WINDOWS)
    #TODO
    elif OS == "Mac":
        pass
    #TODO
    elif OS == "Linux":
        pass
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
    docker_args = get_docker_args()
    print("Executing the following command:")
    print(docker_args)
    process = subprocess.Popen(docker_args)
    process.communicate()
def get_container_args():
    """
    Reads the config file and returns a list of arguments for the container.
    """
    config = configparser.ConfigParser()
    config.read(CONFIG_NAME)

    args_list = ["docker",
                 "run",
                 "--interactive",
                 "--tty",
                 "--rm",
                 "--name",
                 config["DEFAULT"]["name"],
                 "--volume",
                 config["DEFAULT"]["host directory to read or write to"] +
                 ":" + config["DEFAULT"]["read/write directory in container"],
                 "--volume",
                 config["DEFAULT"]["host directory to read from"] + ":" +
                 config["DEFAULT"]["read directory in container"] + ":ro",
                 "--workdir",
                 config["DEFAULT"]["working directory"],
                 "-p",
                 config["DEFAULT"]["port"],
                 ]

    if config.getboolean("DEFAULT", "enable display") == True:
        args_list.append("--env")
        args_list.append(config["DEFAULT"]["display"])

    args_list.append(config["DEFAULT"]["image"])
    args_list.append("bash")

    return args_list

# Other functions
def get_OS():
    """
    Returns the operating system.
    """
    if "Windows" in platform.platform():
        return "Windows"
    elif "Mac" in platform.platform():
        return "Mac"
    else:
        return "Linux"

if __name__ == "__main__":
    main()
