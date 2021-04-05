"""
Contains tools to log CSEA python scripts.

Created 4/5/21 by Benjamin Velie.
veliebm@ufl.edu
"""
from os import PathLike
import logging
from types import FunctionType
import sys
from functools import lru_cache, wraps

@lru_cache
def get_log(log_path: PathLike, logger_name: str) -> logging.Logger:
    """
    Returns a configured log. Memoizable function.
    """
    # Create logger.
    log = logging.getLogger(logger_name)
    log.setLevel(logging.DEBUG)

    # Create handlers.
    stream_handler = logging.StreamHandler(sys.stdout)
    file_handler = logging.FileHandler(log_path)
    stream_handler.setLevel(logging.INFO)
    file_handler.setLevel(logging.DEBUG)

    # Create formatters and add it to handlers.
    stream_format = logging.Formatter('[%(levelname)s] %(message)s')
    file_format = logging.Formatter("[%(asctime)s][%(levelname)s][%(name)s] %(message)s")
    stream_handler.setFormatter(stream_format)
    file_handler.setFormatter(file_format)

    # Add handlers to the logger.
    log.addHandler(stream_handler)
    log.addHandler(file_handler)

    return log


def logged(function: FunctionType, log_path="default.log"):
    """
    Decorator to log a function.
    """
    # Get our logger object.
    log_name = f"{function.__module__}.{function.__name__}"
    log = get_log(log_path, log_name)

    # Inner function.
    @wraps(function)
    def wrapper(*args, **kwargs):

        # Log start and end of inner function.
        try:
            log.debug(f"Arguments: {args} {kwargs}")
            output = function(*args, **kwargs)
            log.debug(f"Output: {output}")
            return output

        # Log exceptions.
        except Exception as some_exception:
            log.exception(some_exception)

    return wrapper
