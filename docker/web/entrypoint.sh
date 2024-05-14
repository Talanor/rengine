#!/bin/bash

loglevel=0
if [ "$DEBUG" == "1" ]; then
    loglevel=3
fi

poetry run -C $HOME/ python3 manage.py runserver -v $loglevel 0.0.0.0:8000