#!/bin/bash -ex

# prefix dir for installation
export PYTHONUSERBASE=/install/files/usr

cd /source
pip install --user --cache-dir=/cache/pip-cache/ -r requirements/production.txt

mkdir -p /install/files/app
cp -a * /install/files/app
cp -a docker/entrypoint-prod.sh /install/files/
cp docker/Dockerfile-prod /install/Dockerfile

tar -C /install -zcvvf "${1-/output/docker-build-context.tar.gz}" .
