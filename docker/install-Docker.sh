#!/bin/bash          
#-------------------------------------------------------------------------------
# Install docker on Ubuntu 16.04 LTS (Xenial Xerus)
# https://docs.docker.com/engine/installation/linux/ubuntulinux/
#-------------------------------------------------------------------------------
echo "PLEASE RUN 'sudo bash $0'"

function backupDir() {
  OF=/var/my-backup-$(date +%Y%m%d).tgz
  tar -cZf $OF /home/me/
}

dockerPreInstall() {
  sudo apt-get update
  sudo apt-get install apt-transport-https ca-certificates

  # GPS Key
  sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
}

installDocker() {
  sudo apt-get update
  sudo apt-get purge lxc-docker
  apt-cache policy docker-engine
  # From now on when you run apt-get upgrade, APT pulls from the new repository.

  # For Ubuntu Trusty, Wily, and Xenial, it’s recommended to install the linux-image-extra
  sudo apt-get update
  sudo apt-get install linux-image-extra-$(uname -r)

  # Check it! for Ubuntu 14.04 or 12.04
  #sudo apt-get install apparmor

  sudo apt-get update
  sudo apt-get install docker-engine
  sudo service docker start
  sudo docker run hello-world
}

function checkKernelVersion() {
  kernel_version=$1
  version=$()
  if [ $(uname -r | awk -F "." '{ print $1 }') -eq 3 ] && \
     [ $(uname -r | awk -F "." '{ print $2 }') -ge 10 ]; then
      echo "INFO: Your kernel version is: $(uname -r)"
  elif [[ $(uname -r | awk -F "." '{ print $1 }') -ge 4 ]]; then
      echo "INFO: Your kernel version is: $(uname -r)"
  else
      echo "INFO: Please upgrade your kernel, need to be greater than $kernel_version"
      echo "INFO: Your kernel version is: $(uname -r)"
      exit 0
  fi
}

function setDockerRepoVersion() {
  os_release="/etc/os-release"
  ubuntu=$(cat $os_release | grep "^ID=ubuntu" | awk -F "=" '{print $2}')

  if [ -f $os_release ] && [ $ubuntu == 'ubuntu' ]; then
      echo "INFO: OS: $ubuntu"
      VERSION_ID=$(cat $os_release | grep VERSION_ID | awk -F "\"" '{print $2}')
      if [ $VERSION_ID == '12.04' ]; then
          echo "INFO: We don't support Ubuntu $VERSION_ID"
          exit
          entry_ubuntu="deb https://apt.dockerproject.org/repo ubuntu-precise main"
      elif [ $VERSION_ID == '14.04' ]; then
          entry_ubuntu="deb https://apt.dockerproject.org/repo ubuntu-trusty main"
      elif [ $VERSION_ID == '15.10' ]; then
         entry_ubuntu="deb https://apt.dockerproject.org/repo ubuntu-wily main"
      elif [ $VERSION_ID == '16.04' ]; then
          entry_ubuntu="deb https://apt.dockerproject.org/repo ubuntu-xenial main"
      else
          echo "INFO: Right Now we don't support your operation system"
          echo "INFO: We support Ubuntu Linux 15.10, 16.04"
          exit 0
      fi
      addToFile
  else
      #version_ID=$(cat /proc/version)
      echo "INFO: Right Now we don't support your operation system"
      echo "INFO: We support Ubuntu Linux 15.10, 16.04"
      exit
  fi
}

function addToFile() {
  file="/etc/apt/sources.list.d/docker.list"
  if [ ! -f "$file" ]; then
    echo "INFO: Create file: $file"
    touch $file
    echo "INFO: Add string '$entry_ubuntu' to \
      '$file'"
    echo $entry_ubuntu > $file
  else
    echo "INFO: Replace with new string '$entry_ubuntu' to the file: '$file'"
    echo $entry_ubuntu > $file
  fi
}

#------------------------------------------------------------------------------
# MAIN
#------------------------------------------------------------------------------
dockerPreInstall
checkKernelVersion "3.10"
setDockerRepoVersion
installDocker


