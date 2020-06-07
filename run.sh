#! /usr/bin/env bash
set -exu
(( $# == 0 ))
cd "`dirname "$(readlink -f "$0")"`"

command -v docker ||
curl https://raw.githubusercontent.com/InnovAnon-Inc/repo/master/get-docker.sh | bash

docker volume inspect abaddonvol ||
docker volume create  abaddonvol

trap 'docker-compose down' 0

xhost +local:`whoami` || :
sudo             -- \
nice -n +20      -- \
sudo -u `whoami` -- \
docker-compose up --build --force-recreate
#docker-compose up -d --build

#docker run   -t --net=host -e DISPLAY=${DISPLAY} --mount source=abaddonvol,target=/root/oblige --rm --name abaddon innovanon/abaddon --help

# https://www.reddit.com/r/docker/comments/9ou9wx/getting_build_artifacts_out_of_docker_image/

( # Create but don't run container from resulting image
  CID=$(docker create --mount source=wadsvol,target=/usr/vol innovanon/docker-wads)

  # Container be gone
  trap "docker rm ${CID}" 0

  # Grab that artifact sweetness
  for k in Project_Brutality.pk3 bd_be.pk3 rainbow_blood.pk3 \
           freedm.wad freedoom1.wad freedoom2.wad ; do
  docker cp ${CID}:/usr/vol/$k .
  done )

docker-compose push
( #git pull
git add .
git commit -m "auto commit by $0"
git push ) || :

