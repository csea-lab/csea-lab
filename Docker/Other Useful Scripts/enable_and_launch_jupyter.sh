#!/bin/bash

set -e

pip install jupyter jupyterlab jupyter_contrib_nbextensions
source activate neuro && jupyter nbextension enable exercise2/main && jupyter nbextension enable spellchecker/main
mkdir -p ~/.jupyter && echo c.NotebookApp.ip = \"0.0.0.0\" > ~/.jupyter/jupyter_notebook_config.py

jupyter lab