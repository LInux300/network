#!/bin/bash
echo "RUN as 'sudo bash $0'"

DEFAULT_DOCKER_NAME="ruda-ubuntu-latest"
DEFAULT_DOCKER_HUB="ubuntu:latest"
#DEFAULT_DOCKER_NAME="ruda-centos-latest"
#DEFAULT_DOCKER_HUB="centos:latest"

# Docker
#-------------------------------------------------------------------------------
dockerHelp() {
    echo "# Docker rails app"
    echo "# https://www.youtube.com/watch?v=QgmzBuPuM6I"
    echo ""
    echo "# Docker install ubuntu:latest"
    echo "# INFO: https://www.youtube.com/watch?v=eCm9xUl7quk"
    echo "# INFO: https://www.youtube.com/watch?v=pGYAg7TMmp0&list=PLoYCgNOIyGAAzevEST2qm2Xbe3aeLFvLc"
}

dockerInstallImage() {
    #sudo docker pull centos:latest
    #sudo docker pull ubuntu:14:04
    sudo docker pull $1
}
#dockerInstallImage $DEFAULT_DOCKER_HUB

dockerRunImage() {
    # it downloads if is not stored locally in images
    # -i interactive shell
    # sudo docker run -t -i ubuntu:16.04 /bin/bash
    #sudo docker run --name 'ruda-ubuntu-latest' -ti ubuntu:latest /bin/bash
    #sudo docker run --name 'ruda-centos-latest' -ti centos:latest /bin/bash
    #sudo docker run --name $2 --rm -ti $1 /bin/bash
    sudo docker run --name $2 -ti $1 /bin/bash
    echo "# INFO: exit with exit :-)"
}

dockerStartAttachContainerID() {
    sudo docker start $1
    echo "# INFO: Docker details"
    echo "#--------------------------------------------------------------------"
    sudo docker ps -a -f name=$DEFAULT_DOCKER_NAME
    echo "#--------------------------------------------------------------------"
    linuxCloneGitRepos
    sudo docker attach $1
}

dockerSearchPublicImages() {
    echo "# INFO: Search term: '$1'"
    sudo docker search --stars=3 --no-trunc --automated $1
}
#dockerSearchPublicImages $DEFAULT_DOCKER_HUB


dockerUtilityAddGroup() {
    # add log in and log out when starting docker image
    sudo groupadd docker
    sudo usermod -aG docker kuntuzangpo
}

dockerUtilityContainerNames() {
    # To see only names of containers
    sudo docker inspect --format='{{.Name}}' $(sudo docker ps -aq --no-trunc)
}
#dockerUtilityContainerNames


dockerUtilityGetImages() {
    sudo docker images
}

dockerUtilitySeeContainers() {
    # See containers
    sudo docker ps -a -f status=running
    sudo docker ps -a
}

dockerUtilityRemoveNotRunningContainers() {
    # To remove all containers that are NOT running
    sudo docker rm `docker ps -aq -f status=exited`
}
#dockerUtilityRemoveNotRunningContainers

dockerDockerHubLogin() {
    # docker login
    # user: kuntuzangmo
    # pass: 
    create docker hub
    create repository private|public

    docker pull kuntuzangmo/tibetanmedicine.eu
}

dockerGetDocker() {
    echo "# Docker"
    echo "# INFO: https://docs.docker.com/linux/step_one/"
    echo "# --------------------------------------------------------------------"

    which curl

    curl -fsSL https://get.docker.com/ | sh
    #   $ curl -fsSL https://get.docker.com/gpg | sudo apt-key add -
}

# LINUX
#-------------------------------------------------------------------------------

linuxAddToEtcHosts() {
    string="81.2.254.221 tibetanmedicine.com"
    file='/etc/hosts'
    $string >> $file
}

linuxCloneGitRepos() {

    container_id=$(sudo docker ps -aqf "name=$DEFAULT_DOCKER_NAME")
    echo "# INFO: Create code directory"
    sudo docker exec  $container_id script /dev/null -c "mkdir ~/code"

    echo "# INFO: Git instalation on docker box"
    FILE="apache-virtual-hosts.sh"
    #sudo docker exec  $container_id /bin/bash -c "sudo apt=get install git"
    docker run --rm -ti $DEFAULT_DOCKER_NAME bash -c "source $FILE"

    #sudo docker exec -it $container_id script /dev/null -c "cd ~/code; git clone https://github.com/rudolfvavra/network.git"

}
 

linuxCloneGitReposTEST() {
    echo "# INFO: Clone Git Repositories"
    #cmd=$(cd ~/code; pwd;
    #git clone https://github.com/rudolfvavra/network.git;)

    sudo docker exec -it $container_id script /dev/null -c <<EOF
mkdir ~/code
cd ~/code
pwd
touch README
#git clone https://github.com/rudolfvavra/network.git
EOF


    #sudo docker exec -d $DEFAULT_DOCKER_NAME bash $cmd
    #cd ~/code
}



# MAIN
#-------------------------------------------------------------------------------
echo "# INFO: Checks for local default installed image"
local_default_docker=$(sudo docker ps -a -f name=$DEFAULT_DOCKER_NAME | wc -l)
# 2 -> first line is tab header
if [ $local_default_docker == 2 ]; then
    echo "# INFO: Starting and Attaching local docker: '$DEFAULT_DOCKER_NAME' ..."
    dockerStartAttachContainerID $DEFAULT_DOCKER_NAME
else
    echo "# INFO: Downloding from ducker hub: '$DEFAULT_DOCKER_HUB'"
    echo "# INFO: Creating the local docker image: '$DEFAULT_DOCKER_NAME'"
    echo "# INFO: Running in interactive mode"
    dockerRunImage $DEFAULT_DOCKER_HUB $DEFAULT_DOCKER_NAME
fi


