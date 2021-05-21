#!/usr/bin/env python3
"""
This module includes a class to run AFNI programs and write and store info about them. Caches program output so you don't need to run the same step twice.

It also includes some helper functions to assist you in your travels with AFNI.

Created 10/13/2020 by Benjamin Velie.
veliebm@gmail.com
"""

# Import external libraries and modules.
from datetime import datetime
import subprocess
from pathlib import Path
import yaml
import sys
import re
import nibabel
from dataclasses import dataclass
from os import PathLike

# Import lean and mean CSEA modules.
from reference import the_path_that_matches

@dataclass
class AFNI():
    """
    Class to run AFNI programs and store information about them.
    """
    program: str
    args: list
    working_directory: PathLike
    write_matrix_lines_to: PathLike=None

    def __post_init__(self):
        """
        Runs after self.__init__()
        """
        self.start_time = datetime.now()
        self.working_directory = Path(self.working_directory).absolute()
        self.log_path = self.working_directory / f"{self.program}_log.yaml"

        # Tell user that we're executing this object.
        print(f"Executing {self.__repr__()}")

        # Make working_directory if it doesn't exist.
        self.working_directory.mkdir(parents=True, exist_ok=True)

        # Execute AFNI program.
        with subprocess.Popen([self.program] + self.args, cwd=self.working_directory, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True) as process:

            # Immediately kill the process if it doesn't need to be run.
            if self.has_run_before:
                process.kill()
                print(f"Killing {self.program} because we've already run it before in {self.working_directory}. Delete its log file if you wish to rerun it.")

            # Print stdout/stderr and store them in a string.
            self.process = process
            self.stdout_and_stderr = ""
            for line in self.process.stdout:
                sys.stdout.write(line)
                sys.stdout.flush()
                self.stdout_and_stderr += line

        self.end_time = datetime.now()
        
        # Save logs.
        if not self.has_run_before:
            if self.write_matrix_lines_to:
                self._write_matrix()
            self.write_logs()

    @property
    def has_run_before(self):
        """
        Returns true if the program has already run before.

        We infer this by checking whether log files are present. If log files exist, then
        the program has probably already ran to completion before.
        """
        try:
            assert self.log_path.exists()
            return True
        except AssertionError:
            return False

    def write_logs(self):
        """
        Write program info and logs to working directory.
        """
        # Store log info into a dict.
        log_data = {
            "Program name": self.program,
            "Return code": self.process.returncode,
            "Working directory": str(self.working_directory),
            "Start time": self.start_time,
            "End time": self.end_time,
            "Total time to run program": str(self.end_time - self.start_time),
            "Complete command executed": self.process.args,
            "stdout and stderr": self.stdout_and_stderr.splitlines()
        }

        # Write the log info dict to a json file.
        print(f"Writing {self.log_path}")
        save_yaml(log_data, self.log_path)

    def _write_matrix(self):
        """
        Writes ALL lines in stdout resembling a matrix to disk.

        Double-check the matrix to make sure it ONLY captured the lines you want it to capture!
        This method is useful if you're recording the outputs of 3dToutcount or 3dROIstats.
        """

        # Define function to filter in any line of stdout that exclusively contains numbers, tabs, and decimal signs.
        def is_part_of_matrix(string, contains_wrong_characters=re.compile(r'[^\t0-9. ]').search):
            return not bool(contains_wrong_characters(string))

        # Apply filter to each line in stdout.
        matrix_lines = [line + "\n" for line in self.stdout_and_stderr.splitlines() if is_part_of_matrix(line)]

        # Write our beautiful (and hopefully not broken!) matrix to disk.
        with open(self.write_matrix_lines_to, "w") as file:
            file.writelines(matrix_lines)

def subbrick_labels_of(path_to_afni_dataset):
    """
    Returns a list. Each element is the label of a sub-brick within the target dataset.
    """
    dataset = nibabel.load(path_to_afni_dataset)
    raw_label_string = dataset.header.info['BRICK_LABS']
    labels = raw_label_string.split("~")

    return labels

def save_yaml(data, write_path: PathLike) -> None:
    """
    Save some data (probably a dictionary) as a pleasant and cheerful yaml file.
    """
    with open(write_path, "w") as write_file:
        yaml.dump(data, write_file, default_flow_style=False)
