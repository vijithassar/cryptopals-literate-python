#!/bin/bash

set -e

# create a virtual environment
if [ ! -d env ]; then
  python3 -m venv env
fi

# install lit.sh
if [ ! -f 'lit.sh' ]; then
  curl https://raw.githubusercontent.com/vijithassar/lit/master/lit.sh > lit.sh && chmod +x lit.sh
fi

# switch to virtual environment
source env/bin/activate

# install required modules
python3 -m pip install requirements.txt
