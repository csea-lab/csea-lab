"""
Contains tools to log CSEA python scripts.

Created 4/5/2021 by Benjamin Velie.
veliebm@ufl.edu
"""
from os import PathLike
from types import FunctionType
from functools import wraps
from datetime import datetime
import json
from pathlib import Path


def logged(function: FunctionType) -> FunctionType:
    """
    Wrapper to log a Python function.

    Parameters
    ----------
    log_path: PathLike="log.json"
        Where to dump the log.
    """
    @wraps(function)
    def wrapper(log_path: PathLike, *args, **kwargs):

        # What to do before executing the function.
        start_time = datetime.now()
        potential_exception = None

        # Try to execute the function.
        try:
            result = function(*args, **kwargs)
            return result
        except Exception as e:
            potential_exception = e

        # What to do after executing the function.
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


@logged("log.json")
def _test_logged(*args, **kwargs):
    """
    Test the logged decorator.
    """
    return args, kwargs, "hello there"
