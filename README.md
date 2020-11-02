[![License](https://img.shields.io/github/license/vlauciani/docker-awstats.svg)](https://github.com/INGV/docker-awstats/blob/master/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/vlauciani/docker-awstats.svg)](https://github.com/INGV/docker-awstats/issues)

![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/vlauciani/docker-awstats)
![Docker Image Size (latest semver)](https://img.shields.io/docker/image-size/vlauciani/docker-awstats?sort=semver)
![Docker Pulls](https://img.shields.io/docker/pulls/vlauciani/awstats.svg)

# docker-awstats
[Awstats](http://www.awstats.org) Docker Image. 

Pre-built docker image is available on [Docker Hub](https://hub.docker.com/repository/docker/vlauciani/awstats).

# Credits

This Docker setup is based on work from:
https://github.com/justb4/docker-awstats.

# Quickstart

### Clone the repository
First, clone the git repositry:
```
$ git clone https://github.com/vlauciani/docker-awstats.git
$ cd docker-awstats
```

### Docker image
To obtain *docker-awstats* docker image, you have two options:

#### 1) Get built image from DockerHub (*preferred*)
Get the last built image from DockerHub repository:
```
$ docker pull vlauciani/docker-awstats:latest
```

#### 2) Build by yourself
```
$ docker build --tag vlauciani/docker-awstats . 
```

in case of errors, try:
```
$ docker build --no-cache --pull --tag vlauciani/docker-awstats . 
```

### Get last Docker image:
```
$ cd docker-awstats
$ docker pull vlauciani/docker-awstats
```

# Awstats Documentation
* All on [awstats config](http://www.awstats.org/docs/awstats_config.html)
* https://blogging.dragon.org.uk/installing-awstats-on-ubuntu-16-04-lts/

## Design
The intention is to have this Docker image as self-contained as possible in order to
avoid host-bound/specific actions and tooling, in particular log processing via 
host-based `cron`, we may even apply `logrotate` later. Also allow for multiple domains with minimal config.

Further design choices:

* schedule `awstats` processing (via `cron`)
* allow for multiple domains
* generate a landing HTML page with links to stats of all domains
* allow for minimal config within an `.env` file (expand with `envsubst` into template `.conf`)
* allow full Awstats `.conf` file as well
* have GeoIP reverse IP lookup, enabled (may need more advanced/detailed upgrade to...)
* configurable `subpath` (prefix) for running behind reverse proxy via `AWSTATS_PATH_PREFIX=` env var
* make it easy run with [docker-compose](test/docker-compose.yml)
 
A `debian-slim` Docker Image ((`buster` version) is used as base image. 
(I'd love to use Alpine, but it became too complicated
with the above features, input welcome!). 
The entry program is `supervisord` that will run a [setup program once](scripts/aw-setup.sh), `apache2` webserver daemon
(for the landing page and logstats), and `cron` for Awstats processing.
 
Advanced
========

User-defined Scripts
--------------------

User-defined Shell/Bash scripts can be added in the directories `/aw-setup.d` and/or `/aw-update.d` by extending
the Docker Image or easier via Docker Volume Mounting.

Purpose is to provide hooks for preprocessing. For example, a script that fetches/syncs a logfile from a remote
server just before [aw-update.sh](scripts/aw-update.sh) runs. This ensures the data is available.

Analyze old log files
---------------------

Awstats only processes lines in log files that are newer than the newest already
known line.  
This means you cannot analyze older log files later. Start with oldest ones first.
You may need to delete already processed data by `rm /var/lib/awstats/*`

Example sketch of bash-script to process old Apache2 logfiles partly gzipped:

```bash
#!/bin/bash
#
# Run the app
# 
#
# Example gzipped log files from mydomain.com-access.log.2 up to mydomain.com-access.log.60
LOGDIR="/var/local/log"
LOGNAME="access.log"
END=60

# Loop backwards 60,59,...2.
for i in $(seq $END -1 2)
do
  logFile="${LOGDIR}/${LOGNAME}.${i}"
  echo "i=${i} logFile=${logFile}"
  docker exec -it awstats gunzip ${logFile}.gz
  docker exec -it awstats awstats -config=mydomain.com -update -LogFile="${logFile}"
  docker exec -it awstats gzip ${logFile}
done

# Non-zipped remaining files
docker exec -it awstats awstats -config=mydomain.com -update -LogFile="${LOGDIR}/${LOGNAME}.1"
docker exec -it awstats awstats -config=mydomain.com -update -LogFile="${LOGDIR}/${LOGNAME}"
```

# Contribute
Please, feel free to contribute.

# Author
(c) 2020 Valentino Lauciani valentino.lauciani[at]ingv.it

Istituto Nazionale di Geofisica e Vulcanologia, Italia
