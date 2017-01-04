#!/bin/bash
# main.sh
#
# From users, gets "real name" from /etc/passwd.

#------------------------------------------------------------------------------
# Browser in terminal
#------------------------------------------------------------------------------
function installBrowserTerminal() {
  sudo apt-get install w3m w3m-img
  sudo apt-get install xterm
  xterm
  # in new window run: w3m google.com
}

#------------------------------------------------------------------------------
# KALI browser
#------------------------------------------------------------------------------
function kaliTop10InBrowser() {
  echo -e "\tINFO: http://tools.kali.org/kali-metapackages"
  echo -e "\tINFO: https://hub.docker.com/r/jgamblin/kalibrowser/"
  sudo docker run -d -t -i -p 6080:6080 jgamblin/kalibrowser
  firefox  http://localhost:6080
  # docker pull jgamblin/kalibrowser-top10
}

#------------------------------------------------------------------------------
# DOCKER
#------------------------------------------------------------------------------
function installDocker() {
    echo "# INFO: https://docs.docker.com/linux/step_one/"
    which curl
    curl -fsSL https://get.docker.com/ | sh
    #   $ curl -fsSL https://get.docker.com/gpg | sudo apt-key add -
}

function dockerInfo() {
  echo -e "\tINFO: Docker Images"
  #docker images
  dockerCheckDigest
  echo -e "\tINFO: Docker Containers Overview"
  docker ps -a
  #echo -e "\tINFO: Running Containers"
  #docker ps -a -f status=running
  #echo -e "\tINFO: State of Running Containers"
  #docker ps -q
}

function removeOneContainer() {
  dockerInfo
  echo -e "\tWARNING: Remove 1 Container"
  echo -n "Enter <container_name>|<container_id> for removing and press [ENTER]: " 
  read container_name
  docker stop $container_name
  docker rm $container_name
}

function removeDockers() {
  dockerInfo
  echo -e "\tWARNING: Removed Docker Containers"
  echo -e "\tINFO: Enter [yes] to delete all '$1' Containers"
  read answer
  echo -e "\tINFO: Your Answer was: '$answer'"
  if [ "$answer" == "yes" ]; then
    echo -e "\tWARNING: Those '$1' Containers were removed:"
    docker rm `docker ps -aq -f status=$1`
  fi
}

function searchDockerRepos() {
  echo -n "Enter search text and press [ENTER]: "
  read search
  docker search --stars=3 --no-trunc --automated $search
}

function checkDockerContainerUp() {
  dockerInfo
  echo -n "Enter <container_name>|<container_id> to get Container IP [ENTER]: "
  read container
  docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container"
}

function getDockerContainerIps() {
  echo -e "\tINFO: IPAddress - Name "
  docker inspect -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}  - {{.Name}}" $(docker ps -aq)
}

function dockerCleanup() {
  EXITED=$(docker ps -q -f status=exited)
  DANGLING=$(docker images -q -f "dangling=true")

  if [ -n "$EXITED" ]; then
    #docker rm $EXITED
    docker rm -v $(docker ps --filter status=exited -q 2>/dev/null) 2>/dev/null
  else
    echo -e "\tINFO: No containers to remove."
  fi
  if [ -n "$DANGLING" ]; then
    echo -e "\tWARNING: Removing unused images"
    docker rmi $(docker images --filter dangling=true -q 2>/dev/null) 2>/dev/null
  else
    echo -e "\tINFO: No images to remove."
  fi

}

#------------------------------------------------------------------------------
# Docker Network - Container Network
#------------------------------------------------------------------------------
function runImageDocker() {
  echo -e "\tINFO: Run '$DOCKER_IMAGE'"
  docker pull $DOCKER_IMAGE
  DOCKER_NAME_EXIST=$(docker ps -a --format={{.Names}} -f name=$DOCKER_NAME)
  if [ "$DOCKER_NAME" == "$DOCKER_NAME_EXIST" ]; then
    echo -e "\tINFO: Container '$DOCKER_NAME' already exists"
    docker ps -a | grep $DOCKER_NAME
    docker start $DOCKER_NAME
    #docker attach $DOCKER_NAME
    docker exec -i -t $DOCKER_NAME /bin/bash
  else
    echo -e "\tINFO: Run container interactive for '$DOCKER_NAME'"
    #docker run --name $DOCKER_NAME -it $DOCKER_IMAGE /bin/bash
    docker run --name $DOCKER_NAME --tty --detach $DOCKER_IMAGE /bin/bash
    docker exec -i -t $DOCKER_NAME /bin/bash
  fi
}

function dockerCheckDigest() {
  echo -e "\tINFO: Checking digest 'sha256' for local DockerImages..."
  docker images --digests | head
}

# function returns params
function nameYourDockerImage() {
  echo -n -e "\tINFO: Name your New image [ENTER]: "
  read $ARR_DOCKER["name_your_image"]
  echo -n -e "\tINFO: Image Tag <stable|latest|master|...> [ENTER]: "
  read tag
  echo -n -e "\tINFO: <docker_user|user> [ENTER]: "
  read user
  echo -n -e "\tINFO: Name your <DockerFile>...> [ENTER]: "
  read docker_file
  echo "$ARR_DOCKER['name_your_image']|$tag|$user"
}
#ret="$(nameYourDockerImage)"
#IFS="|"
#set -- $ret
#echo "Your Docker Name: $1"
#echo "Image Tag: $2"
#echo "Docker User|User: $3"

function dockerBuildImagesFromFiles() {
  echo -e "\tINFO: reading from json['dockerFiles']..."

  mkdir -p $DOCKER_FILES_DIR
  cd $DOCKER_FILES_DIR

  #TODO: change NUMBER_CONTAINERS for len of containers
  for i in `seq 0 $NUMBER_CONTAINERS`; do
    s=".network.dockerFiles[$i].docker_file_name"
      docker_file_name=`echo $CAT_FILE | $BIN_DIR/jq $s`
      docker_file_name=`echo ${docker_file_name:1:-1}`
    s=".network.dockerFiles[$i].enable"
      e=`echo $CAT_FILE | $BIN_DIR/jq $s`
      e=`echo ${e:1:-1}`

    if [ "$e" == "true" ]; then
      file=$DOCKER_FILES_DIR/$docker_file_name
      if [ -e $file ]; then
        echo -e "\tINFO: DockerFile exists '$file'"
        #nohup cat $file  2>1 &
        cat $file
      else
        echo -e "\tINFO: Enter [yes] to edit '$file' with default DockerFile setting..."
        read answer
        echo -e "\tINFO: Answer was: '$answer'"

          cat << 'EOF' >> $file
# Header: Minimal DockerFile
# User: Klicko
# Version: 0.0.2
#------------------------------------------------------------------------------
FROM centos:centos7
MAINTAINER The Custom CentOS <user@example.com>

RUN yum -y update; yum clean all
RUN yum -y install openssh-server passwd; yum clean all
ADD ./start.sh /start.sh
RUN mkdir /var/run/sshd

RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' 

RUN chmod 755 /start.sh
# EXPOSE 22
RUN ./start.sh
ENTRYPOINT ["/usr/sbin/sshd", "-D"]
EOF

        if [ "$answer" == "yes" ]; then
          echo -e "\tINFO: created default DockerFile: '$file'..."
        else
          echo -e "\tINFO: created new empty file '$file'"
          vi $file  
        fi
      fi   # file ends
      #docker build --build-arg user=what_user Dockerfile
      docker build -t $user/$name_your_image:$tag -f $file .
    fi
  done
}

function dockerCommitCreate() {
  echo -n -e "\tINFO: Commit changes on <container> and [ENTER]: "
  read container
  echo -n -e "\tINFO: Name your New image [ENTER]: "
  read name_your_image
  echo -n -e "\tINFO: Image Tag <stable|latest|master|...> [ENTER]: "
  read tag
  echo -n -e "\tINFO: Commit message [ENTER]: "
  read commit_msg
  echo -n -e "\tINFO: <docker_user|user> [ENTER]: "
  read user
  docker commit -m "$commit_msg" -a "$user" $container $user/name_your_image:tag
}

function execDockerContainer() {
  dockerInfo
  echo -n -e "\tINFO: Exec <container> interactive and press [ENTER]: "
  read container
  docker exec -i -t $container /bin/bash
}

function startDockerContainer() {
  echo -e "\tINFO: Booting '$DOCKER_IMAGE' container..."
  docker pull $DOCKER_IMAGE
  DOCKER_NAME_EXIST=$(docker ps -a --format={{.Names}} -f name=$DOCKER_NAME)
  
  if [ "$DOCKER_NAME" == "$DOCKER_NAME_EXIST" ]; then
    echo -e "\tINFO: Starting existing '$DOCKER_NAME' container..."
    docker start $DOCKER_NAME
  else
    sleep 1
    echo -e "\tINFO: Starting new '$DOCKER_NAME' container in background..."
    if [ "$DOCKER_RUN" == "default" ]; then
      echo -e "\tINFO: 'NO Json Run param';\trunning as daemon with default setting... "
      docker run --name $DOCKER_NAME --tty --detach $DOCKER_IMAGE /bin/bash
    else
      echo -e "\tINFO: run cmd:\t\n\t$DOCKER_RUN"
      eval `$DOCKER_RUN`
    fi
  fi
}

function stopDockerContainer() {
  echo -e "\tINFO Stopping '$DOCKER_NAME' container... "
  docker stop $DOCKER_NAME
}

function dockerContainers() {
  echo -e "\tINFO: read json['containers']; initial docker network"

  #TODO: change NUMBER_CONTAINERS for len of containers
  for i in `seq 0 $NUMBER_CONTAINERS`; do
    search_string=".network.containers[$i].docker_name"
      docker_name=`echo $CAT_FILE | $BIN_DIR/jq $search_string`
      docker_name=`echo ${docker_name:1:-1}` # strip first and last
    search_string=".network.containers[$i].docker_image"
      docker_image=`echo $CAT_FILE | $BIN_DIR/jq $search_string`
      docker_image=`echo ${docker_image:1:-1}`
    search_string=".network.containers[$i].enable"
      e=`echo $CAT_FILE | $BIN_DIR/jq $search_string`
      e=`echo ${e:1:-1}`
    search_string=".network.containers[$i].docker_run"
      docker_run=`echo $CAT_FILE | $BIN_DIR/jq $search_string`
      docker_run=`echo ${docker_run:1:-1}`

    ARR_DOCKER["docker_name_$i"]=$docker_name
    ARR_DOCKER["docker_image_$i"]=$docker_image
    ARR_DOCKER["docker_run_$i"]=$docker_run

    export DOCKER_NAME=$docker_name
    export DOCKER_IMAGE=$docker_image
    export DOCKER_RUN=$docker_run
    #TODO: export INTERACTIVE=false

    if [ "$e" == "true" ]; then
      if [ "$1" == "start" ]; then
        startDockerContainer
      elif [ "$1" == "stop" ]; then
        stopDockerContainer
      fi
    fi
  done
}

function dockerNetworkInspectBridge() {
  echo -e "\tINFO: Inspect Bridge, outpu JSON; https://docs.docker.com/engine/userguide/networking/ "
  docker network inspect bridge
}

function runCmdOnKaliDocker() {
  container_id=$(docker ps -aqf "name=$DOCKER_NAME")
  echo -e "\tINFO: Run command on '$container_id'"
  echo -n -e "\tEnter commands and press [ENTER]: "
  read commands
  docker start $DOCKER_NAME
  docker exec $container_id script /dev/null -c "$commands"
  docker stop $DOCKER_NAME
}

function kaliNetHunter() {
  echo -e "\tINFO: https://www.offensive-security.com/kali-linux-nethunter-download/"
}

#------------------------------------------------------------------------------
# KALI LINUX - ISO IMAGE
#------------------------------------------------------------------------------
function installKaliLinux() {
  APP_DIR=~/Desktop/kali
  KALI_ISO=kali-linux-2016.2-amd64.iso

  mkdir -p $APP_DIR && cd $APP_DIR
  # Download https://www.kali.org/downloads/
  wget http://cdimage.kali.org/current/$KALI_ISO
  wget http://cdimage.kali.org/current/SHA1SUMS
  wget http://cdimage.kali.org/current/SHA1SUMS.gpg
  gpg --verify SHA1SUMS.gpg SHA1SUMS
  # If you don’t get that “Good signature” message or if the key ID doesn’t match, then you should stop the process and review whether you downloaded the images from a legitimate Kali mirror.

  # VERIFY SHA1
  verify_iso_sha1=`sha1sum $KALI_ISO`
  verify_sha_sha1=`grep $KALI_ISO SHA1SUMS`
  echo -e "\tINFO: SHA: `grep $KALI_ISO SHA1SUMS | sha1sum -c`"
  if [ "$verify_iso_sha1" -ne "$verify_sha_sha1" ]; then
    echo -e "\tWARNING: SHA1SUMS differs!"
    echo -e "\tINFO: $verify_sha_sha1"
    echo -e "\tINFO: $verify_iso_sha1"
    exit 0
  fi

  echo -e "\tINFO: Ensure the Origin of the SHA1SUMS File"
  wget -q -O - https://www.kali.org/archive-key.asc | gpg --import
    # or...
    ##$ gpg --keyserver hkp://keys.gnupg.net --recv-key 7D8D0BF6
    ### ...and verify that the displayed fingerprint matches the one below
  gpg --list-keys --with-fingerprint 7D8D0BF6
    ##pub 4096R/7D8D0BF6 2012-03-05 [expires: 2018-02-02]
    ##Key fingerprint = 44C6 513A 8E4F B3D3 0875 F758 ED44 4FF0 7D8D 0BF6
    ##uid Kali Linux Repository <devel@kali.org>
    ##sub 4096R/FC0D0DCB 2012-03-05 [expires: 2018-02-02]

  # get the usb location
    #fdisk -l
  USB_LOCATION=/dev/sdb
  umount /dev/sdb1
  echo -e "\tINFO: Making USB PEN, iso image"
  dd bs=4M if=$KALI_ISO of=$USB_LOCATION

  # to test USB QEMU is a generic and open source machine emulator and virtualizer. 
    #apt-get install qemu
    #sudo qemu-system-x86_64 -usb -usbdevice disk:/dev/sdb
}

#------------------------------------------------------------------------------
# NGINX
#------------------------------------------------------------------------------
# https://docs.docker.com/engine/reference/run/

function serviceNginxStart() {
  echo -e "\tINFO: run cmd from <docker_run> param ..."
  #docker run -d -p 80:80 nginx_proxy service nginx start
}

#------------------------------------------------------------------------------
# RASPBERRY
#------------------------------------------------------------------------------
VERSION_RPI='2.1.2'
function downloadKaliRaspberry() {
  APP_DIR=~/tools/kaliRaspberry
  mkdir -p $APP_DIR && cd $APP_DIR
  echo -e "\tINFO: http://docs.kali.org/kali-on-arm/kali-linux-raspberry-pi2"
  echo -e "\tINFO: default pass: toor"
  echo -e "\tINFO: ARM: https://www.offensive-security.com/kali-linux-arm-images/"
  wget https://images.offensive-security.com/arm-images/kali-$VERSION_RPI.img.xz
}
function microSdRaspberry() {
  echo -e "\tINFO: http://docs.kali.org/kali-on-arm/kali-linux-raspberry-pi2"
  downloadKaliRaspberry
  echo -e "\tINFO: use 'dd' utility to image file to microSD, adjust location!"
  cd $APP_DIR
  xzcat $APP_DIR/kali-$VERSION_RPI.img.xz | dd of=/dev/sdb bs=512k
}

#------------------------------------------------------------------------------
# SQL 
#------------------------------------------------------------------------------
function installSqlVulnerabilityScanner() {
  APP_DIR=~/tools/whitewidow
  echo -e "\tINFO: https://github.com/Ekultek/whitewidow"
  mkdir -p $APP_DIR && cd $APP_DIR
  echo -e "\tINFO: $APP_DIR"
  git clone https://github.com/Ekultek/whitewidow.git $APP_DIR
  bundle install
}
function runSqlVulnerabilityScanner() {
  installSqlVulnerabilityScanner
  ruby whitewidow.rb -d      # in default mode
  #ruby whitewidow.rb -d --proxy <host>:80
}

#------------------------------------------------------------------------------
# HTTP 
#------------------------------------------------------------------------------
WEB_PAGE=xxx.com
function installHttpDos() {
  sudo apt-get install goldeneye
}
function runHttpDos() {
  echo -e "\tWARNING: "
  echo -e "\tWARNING: "
  anonsurf start
  goldeneye $WEB_PAGE
}

function infoHttp() {
  echo -e "\tINFO: "Is It Down Right Now" monitors the status of your \
    favorite web sites and checks whether they are down or not."
  wget http://www.isitdownrightnow.com
}

#------------------------------------------------------------------------------
# PARROT
#------------------------------------------------------------------------------
# Parrot includes by default TOR, I2P, anonsurf, gpg, tccf, zulucrypt,
# veracrypt, truecrypt, luks and many other tecnologies designed to defend 
# your privacy and your identity. Linux Distro PEN DRIVE

function installParrot() {
  echo -e "\tINFO: PARROR linux security distro"
  echo -e "\tTODO"
}

function installTails() {
  echo -e "\tINFO: https://tails.boum.org/"
  echo -e "\tTODO"
}

#------------------------------------------------------------------------------
# BROTE FORCE  -  Patator
#------------------------------------------------------------------------------
# is a universal tool brute force, having on board a decent numberof modules

function installPatator() {
  echo -e "\tINFO: Patator is a universal tool brute force with modules"
  echo -e "\tINFO: https://github.com/lanjelot/patator"
  APP_DIR=~/tools/patator
  mkdir -p $APP_DIR && cd $APP_DIR
  git clone https://github.com/lanjelot/patator.git $APP_DIR
}

function helpPatator() {
  cd $APP_DIR
  ./patator.py module --help
}

function runPatatorSsh() {
  cd $APP_DIR
  ./patator.py module ssh_login user=root \
  password=FILE0 0=/usr/share/wordlists/fern-wifi/common.txt \
  host=192.168.1.10 -x ignore:mesg='Authentication failed'
}

function infoPenetrationTesting() {
  echo -e "\tINFO: https://youtube.com/penetrationtestingwithddos"
  echo -e "\tINFO: http://kali-linux.co"
}

#------------------------------------------------------------------------------
# JSON
#------------------------------------------------------------------------------
function downloadJsonBashParser() {
  echo -e "\tINFO: https://stedolan.github.io/jq/tutorial/"
  if [ -e "$BIN_DIR/jq" ]; then
    echo -e "\tINFO: $BIN_DIR/jq exists."
  else
  echo -e "\tINFO: Coping json parser for bash into $BIN_DIR/jq ..."
    curl http://stedolan.github.io/jq/download/linux64/jq -o $BIN_DIR/jq
    #wget http://stedolan.github.io/jq/download/linux64/jq $BIN_DIR/jq
    chmod a+x $BIN_DIR/jq
  fi
}

function readJson2 {
  UNAMESTR=`uname`
  if [[ "$UNAMESTR" == 'Linux' ]]; then
    SED_EXTENDED='-r'
  elif [[ "$UNAMESTR" == 'Darwin' ]]; then
    SED_EXTENDED='-E'
  fi;

  VALUE=`grep -m 1 "\"${2}\"" ${1} | sed ${SED_EXTENDED} 's/^ *//;s/.*: *"//;s/",?//'`

  if [ ! "$VALUE" ]; then
    echo "Error: Cannot find \"${2}\" in ${1}" >&2;
    exit 1;
  else
    echo $VALUE
  fi;
}
#[VAR]=readJson2 [filename] [key] || exit [code]

#------------------------------------------------------------------------------
# LINUX
#------------------------------------------------------------------------------
linuxAddToEtcHosts() {
    string="81.2.254.221 tibetanmedicine.com"
    file='/etc/hosts'
    $string >> $file
}
#------------------------------------------------------------------------------

source ~/code/network/setenvs
declare -a ARR_DOCKER
declare -r CAT_FILE=`cat $SETUP_DIR/main.json`         # read only
downloadJsonBashParser

#declare -f                                             # lists the function above;
#declare -i integer_variable
#declare -x OUTPUT="output of the current file"

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "#--------------------------------------------------------------------"
      echo "#  APP: $APP_NAME"
      echo "#--------------------------------------------------------------------"
      echo -e "\t-h|--help                       Help"
      echo ""
      echo "# START|STOP SERVICE:"
      echo "#--------------------------------------------------------------------"
      echo -e "\t-sdn |--start_docker_network    Start network of containers"
      echo -e "\t-stdn|--stop_docker_network     Stop network of containers"
      echo ""
      echo "# DOCKER"
      echo "#--------------------------------------------------------------------"
      echo -e "\t-di  |--docker_info             Local Info"
      echo -e "\t-dbi |--docker_build_images     Build; configuration stored in json under ['dockerFiles']"
      echo -e "\t-dciu|--docker_cleanup          Remove Unused Images, exited Containers"
      echo -e "\t-dci |--docker_container_ips    Get IPs of Containers"
      echo -e "\t-dcu |--docker_containers_up    Get IP of the <container_ids>"
      echo -e "\t-dcc |--docker_commit_create    Commit changes on container and create new image of it"
      echo -e "\t-dec |--docker_exec_container   Start Container in interactive mode"
      echo -e "\t-drc |--docker_remove_container          Remove one Container"
      echo -e "\t-drec|--docker_remove_exited_containers  Remove exited dockers"
      echo -e "\t-dsr |--docker_search_repos     Search <string> in docker repos"
      echo ""
      echo "# RUN"
      echo "#--------------------------------------------------------------------"
      echo -e "\t-rad |--run_ansible_docker      run ansible docker centos ia"
      echo -e "\t-radd|--run_ansible_docker_deb8 run ansible doc deb interactive"
      echo -e "\t-rka |--run_kafka_docker        run kafka docker interactive"
      echo -e "\t-rkd |--run_kali_docker         run kali docker interactive"
      echo -e "\t-rckd|--run_cmd_on_kali_docker  run command on kali docker"
      #echo -e "\t-rt  |--run_tails       TODO run linux distro tails for privacy"
      #echo -e "\t-rp  |--run_parrot      TODO run linux security disto tails"
      echo ""
      echo "# GIT & INSTALL"
      echo "#--------------------------------------------------------------------"
      echo -e "\t-iku |--install_kali_usb        download $ verify sha1 $ install Kali on usb drive"
      echo -e "\t-iss |--install_raspberry_sd    download and do image on microSD"
      echo -e "\t-gi  |--git_info                git info about current repo"
      echo ""
      echo "#--------------------------------------------------------------------"
      exit 0
      ;;
    -gi|--git_info)
      echo -e "\tINFO: Revisiting Commits"
      git log --pretty=format:"%h - %an, %ar : %s"
      echo -e "\tINFO: about last commit"
      git log -1
      echo -e "\tINFO: stats about last commit"
      git diff --stat HEAD
      echo -e "\tINFO: Show detail changes for last commit"
      git log -p -2
      ;;
    -rp|--run_parrot)
      installParrot
      ;;
    -rt|--run_tails)
      installTails
      ;;
    -di|--docker_info)
      dockerInfo
      getDockerContainerIps
      ;;
    -dbi|--docker_build_images)
      dockerBuildImagesFromFiles
      ;;
    -dsr|--docker_search_repos)
      searchDockerRepos
      ;;
    -dci|--docker_container_ips)
      getDockerContainerIps
      ;;
    -dcu|--docker_containers_up)
      checkDockerContainerUp
      ;;
    -dcc|--docker_commit_create)
      dockerCommitCreate
      ;;
    -dec|--docker_exec_container)
      execDockerContainer
      ;;
    -drc|--docker_remove_container)
      removeOneContainer
      ;;
    -drec|--docker_remove_exited_containers)
      removeDockers exited
      ;;
    -dciu|--docker_cleanup)
      dockerCleanup
      ;;
    -sdn|--start_docker_network)
      dockerContainers start
      dockerInfo
      getDockerContainerIps
      ;;
    -stdn|--stop_docker_network)
      dockerContainers stop
      dockerInfo
      ;;
    -isu|--install_kali_usb)
      installKaliLinux
      ;;
    -iss|--install_raspberry_sd)
      microSdRaspberry
      ;;
    -rkd|--run_kali_docker)
      echo -e "\tINFO: https://hub.docker.com/r/kalilinux/kali-linux-docker/"
      export DOCKER_NAME='kali_linux'
      export DOCKER_IMAGE=kalilinux/kali-linux-docker
      runImageDocker
      ;;
    -rka|--run_kafka_docker)
      echo -e "\tINFO: https://hub.docker.com/r/wurstmeister/kafka"
      export DOCKER_NAME='kafka'
      export DOCKER_IMAGE=wurstmeister/kafka
      runImageDocker
      ;;
    -radd|--run_ansible_docker_debian8)
      echo -e "\tINFO: https://hub.docker.com/r/williamyeh/ansible/"
      export DOCKER_NAME='ansible_debian8'
      export DOCKER_IMAGE=williamyeh/ansible:debian8
      runImageDocker
      ;;
    -rad|--run_ansible_docker)
      echo -e "\tINFO: https://hub.docker.com/r/williamyeh/ansible/"
      export DOCKER_NAME='ansible_centos7'
      echo -e "\tTODO: add os versions"
      export DOCKER_IMAGE=williamyeh/ansible:centos7
      runImageDocker
      ;;
    -rckd|--run_cmd_on_kali_docker)
      runCmdOnKaliDocker
      ;;
    --test)
      for i in `seq 0 $XY`; do
        echo "test: $i"
      done
      ;;
    *)
      break
      ;;
  esac
  exit 0
done
