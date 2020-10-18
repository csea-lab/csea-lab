#!/usr/bin/env python3

"""
Class to run AFNI programs and write and store info about them.

Created 10/13/2020 by Benjamin Velie.
veliebm@gmail.com

"""

# Import standard Python modules. ---------------------
from datetime import datetime
import subprocess
from pathlib import Path
import json
import sys


# Import some lean and mean CSEA modules. --------------------------
from reference import the_path_that_matches


class AFNI():
    """
    Class to run AFNI programs and store information about them.

    """

    def __init__(self, where_to_create_working_directory, program: str, args: list):

        # Store parameters and start time. Tell user that we're executing this object. --------------------------
        self.where_to_create_working_directory = Path(where_to_create_working_directory).absolute()
        self.program = program
        self.args = args
        self.start_time = datetime.now()
        print(f"Executing {self.__repr__()}")


        # Make working_directory if it doesn't exist. -------------------------------------
        self.working_directory = self.where_to_create_working_directory/self.program
        self.working_directory.mkdir(parents=True, exist_ok=True)


        # Execute AFNI program. Print stdout/stderr and store them in a string. ---------------------------------
        with subprocess.Popen([self.program] + self.args, cwd=self.working_directory, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True) as process:

            # Immediately kill the process if it doesn't need to be run.
            if self._program_has_run_before():
                process.kill()
                print(f"Killing {self.program} because we've already run it before. Delete its log files if you wish to run {self.program} again.")

            self.process = process
            self.stdout_and_stderr = ""
            for line in self.process.stdout:
                sys.stdout.write(line)
                sys.stdout.flush()
                self.stdout_and_stderr += line


        # Record end time. Write logs. ----------------------------------------
        self.end_time = datetime.now()
        if not self._program_has_run_before():
            self.write_logs()


    def __repr__(self):
        """
        Defines how the class represents itself internally as a string.

        To learn more, consider reading https://docs.python.org/3/reference/datamodel.html#basic-customization

        """

        return f"{self.__class__.__name__}(where_to_create_working_directory='{self.where_to_create_working_directory}', program='{self.program}', args={self.args})"

    
    def write_logs(self):
        """
        Write program info and logs to working directory.

        """

        # Store program info into a dict. ---------------------------------
        program_info = {
            "Program name": self.program,
            "Return code (if 0, then in theory the program threw no errors)": self.process.returncode,
            "Working directory": str(self.working_directory),
            "Start time": str(self.start_time),
            "End time": str(self.end_time),
            "Total time to run program": str(self.end_time - self.start_time),
            "Complete command executed": self.process.args
        }


        # Write the program info dict to a json file. --------------------------------
        output_json_path = self.working_directory / f"{self.program}_info.json"
        print(f"Writing {output_json_path}")
        with open(output_json_path, "w") as json_file:
            json.dump(program_info, json_file, indent="\t")


        # Write the program's stdout and stderr to a text file. -----------------------------
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
            the_path_that_matches("*_info.json", in_directory=self.working_directory).exists()
            the_path_that_matches("*_stdout+stderr.log", in_directory=self.working_directory).exists()
            return True
        except OSError:
            return False
