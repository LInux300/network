#!/bin/bash

#. ~/.sshagent >/dev/null 2>&1
DIR_NAME=$(dirname $(readlink -f $0))
. $DIR_NAME/setenvs

APP_DIR=~/rkhunter
APP_NAME="rkhunter"

DOWNLOAD_VERSION="1.4.2"
DOWNLOAD_FILE_TYPE="tar.gz"
DOWNLOAD_NAME="$APP_NAME-$DOWNLOAD_VERSION.$DOWNLOAD_FILE_TYPE"
DOWNLOAD_LINK="http://downloads.sourceforge.net/project/rkhunter/rkhunter/1.4.2/$DOWNLOAD_NAME"
DOWNLOAD_DIR=~/Downloads
DOWNLOAD_STRING="$DOWNLOAD_DIR/$APP_NAME.$DOWNLOAD_FILE_TYPE"

function configureRkhunter() {
  echo -e "\t\t\tINFO: configure '$APP_NAME' conf file"
  cat $APP_DIR/files/rkhunter.conf
  echo -e "\t\t\tTODO"
}

function debugRkhunter() {
  $APP_DIR/files/rkhunter --propupd --check --sk --debug
  # create the file in '/tmp' and not in current dir
  # finished with testing run
  # cd /tmp
  # /bin/rm -rf rth
}

function downloadApp() {
  echo -e "\t\t\tDownload: $APP_NAME"
  mkdir -p $DOWNLOAD_DIR
  wget $DOWNLOAD_LINK -O $DOWNLOAD_STRING
}

function installApp() {
  echo -e "\t\t\tInstall: $APP_NAME"
  $APP_DIR/installer.sh --layout custom . --install
}

function readme() {
  cat $APP_DIR/files/README
}

function removeApp() {
  echo -e "\t\t\tINFO: remove: '$APP_NAME'"
  $APP_DIR/installer.sh --layout custom $APP_DIR --remove
}

function runRkhunter() {
  $APP_DIR/files/rkhunter --propupd --check --sk
}

function saveSource() {
  downloadApp
  echo -e "\t\t\tINFO: save source: '$APP_NAME'"
  mkdir -p $APP_DIR && cd $APP_DIR
  mv $DOWNLOAD_STRING .
  echo -e "\t\t\tINFO: location: '$APP_DIR/$APP_NAME.$DOWNLOAD_FILE_TYPE'"
}

function sendNotification() {
  traceLog
  echo -e "\t\t\tINFO: send notification: '$APP_NAME'"
  echo -e "\t\t\tINFO: TODO !!!"
}

function tailRkhunter() {
  echo -e "\t\t\tINFO: Tail '$APP_NAME' log file"
  tail -100l $APP_DIR/files/rkhunter.log
}

function traceLog() {
  echo -e "\t\t\tINFO: trace: '$APP_NAME' log file"
  echo -e "\t\t\tINFO: TODO !!!"
}

function untarApp() {
  echo -e "\t\t\tUntar: $APP_NAME"
  mkdir -p $APP_DIR && cd $APP_DIR
  echo $DOWNLOAD_STRING
  tar -xvzf $DOWNLOAD_STRING --strip 1
}

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "#--------------------------------------------------------------------"
      echo "#  App: $APP_NAME"
      echo "#--------------------------------------------------------------------"
      echo "Options:"
      echo ""
      echo -e "\t-h|--help           help"
      echo -e "\t--configure         configure"
      echo -e "\t--debug             debug in /tmp run audit as sudo"
      echo -e "\t--install           download, untar, install as local"
      echo -e "\t--readme            README"
      echo -e "\t--remove            remove: '$APP_NAME'"
      echo -e "\t--run               run audit (sudo)"
      echo -e "\t--save              save source to $APP_DIR"
      echo -e "\t--send_notification send message"
      echo -e "\t--tail_log          tail log file"
      echo -e "\t--trace_log         trace log file"
      echo ""
      echo "#--------------------------------------------------------------------"
      exit 0
      ;;
    --configure)
      echo -e "\t\t\tINFO: configure '$APP_NAME'"
      configureRkhunter
      ;;
    --debug)
      echo -e "\t\t\tINFO: debug mode '$APP_NAME'"
      debugRkhunter
      ;;
    --install)
      echo -e "\t\t\tINFO: install '$APP_NAME'"
      downloadApp
      untarApp
      installApp
      ;;
    --readme)
      echo -e "\t\t\tINFO: README '$APP_NAME'"
      readme
      ;;
    --remove)
      echo -e "\t\t\tINFO: remove '$APP_NAME'"
      removeApp
      ;;
    --run)
      echo -e "\t\t\tINFO: run '$APP_NAME'"
      runRkhunter
      ;;
    --save)
      echo -e "\t\t\tINFO: save source '$APP_NAME' to $APP_DIR"
      saveSource
      ;;
    --send_notification)
      echo -e "\t\t\tINFO: send notification from '$APP_NAME'"
      sendNotification
      ;;
    --tail_log)
      echo -e "\t\t\tINFO: tail log of '$APP_NAME'"
      tailRkhunter
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

