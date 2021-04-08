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


def logged(log_path) -> FunctionType:
    """
    Decorator to log a Python function.

    Parameters
    ----------
    log_path: PathLike
        Where to dump the log.

    Learn about decorators: https://stackoverflow.com/questions/739654/how-to-make-function-decorators-and-chain-them-together/1594484#1594484
    """
    # Define the decorator to return.
    def decorator(function: FunctionType) -> FunctionType:
        @wraps(function)
        def wrapper(*args, **kwargs):
        
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
                    "Returned": result,
                    "Exception": potential_exception,
                }
                with open(log_path, "w") as file_writer:
                    json.dump(writing_dictionary, file_writer, default=str, indent="\t")
    
        return wrapper
    return decorator


@logged("log.json")
def _test_logged(*args, **kwargs):
    """
    Test the logged decorator.
    """
    return args, kwargs, "hello there"
