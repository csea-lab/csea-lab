"""This program launches docker on Windows as an administrator. It stops running once docker is running."""
### I began writing this on June 28, 2020. My name is Ben Velie. Send me questions at veliebm@gmail.com 🙂

import subprocess
import time

def main():

    start_docker()


def start_docker():
    """Start the docker process if it's not already running."""
    docker_path = "'C:/Program Files/Docker/Docker/Docker Desktop.exe'"

    ## Check if docker is running.
    process = powershell("docker ps")
    if process.returncode != 0:
        powershell(f"Start-Process {docker_path} -Verb runAs")

        ## Wait for docker to run before exiting our function.
        print("Starting Docker…")
        while True:
            time.sleep(2)
            check_process = powershell("docker ps")
            if check_process.returncode == 0:
                break
    print("Docker is running. Good! Make sure this is as an administrator.")


def powershell(input_string: str, capture_output=True):
    """Run the input string in PowerShell. Returns the generated process object."""
    powershell_path = "C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
    output_process = subprocess.run(f"{powershell_path} {input_string}", capture_output=capture_output)
    return output_process


if __name__ == "__main__":
    main()