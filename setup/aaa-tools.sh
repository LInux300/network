#!/bin/bash
DIR_NAME=$(dirname $(readlink -f $0))
. $DIR_NAME/setenvs

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
  docker images
  echo -e "\tINFO: Docker Containers"
  docker ps -a
  echo -e "\tINFO: Running Containers"
  docker ps -a -f status=running
  echo -e "\tINFO: State of Running Containers"
  docker ps -q
}

function removeExitedDockers() {
  docker rm `docker ps -aq -f status=exited`
}

function searchDockerRepos() {
  echo -n "Enter search text and press [ENTER]: "
  read search
  docker search --stars=3 --no-trunc --automated $search
}

#------------------------------------------------------------------------------
# KALI
#------------------------------------------------------------------------------
DOCKER_NAME='kali-linux' && DOCKER_IMAGE=kalilinux/kali-linux-docker
function runKaliDocker() {
  echo -e "\tINFO: Run $DOCKER_IMAGE"
  echo -e "\tINFO: https://hub.docker.com/r/kalilinux/kali-linux-docker/"
  docker pull $DOCKER_IMAGE
  DOCKER_NAME_EXIST=$(docker ps -a --format={{.Names}} -f name=$DOCKER_NAME)
  if [ "$DOCKER_NAME" == "$DOCKER_NAME_EXIST" ]; then
    echo -e "\tINFO: Container '$DOCKER_NAME' already exists"
    docker ps -a | grep $DOCKER_NAME
    docker start $DOCKER_NAME
    docker attach $DOCKER_NAME
  else
    docker run --name $DOCKER_NAME -it $DOCKER_IMAGE /bin/bash
  fi
}

function runCmdOnKaliDocker() {
    container_id=$(docker ps -aqf "name=$DOCKER_NAME")
    echo -e "\tINFO: run command on $container_id"
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

function downloadParrot() {
  echo -e "\tINFo: PARROR linux security distro"
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
# LINUX
#------------------------------------------------------------------------------
linuxAddToEtcHosts() {
    string="81.2.254.221 tibetanmedicine.com"
    file='/etc/hosts'
    $string >> $file
}
#------------------------------------------------------------------------------


while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "#--------------------------------------------------------------------"
      echo "#  App: $APP_NAME"
      echo "#--------------------------------------------------------------------"
      echo "# OPTIONS:"
      echo -e "\t-h|--help                 help"
      echo ""
      echo "# DOCKER:"
      echo "#--------------------------------------------------------------------"
      echo -e "\t--docker_info             docker local info"
      echo -e "\t--remove_exited_dockers   remove exited dockers"
      echo -e "\t--search_docker_repos     search for string in docker reposr"
      echo ""
      echo "# KALI:"
      echo "#--------------------------------------------------------------------"
      echo -e "\t--run_kali_docker         run kali docker interactive"
      echo -e "\t--run_cmd_on_kali_docker  run command on kali docker"
      echo ""
      echo "# RASPBERRY:"
      echo "#--------------------------------------------------------------------"
      echo -e "\t--micro_sd_raspberry      download and do image on microSD"
      exit 0
      ;;
    --docker_info)
      dockerInfo
      ;;
    --remove_exited_dockers)
      removeExitedDockers
      ;;
    --search_docker_repos)
      searchDockerRepos
      ;;
    --run_kali_docker)
      runKaliDocker
      ;;
    --run_cmd_on_kali_docker)
      runCmdOnKaliDocker
      ;;
    --micro_sd_raspberry)
      microSdRaspberry
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

