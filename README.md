
# Developing and packaging Django apps with Docker



**NOTE: This is work in progress**


## Overview

Sometimes it can be difficult to create clean Docker images for
applications that have lots of build time dependencies. Production
images may then end up containing extra packages, such as compilers,
that shouldn't really be there. One approach is to write Dockerfiles
that first installs the dependencies, then builds the application and
finally removes unnecessary dependencies. Another approach is to use
"builder" container.

This tutorial shows how to use an intermediate "builder" container to
produce clean Docker image for the web app, free of any build time
dependencies.  It also shows how to use docker-compose for setting up
the development environment with a single command.


## Developing with docker-compose

Execute `docker-compose up` to start the development container with
django and postgress.  See [docker-compose.yml](docker-compose.yml)
for details.

    export UID
    docker-compose up


The current directory will be mounted into django container as /app.
Django will run source code from there, making it unnecessary to
re-create the container each time source code is modified.

We'll also set /app/.cache/ as cache for pip and virtualenv for
installing development dependencies.  Environment variable UID is used
to pass the user id into the container.  Processes will be executed
with that UID to guarantee correct ownership of files stored in
mounted host volume.

For the contents of the django development environment container, see
[docker/Dockerfile-dev](docker/Dockerfile-dev).


## Creating production image

First we create builder container.  In this tutorial the development
from previous chapter doubles as the builder.

    docker build --build-arg uid=$UID --file docker/Dockerfile-dev --tag webdev .


Next we run the builder script within this container.  It will install
the application and its extra non-OS dependencies into a build
context.  See [docker/builder.sh](docker/builder.sh) for full details.
The result is a tar.gz package which is then used in the next step as
Docker build context to create the production container.

    docker run --rm \
        --volume $PWD:/source \
        --volume $HOME/cache:/cache \
        --volume $HOME/output:/output \
        webdev \
        /source/docker/builder.sh

    docker build --tag myapp - < $HOME/output/docker-build-context.tar.gz


Finally the image can be tested:

    docker run --rm \
        -e ENVIRONMENT="PRODUCTION" \
        -e DJANGO_SECRET_KEY="my-not-so-secret-key" \
        -e POSTGRES_USER="postgres" \
        -e POSTGRES_PASSWORD="postgres" \
        --publish 8000:8000 \
        myapp

