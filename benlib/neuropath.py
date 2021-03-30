"""
Class to ease working with path archetypes we see at CSEA a lot.

Especially AFNI or BIDS paths.

Created on 3/18/2021 by Ben Velie
veliebm@gmail.com
"""

from pathlib import Path
from dataclasses import dataclass
from typing import Dict, Union
import re
from functools import cached_property


@dataclass
class NeuroPath:
    """
    Eases working with path archetypes we see at CSEA a lot.

    Especially AFNI or BIDS paths.
    """
    _path: Path


    def __post_init__(self) -> None:
        """This method calls after the __init__ method."""
        self._path = Path(self.path).absolute()

    def __fspath__(self):
        """Makes our class officially PathLike."""
        return str(self.path)

    def __getitem__(self, key: str) -> str:
        """Accesses our inner BIDS-naming dictionary."""
        return self.dictionary[key]

    def __str__(self) -> str:
        """What to do when we need to represent this object is a string."""
        return str(self.path)

    @property
    def path(self) -> Path:
        """Path to a file."""
        return self._path

    @cached_property
    def prefix(self) -> str:
        """Returns the prefix of your AFNI file."""
        assert self.is_afni, "This isn't an AFNI file"
        return re.search(pattern=f"(.+)\\+{self.view}$", string=self.path.stem).group(1)

    @cached_property
    def view(self) -> str:
        """Returns the view of your AFNI file."""
        assert self.is_afni, "This isn't an AFNI file"
        return re.search(pattern=r"\+(\w+?)$", string=self.path.stem).group(1)

    @cached_property
    def dictionary(self) -> Dict[str, Union[str, bool]]:
        """Returns a dict with keys and values from the name of self.path. Keys without values are assigned True."""
        stem = self.path.stem
        if self.is_afni:
            stem = self.prefix
        
        dictionary = {}

        segments = stem.split("_")
        for segment in segments:
            try:
                key, value = segment.split("-")
            except ValueError:
                key, value = segment, True

            dictionary[key] = value
        
        return dictionary

    @cached_property
    def is_afni(self) -> bool:
        """Returns true if this is an AFNI path."""
        is_afni = False

        stem = self.path.stem
        if re.search(pattern=r"(\+tlrc|\+orig)$", string=stem):
            is_afni = True

        return is_afni
