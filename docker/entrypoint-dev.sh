#!/bin/bash -ex

# create virtualenv under project directory if it does not exist yet
[[ ! -d "$XDG_CACHE_HOME/webdev-env" ]] && mkdir -p "$XDG_CACHE_HOME" && virtualenv --python=python3 "$XDG_CACHE_HOME/webdev-env"

# activate virtualenv
. "$XDG_CACHE_HOME/webdev-env/bin/activate"

# add virtualenv to .bashrc so that it is available when execing to the environment
echo ". $XDG_CACHE_HOME/webdev-env/bin/activate; cd /app" > "$HOME/.bashrc"


cd /app

# install dependencies
pip install -r requirements.txt


# wait until postgres can be connected, up to 5 seconds
timeout 10 bash -c "until cat < /dev/null >/dev/tcp/db/5432; do sleep 1; done" 2>/dev/null

# run db migrations
python manage.py migrate

# run the server
python manage.py runserver 0.0.0.0:8000
