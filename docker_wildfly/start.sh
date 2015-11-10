dockerMachine="puppet-docker"
docker-machine start $dockerMachine
docker-machine env $dockerMachine
eval "$(docker-machine env $dockerMachine)"
