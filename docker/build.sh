#!/bin/bash

# For example:
#   bash build.sh -f bookworm.Dockerfile -i gamemaster -t 1.0.0
#   bash build.sh -f bookworm.Dockerfile -i gamemaster -t 1.0.0 -a GAMEMASTER_USER=gamemaster -a GAMEMASTER_HOME=/opt/docker_home

usage() {
  cat <<EOF

Usage: bash build.sh -f docker_file -i image_name -t image_tag -a build_arg -a build_arg

EOF
}

image_name="gamemaster"
image_tag="1.0.0"

while getopts ":f:i:t:a:h:" arg; do
  case $arg in
  f)
    docker_file=${OPTARG}
    ;;
  i)
    image_name=${OPTARG}
    ;;
  t)
    image_tag=${OPTARG}
    ;;
  a)
    build_arg="$build_arg--build-arg ${OPTARG} "
    ;;
  h)
    usage
    exit 1
    ;;
  \?)
    echo "invalid flag"
    exit 1
    ;;
  esac
done

build_arg="$build_arg--build-arg GAMEMASTER_VERSION=$image_tag"

docker login
docker pull hello-world:latest
docker pull gcc:13-bookworm
docker build --network=host -f $docker_file -t $image_name:$image_tag $build_arg .
