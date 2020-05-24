#! /bin/bash
set -exu
[[ $# -eq 0 ]]

docker version ||
dockerd &

docker volume inspect abaddonvol ||
docker volume create  abaddonvol

xhost +local:`whoami`
sudo             -- \
nice -n +20      -- \
sudo -u `whoami` -- \
docker-compose up --build
#docker-compose up -d --build

#docker run   -t --net=host -e DISPLAY=${DISPLAY} --mount source=abaddonvol,target=/root/oblige --rm --name abaddon innovanon/abaddon --help

# https://www.reddit.com/r/docker/comments/9ou9wx/getting_build_artifacts_out_of_docker_image/

# Create but don't run container from resulting image
CID=$(docker create --mount source=wadsvol,target=/usr/vol innovanon/docker-wads)

# Container be gone
trap "docker rm ${CID}" 0

# Grab that artifact sweetness
docker cp ${CID}:/usr/vol/Project_Brutality.pk3 .
docker cp ${CID}:/usr/vol/rainbow_blood.pk3     .
docker cp ${CID}:/usr/vol/bd_be.pk3             .
docker cp ${CID}:/usr/vol/freedm.wad            .
docker cp ${CID}:/usr/vol/freedoom1.wad         .
docker cp ${CID}:/usr/vol/freedoom2.wad         .

