"""
Class to ease working with BIDS-named paths.

Created on 3/18/2021 by Ben Velie
veliebm@gmail.com
"""

from pathlib import Path
from dataclasses import dataclass
from typing import Dict, Union
import re
from functools import cached_property


@dataclass
class BIDSpath:
    """
    Attributes
    ----------
    path: Path
        Path to something named according to BIDS.
    """
    _path: Path


    def __post_init__(self) -> None:
        """
        This method calls after the __init__ method.
        """
        self._path = Path(self.path).absolute()

    def __getitem__(self, key: str) -> str:
        """
        Let us access our inner dictionary.
        """
        return self.dictionary[key]

    @property
    def path(self) -> Path:
        return self._path

    @path.setter
    def path(self, _) -> None:
        """
        Make it impossible to change self.path.
        """
        pass

    @cached_property
    def prefix(self) -> str:
        """
        Returns the stem. If our path is an AFNI path, removes the view.
        """
        prefix = self.path.stem

        if self.is_afni:
            prefix = re.search(pattern=f"(.+)\\+{self.view}$", string=prefix).group(1)
        
        return prefix

    @cached_property
    def view(self) -> str:
        """
        If we have an AFNI path, then return its view, else return None.
        """
        view = None

        if self.is_afni:
            stem = self.path.stem
            view = re.search(pattern=r"\+(\w+?)$", string=stem).group(1)

        return view

    @cached_property
    def dictionary(self) -> Dict[str, Union[str, bool]]:
        """
        Parses keys and values from the name of self.path. Keys without values are assigned True.
        """
        prefix = self.prefix
        dictionary = {}

        segments = prefix.split("_")
        for segment in segments:
            try:
                key, value = segment.split("-")
            except ValueError:
                key, value = segment, True

            dictionary[key] = value
        
        return dictionary

    @cached_property
    def is_afni(self) -> bool:
        """
        Determine whether this is an AFNI path.
        """
        is_afni = False

        stem = self.path.stem
        if re.search(pattern=r"(\+tlrc|\+orig)$", string=stem):
            is_afni = True

        return is_afni
