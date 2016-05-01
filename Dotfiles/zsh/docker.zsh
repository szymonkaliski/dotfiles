alias docker-name="docker ps | tail -1 | rev | cut -d ' ' -f1 | rev"
alias docker-disconnect="docker-machine stop"

docker-connect() {
  if ! docker-machine ls | grep -q "Running"; then
    echo "Docker not running, booting up!"
    docker-machine start
  fi

  eval $(docker-machine env default)
}

docker-ip() {
  echo $DOCKER_HOST | cut -d '/' -f3 | cut -d ':' -f1
}

docker-cleanup() {
  docker rm -v $(docker ps -a -q -f status=exited)
  docker rmi -f $(docker images -f "dangling=true" -q)
}

