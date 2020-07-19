#!/bin/bash
# This script is really useful! If you run it from within a container, the container
# will download and install Jupyter Notebook and Jupyter Lab. Then it launches Jupyter Lab.

set -e

pip install jupyter jupyterlab jupyter_contrib_nbextensions
source activate neuro && jupyter nbextension enable exercise2/main && jupyter nbextension enable spellchecker/main
mkdir -p ~/.jupyter && echo c.NotebookApp.ip = \"0.0.0.0\" > ~/.jupyter/jupyter_notebook_config.py

jupyter lab