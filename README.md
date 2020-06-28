[![Build Status](https://travis-ci.com/cliwrap/bionic.svg?branch=master)](https://travis-ci.com/cliwrap/bionic)

The `Dockerfile` in this repository builds a `ubuntu:18.04` container
(with `apt-get update` and `apt-get upgrade` run) which lets you run
commands inside the container using a UID and GID which are passed in
environment variables from outside the container, so that any files
created in a volume mount can be created as the user and group who
initiated `docker run`.

Read more at [https://wtanaka.com/node/8271](https://wtanaka.com/node/8271)

To download: [`docker pull cliwrap/bionic`](https://hub.docker.com/r/cliwrap/bionic/)

Examples
--------

Create a file called `myfile` in the current directory

```docker run --rm -e "HOSTUID=`id -u`" -v "`pwd`:/work" cliwrap/bionic touch myfile```

Create a file with the correct uid and gid in the current directory

```docker run --rm -e "HOSTUID=`id -u`" -e "HOSTGID=`id -g`" -v "`pwd`:/work" cliwrap/bionic touch myfile```
