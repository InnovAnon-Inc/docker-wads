#! /bin/bash
set -exu

if ! command -v dockerd ; then
	command -v wget ||
	apt install wget
	wget -nc https://download.docker.com/linux/static/stable/x86_64/docker-19.03.8.tgz
	[ -d docker-19.03.8 ] ||
	tar xf docker-19.03.8.tgz
	install docker/* /usr/local/bin/
fi

docker version ||
dockerd &

sudo             -- \
nice -n +20      -- \
sudo -u `whoami` -- \
docker build -t innovanon/wads .

docker push innovanon/wads:latest || :

docker volume inspect wadsvol ||
docker volume create  wadsvol

xhost +local:`whoami`
sudo             -- \
nice -n -20      -- \
sudo -u `whoami` -- \
docker run   -t --net=host -e DISPLAY=${DISPLAY} --mount source=wadsvol,target=/usr/out --rm --name wads innovanon/wads
#docker run   -t --mount source=wadsvol,target=/root/oblige --rm --name wads innovanon/wads

# https://www.reddit.com/r/docker/comments/9ou9wx/getting_build_artifacts_out_of_docker_image/

# Create but don't run container from resulting image
CID=$(docker create --mount source=wadsvol,target=/root/oblige innovanon/wads)

# Container be gone
trap "docker rm ${CID}" 0

# Grab that artifact sweetness
docker cp ${CID}:/usr/out/Project_Brutality.pk3 .
docker cp ${CID}:/usr/out/freedm.wad            .
docker cp ${CID}:/usr/out/freedoom1.wad         .
docker cp ${CID}:/usr/out/freedoom2.wad         .

