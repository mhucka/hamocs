#!/bin/sh
if [ `id -u` = 0 ]; then
    echo "Do not run this as root; run it as mhucka"
else
    . ./venv/bin/activate
    ./flask-server.py
fi
