These are the scripts I used to transform Matt's concurrent EEG/fMRI dataset (not included here) into BIDS format in the summer of 2020. After I BIDSified it, I preprocessed it using [fMRIPrep running in a Docker container.](https://fmriprep.org/en/stable/docker.html)

To BIDSify the data:
1) First, run [bidsify_paths.py](bidsify_paths.py), which organizes the dataset into a directory structure resembling BIDS.
2) Now, run [bidsify_metadata.py](bidsify_metadata.py), which extracts metadata from the BIDSified paths to finalize the dataset into BIDS.

Helper programs:
1) [bidsify_paths_template.py](bidsify_paths_template.py) provides templates for [bidsify_paths.py](bidsify_paths.py) so it knows what paths to grab and what to do with them.
2) [dat.py](dat.py) provides a class to extract and organize data from .dat files.
3) [settings.py](settings.py) provides a class to extract and organize data from fMRI settings files.
4) [nifti.py](nifti.py) provides a class to extract and organize data from .nii files.
5) [vmrk.py](vmrk.py) provides a class to extract and organize data from .vmrk files.