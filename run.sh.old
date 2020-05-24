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
docker build -t innovanon/docker-wads .

docker push innovanon/docker-wads:latest || :

docker volume inspect wadsvol ||
docker volume create  wadsvol

xhost +local:`whoami`
sudo             -- \
nice -n +20      -- \
sudo -u `whoami` -- \
docker run   -t --net=host -e DISPLAY=${DISPLAY} --mount source=wadsvol,target=/usr/vol --rm --name docker-wads innovanon/docker-wads
#docker run   -t --net=host -e DISPLAY=${DISPLAY} --rm --name docker-wads innovanon/docker-wads
#docker run   -t --mount source=wadsvol,target=/usr/vol --rm --name docker-wads innovanon/docker-wads

# https://www.reddit.com/r/docker/comments/9ou9wx/getting_build_artifacts_out_of_docker_image/

# Create but don't run container from resulting image
CID=$(docker create --mount source=wadsvol,target=/usr/vol innovanon/docker-wads)

# Container be gone
trap "docker rm ${CID}" 0

# Grab that artifact sweetness
docker cp ${CID}:/usr/vol/Project_Brutality.pk3 .
docker cp ${CID}:/usr/vol/rainbow_blood.pk3     .
docker cp ${CID}:/usr/vol/freedm.wad            .
docker cp ${CID}:/usr/vol/freedoom1.wad         .
docker cp ${CID}:/usr/vol/freedoom2.wad         .

