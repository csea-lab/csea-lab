"""
Class to ease working with BIDS-named paths.

Created on 3/18/2021 by Ben Velie
veliebm@gmail.com
"""

from pathlib import Path
from dataclasses import dataclass, field
from typing import Dict
import re


@dataclass
class BIDSpath:
    """
    Attributes
    ----------
    path: Path
        Path to something named according to BIDS.
    dictionary: Dict
        Stores key-value pairs from the file name.
    is_afni: bool
        True if path leads to something named like an AFNI file.
    """
    __slots__ = ["_path", "dictionary", "is_afni"]
    _path: Path
    dictionary: Dict[str, str] = field(init=False)
    is_afni: bool = field(init=False) 


    def __post_init__(self) -> None:
        """
        This method calls after the __init__ method.
        """
        self.path = Path(self.path)
        self._update_attributes()


    def __getitem__(self, key: str) -> str:
        """
        Let us access our inner dictionary.
        """
        return self.dictionary[key]


    @property
    def path(self) -> Path:
        return self._path

    @path.setter
    def path(self, _path: Path) -> None:
        self._path = Path(_path)
        self._update_attributes()


    def get_prefix(self) -> str:
        """
        Returns the stem. If our path is an AFNI path, removes the view.
        """
        prefix = self.path.stem

        if self.is_afni:
            view = self.get_view()
            prefix = re.search(pattern=f"(.+)\\+{view}$", string=prefix).group(1)
        
        return prefix


    def get_view(self) -> str:
        """
        If we have an AFNI path, then return its view, else return None.
        """
        view = None

        if self.is_afni:
            stem = self.path.stem
            view = re.search(pattern=r"\+(\w+?)$", string=stem).group(1)

        return view


    def _reset_attributes_to_default(self) -> None:
        """
        Sets our attributes to their default values.
        """
        self.dictionary = {}
        self.is_afni = False


    def _update_attributes(self) -> None:
        """
        Update our attributes.
        """
        self._reset_attributes_to_default()

        # Determine whether this is an AFNI path.
        stem = self.path.stem
        if re.search(pattern=r"(\+tlrc|\+orig)$", string=stem):
            self.is_afni = True
        
        # Parse dictionary of the path.
        self._parse_dictionary()


    def _parse_dictionary(self) -> None:
        """
        Parses keys and values from the name of self.path. Keys without values are assigned True.
        """
        prefix = self.get_prefix()

        segments = prefix.split("_")
        for segment in segments:
            try:
                key, value = segment.split("-")
            except ValueError:
                key, value = segment, True

            self.dictionary[key] = value
