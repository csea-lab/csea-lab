"""
Contains tools to log CSEA python scripts.

Created 4/5/21 by Benjamin Velie.
veliebm@ufl.edu
"""
from os import PathLike
from types import FunctionType
from functools import wraps
from datetime import datetime
import json
from pathlib import Path


def json_logged(function: FunctionType, log_path: PathLike="log.json"):
    """
    Wrapper to log a Python function.
    """
    @wraps(function)
    def wrapper(*args, **kwargs):

        start_time = datetime.now()
        potential_exception = None

        try:
            result = function(*args, **kwargs)
            return result

        except Exception as e:
            potential_exception = e

        finally:
            end_time = datetime.now()
            writing_dictionary = {
                "Start time": start_time,
                "End time": end_time,
                "Working directory": Path().absolute(),
                "Module": function.__module__,
                "Function": function.__name__,
                "Arguments": args,
                "Keyword arguments": kwargs,
                "Result": result,
                "Exception": potential_exception,
            }
            with open(log_path, "w") as file_writer:
                json.dump(writing_dictionary, file_writer, default=str, indent="\t")

    return wrapper
