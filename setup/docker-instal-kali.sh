#!/bin/bash
# for kali: https://gist.github.com/apolloclark/f0e3974601346883c731
# Kali 2016.1, Docker Install script

# update apt-get
export DEBIAN_FRONTEND="noninteractive"
sudo apt-get update

# remove previously installed Docker
sudo apt-get purge lxc-docker*
sudo apt-get purge docker.io*

# add Docker repo
sudo apt-get install -y apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

cat > /etc/apt/sources.list.d/docker.list <<'EOF'
deb https://apt.dockerproject.org/repo debian-stretch main
EOF
sudo apt-get update

# install Docker
sudo apt-get install -y docker-engine
sudo service docker start
sudo docker run hello-world


# configure Docker user group permissions
sudo groupadd docker

## klicko 
useradd -m xp
passwd xp
usermod -a -G sudo xp
chsh -s /bin/bash xp
# as root change /etc/sudoers
### klicko
#xp        ALL=(ALL)      ALL

sudo gpasswd -a ${USER} docker
sudo service docker restart

# set Docker to auto-launch on startup
sudo systemctl enable docker
