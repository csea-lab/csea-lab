import configparser
import subprocess
import os
import platform
import psutil
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
    # If a config file doesn't exist, make one.
    if not os.path.exists(CONFIG_NAME):
        with open(CONFIG_NAME, "w") as config_file:
            pass

    config = configparser.ConfigParser()

    # Get default config.
    config.read_dict(OS_default_config())

    # Overwrite default config with config file.
    config.read(CONFIG_NAME)

    # Save our changes to the config file.
    with open('config.ini', 'w') as config_file:
        config.write(config_file)
def OS_default_config():
    """
    Returns the config dictionary for the current operating system.
    """
    windows_default_config = {"DEFAULT":
        {"image": "afni/afni",
        "name": "afni",
        "host directory to read OR write to": "/c/Volumes/volume/",
        "read/write directory in container": "/write_host/",
        "host directory to read from": "/c/",
        "read directory in container": "/read_host/",
        "working directory": "/write_host/",
        "port": "8889",
        "display": "DISPLAY=host.docker.internal:0",
        "enable display": "False",
        "docker path": "C:/Program Files/Docker/Docker/Docker Desktop.exe",
        "x server path": "C:/Program Files/VcXsrv/vcxsrv.exe"}
        }

    mac_default_config = {"DEFAULT":
        {"image": "afni/afni",
        "name": "afni",
        "host directory to read OR write to": "/",
        "read/write directory in container": "/write_host/",
        "host directory to read from": "/",
        "read directory in container": "/read_host/",
        "working directory": "/write_host/",
        "port": "8889",
        "display": "",
        "enable display": "False",
        "docker path": "",
        "x server path": ""}
        }

    linux_default_config = {"DEFAULT":
        {"image": "afni/afni",
        "name": "afni",
        "host directory to read OR write to": "/",
        "read/write directory in container": "/write_host/",
        "host directory to read from": "/",
        "read directory in container": "/read_host/",
        "working directory": "/write_host/",
        "port": "8889",
        "display": "",
        "enable display": "False",
        "docker path": "",
        "x server path": ""}
        }
    
    OS = get_OS()
    if OS == "Windows":
        return windows_default_config
    elif OS == "Mac":
        return mac_default_config
    elif OS == "Linux":
        return linux_default_config
    
# Functions to launch X Server
def launch_xserver():
    """
    Launch X Server if it isn't already running.
    """
    if(xserver_running()):
        print("X Server is running")
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
    docker_path = read_config()["docker path"]
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
    print("Executing the following command:")
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
                 "--interactive",
                 "--tty",
                 "--rm",
                 "--name",
                 config_dict["name"],
                 "--volume",
                 config_dict["host directory to read or write to"] + ":" + config_dict["read/write directory in container"],
                 "--volume",
                 config_dict["host directory to read from"] + ":" +
                 config_dict["read directory in container"] + ":ro",
                 "--workdir",
                 config_dict["working directory"],
                 "-p",
                 config_dict["port"],
                 ]

    if config_dict["enable display"] == "True":
        args_list.append("--env")
        args_list.append(config_dict["display"])

    args_list.append(config_dict["image"])
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
def read_config():
    """
    Returns the config file as a dictionary.
    """
    config = configparser.ConfigParser()
    config.read(CONFIG_NAME)
    return {key: config["DEFAULT"][key] for key in config["DEFAULT"]}

if __name__ == "__main__":
    main()
