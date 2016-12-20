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
# KALI DOCKER
#------------------------------------------------------------------------------
function runImageDocker() {
  echo -e "\tINFO: Run $DOCKER_IMAGE"
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
      echo "# KALI LINUX:"
      echo "#--------------------------------------------------------------------"
      echo -e "\t--install_kali             download & install Kali"
      echo ""
      echo "# KALI DOCKER:"
      echo "#--------------------------------------------------------------------"
      echo -e "\t--run_kali_docker         run kali docker interactive"
      echo -e "\t--run_cmd_on_kali_docker  run command on kali docker"
      echo ""
      echo "# KAFKA:"
      echo "#--------------------------------------------------------------------"
      echo -e "\t--run_kafka_docker        run kafka docker interactive"
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
    --install_kali)
      installKaliLinux
      ;;
    --run_kali_docker)
      echo -e "\tINFO: https://hub.docker.com/r/kalilinux/kali-linux-docker/"
      export DOCKER_NAME='kali-linux'
      export DOCKER_IMAGE=kalilinux/kali-linux-docker
      runImageDocker
      ;;
    --run_kafka_docker)
      export DOCKER_NAME='kafka'
      export DOCKER_IMAGE=wurstmeister/kafka
      runImageDocker
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

