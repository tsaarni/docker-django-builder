#!/bin/bash -ex

addgroup --gid 1000 django
adduser --system -uid 1000 --ingroup django django

ln -s /usr/local/bin/python3 /usr/bin/python3


python -m compileall > /dev/null
python -m compileall /app > /dev/null

export PYTHONPATH=/usr/lib/python3.5/site-packages:/app

if [ "$#" -gt 0 ]; then
    exec "$@"
fi


cd /app
exec gunicorn -b "0.0.0.0:8000" --workers 3 --log-file=- --user django --group django my_web_app.wsgi
