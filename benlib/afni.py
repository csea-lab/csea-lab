#!/usr/bin/env python3
"""
This module includes a class to run AFNI programs and write and store info about them. Caches program output so you don't need to run the same step twice.

It also includes some helper functions to assist you in your travels with AFNI.

Created 10/13/2020 by Benjamin Velie.
veliebm@gmail.com
"""

# Import external libraries and modules.
from datetime import datetime
from functools import cached_property
import subprocess
from pathlib import Path
import yaml
import sys
import re
import nibabel
from dataclasses import dataclass
from os import PathLike
from typing import Dict, List

@dataclass
class AFNI():
    """
    Class to run AFNI programs and store information about them.
    """
    program: str
    args: list
    working_directory: PathLike
    write_matrix_lines_to: PathLike=None

    def __post_init__(self) -> None:
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
            if self.has_ran_before:
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
        if not self.has_ran_before:
            if self.write_matrix_lines_to:
                self._write_matrix()
            self.write_logs(self.log_path)

    @cached_property
    def has_ran_before(self) -> bool:
        """
        Returns true if the program has already run before.

        We infer this by checking whether log files are present in which we've run the program with the same args.
        """
        has_ran = True
        try:
            assert self.log_path.exists(), f"{self.log_path}: Log doesn't exist."
            log = read_yaml(self.log_path)
            assert log["__repr__"] == self.__repr__(), f"{self.log_path}: Log doesn't contain same __repr__ as the AFNI program you're running."
        except AssertionError:
            has_ran = False

        return has_ran

    def write_logs(self, log_path: PathLike) -> None:
        """
        Write program log.
        """
        # Store log info into a dict.
        log_data = {
            "Start time": self.start_time,
            "End time": self.end_time,
            "Total time to run program": str(self.end_time - self.start_time),
            "Return code": self.process.returncode,
            "__repr__": self.__repr__(),
            "stdout and stderr": self.stdout_and_stderr.splitlines(),
        }

        # Write the log data to a yaml file.
        print(f"Writing {log_path}")
        save_yaml(log_data, log_path)

    def _write_matrix(self) -> None:
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

def subbrick_labels_of(path_to_afni_dataset) -> List[str]:
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

def read_yaml(path: PathLike) -> Dict:
    """
    Decode a yaml file.
    """
    with open(path, "r") as read_file:
        return yaml.load(read_file, Loader=yaml.UnsafeLoader)
