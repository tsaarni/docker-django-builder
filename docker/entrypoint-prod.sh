#!/bin/bash -ex

addgroup --gid 1000 django
adduser --system -uid 1000 --ingroup django django

cd /app
python -m compileall /app > /dev/null

# exec gunicorn or user defined command if provided
if [ "$#" -gt 0 ]; then
    exec "$@"
else
    exec gunicorn -b "0.0.0.0:8000" --workers 3 --log-file=- --user django --group django mysite.wsgi
fi
