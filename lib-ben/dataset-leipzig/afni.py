#!/usr/bin/env python3

"""
Class to run AFNI programs and write and store info about them.

Created 10/13/2020 by Benjamin Velie.
veliebm@gmail.com

"""

# Import standard Python modules.
from datetime import datetime
import subprocess
from pathlib import Path
import json
import sys
import re

# Import some lean and mean CSEA modules.
from reference import the_path_that_matches


class AFNI():
    """
    Class to run AFNI programs and store information about them.
    """

    def __init__(self, program: str, args: list, working_directory, write_matrix_lines_to=None):

        self.start_time = datetime.now()

        # Store input parameters of the object.
        self.program = program
        self.args = args
        self.working_directory = Path(working_directory).absolute()
        self.write_matrix_lines_to = write_matrix_lines_to

        # Figure out if program has run before. If yes, we'll kill the process later.
        self.program_has_run_before = False
        if self._program_has_run_before():
            self.program_has_run_before = True

        # Tell user that we're executing this object.
        print(f"Executing {self.__repr__()}")

        # Make working_directory if it doesn't exist.
        self.working_directory.mkdir(parents=True, exist_ok=True)

        # Execute AFNI program.
        with subprocess.Popen([self.program] + self.args, cwd=self.working_directory, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True) as process:

            # Immediately kill the process if it doesn't need to be run.
            if self.program_has_run_before:
                process.kill()
                print(f"Killing {self.program} because we've already run it before in {self.working_directory}. Delete its log files if you wish to rerun it.")

            # Print stdout/stderr and store them in a string.
            self.process = process
            self.stdout_and_stderr = ""
            for line in self.process.stdout:
                sys.stdout.write(line)
                sys.stdout.flush()
                self.stdout_and_stderr += line

        # Write matrix if an output path for it was given.
        if self.write_matrix_lines_to:
            self._write_matrix()

        self.end_time = datetime.now()
        
        if not self.program_has_run_before:
            self.write_logs()


    def __repr__(self):
        """
        Defines how the class represents itself internally as a string.

        To learn more, consider reading https://docs.python.org/3/reference/datamodel.html#basic-customization
        """

        return f"{self.__class__.__name__}(program='{self.program}', args={self.args}, working_directory='{self.working_directory}')"


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


    def write_logs(self):
        """
        Write program info and logs to working directory.
        """

        # Store program info into a dict.
        program_info = {
            "Program name": self.program,
            "Return code (if 0, then in theory the program threw no errors)": self.process.returncode,
            "Working directory": str(self.working_directory),
            "Start time": str(self.start_time),
            "End time": str(self.end_time),
            "Total time to run program": str(self.end_time - self.start_time),
            "Complete command executed": [str(arg) for arg in self.process.args]
        }

        # Write the program info dict to a json file.
        output_json_path = self.working_directory / f"{self.program}_info.json"
        print(f"Writing {output_json_path}")
        with open(output_json_path, "w") as json_file:
            json.dump(program_info, json_file, indent="\t")

        # Write the program's stdout and stderr to a text file. 
        stdout_stderr_log_path = self.working_directory / f"{self.program}_stdout+stderr.log"
        print(f"Writing {stdout_stderr_log_path}")
        stdout_stderr_log_path.write_text(self.stdout_and_stderr)


    def _program_has_run_before(self):
        """
        Returns true if the program has already run before.

        We infer this by checking whether log files are present. If log files exist, then
        the program has probably already ran to completion before.
        """

        try:
            the_path_that_matches(f"{self.program}_info.json", in_directory=self.working_directory).exists()
            the_path_that_matches(f"{self.program}_stdout+stderr.log", in_directory=self.working_directory).exists()
            return True
        except OSError:
            return False
