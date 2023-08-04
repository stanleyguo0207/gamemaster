#!/bin/bash

usage() {
  cat <<EOF

Usage: bash $0 -f <file> [-i <string>] [-t <string>] [-a <string>=<string> ...] [-c <string>] [-p <uint16|>9000>]

E.g.
    bash $0 -f bookworm.Dockerfile -i gamemaster -t 1.0.0 -a GAMEMASTER_USER=gamemaster -a GAMEMASTER_HOME=/opt/docker_home -c stanley -p 9901

EOF
  exit 1
}

image_name="gamemaster"
image_tag="1.0.0"

while getopts ":f:i:t:a:c:p:" arg; do
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
  c)
    container_name=${OPTARG}
    ;;
  p)
    ssh_port=${OPTARG}
    ;;
  \?)
    echo "Invalid parameter     -${OPTARG}"
    usage
    ;;
  esac
done

if [[ ! -f $docker_file ]]; then
  echo "Dockerfile not found      $docker_file"
  usage
fi

if [[ -z $image_name ]]; then
  echo "Docker build image name is empty"
  usage
fi

if [[ -z $image_tag ]]; then
  echo "Docker build image tag is empty"
  usage
fi

if [[ -z $container_name ]]; then
  echo "Docker create container name is empty"
  usage
fi

if [[ $ssh_port -le 9000 ]]; then
  echo "Docker create container port is invalid, must greater than 9000"
  usage
fi

check_info=$(docker ps -a | grep "$ssh_port->22")

if [[ -n $check_info ]]; then
  echo "Docker create container port already used by other container"
  echo "$check_info"
  usage
fi

image_hash=$(docker images -q "$image_name:$image_tag")
container_hash=$(docker ps -aqf "name=$container_name")

echo "Build info:"
echo "-----------"
echo "docker_file:        $docker_file"
echo "image_name:         $image_name"
echo "image_tag:          $image_tag"
echo "image:              $image_name:$image_tag"
echo "image_hash:         $image_hash"
echo "build_arg:          $build_arg"
echo "container_name:     $container_name"
echo "container_hash:     $container_hash"
echo "ssh_port:           $ssh_port"
echo "-----------"

if [[ -z $image_hash ]]; then
  echo ""
  echo "-----------"
  echo "Building image..."

  docker login
  docker pull hello-world:latest
  docker pull gcc:13-bookworm
  docker build --network=host --no-cache -f $docker_file -t $image_name:$image_tag $build_arg .

  image_hash=$(docker images -q "$image_name:$image_tag")
fi

if [[ -n $image_hash && -z $container_hash ]]; then
  docker create --name $container_name -p $ssh_port:22 --security-opt seccomp=unconfined --privileged=true --restart=always $image_name:$image_tag /sbin/init
  docker start $container_name
fi
