#!/bin/bash

#. ~/.sshagent >/dev/null 2>&1
DIR_NAME=$(dirname $(readlink -f $0))
. $DIR_NAME/setenvs

APP_DIR=~/lynis
APP_NAME="lynis"

DOWNLOAD_LINK="https://github.com/CISOfy/lynis.git"

CRON_DAILY_FILE="/etc/cron.daily/lynis"

LOG_FILE=/tmp/lynis.log
REPORT_FILE=/tmp/lynis-report.dat

function configureApp() {
  echo -e "\t\tINFO: configure '$APP_NAME' conf file"
  less $APP_DIR/default.prf
  cd $APP_DIR && echo -e "\t\tINFO: `./lynis show profiles`"
  #echo -e "\t\tINFO: read '$APP_NAME/custom.prf'"
  #less $APP_DIR/custom.prf
}

function cronCreateDaily() {
  echo -e "\t\tINFO: cronjob: $APP_NAME"
  cat <<<'#!/bin/sh

AUDITOR="automated"
DATE=$(date +%Y%m%d)
HOST=$(hostname)
LOG_DIR="/var/log/lynis"
REPORT="$LOG_DIR/report-${HOST}.${DATE}"
DATA="$LOG_DIR/report-data-${HOST}.${DATE}.txt"

cd /usr/local/lynis

# Run Lynis
./lynis audit system --auditor "${AUDITOR}" --cronjob > ${REPORT}

# Optional step: Move report file if it exists
if [ -f /var/log/lynis-report.dat ]; then
    mv /var/log/lynis-report.dat ${DATA}
fi

# The End
' > $CRON_DAILY_FILE
  chmod +x $CRON_DAILY_FILE
  echo -e "\t\tINFO: `ls -la $CRON_DAILY_FILE`"
}

function cronCreateWeekly() {
  echo -e "\t\tINFO: cron weekly '$APP_NAME' TODO"
  cat <<'EOF' >> /etc/cron.weekly/lynis
#!/bin/bash
EOF
}

function cronjobApp() {
  cronCreateDaily
}

function collector() {
  echo -e "\t\tINFO: It collects reports from many systems and uploads it in one batch."
  echo -e "\t\tINFO: https://cisofy.com/documentation/lynis/collector/#installation"
  echo -e "\t\tINFO: https://packages.cisofy.com/"
}

function debugApp() {
  echo -e "\t\tINFO: debug: $APP_NAME"
}

function downloadApp() {
  echo -e "\t\tINFO: download: $APP_NAME"
  git clone $DOWNLOAD_LINK $APP_DIR
}

function infoApp() {
  echo -e "\t\tINFO: '$APP_DIR/$APP_NAME'"
  echo -e "\t\tINFO: wget https://packacisofy.com"
  echo -e "\t\tINFO: `ls -la $APP_DIR/$APP_NAME`"
  cd $APP_DIR && ./lynis help
  ./lynis show 
  ./lynis show help
  ./lynis show os
  ./lynis show commands
}

function installApp() {
  echo -e "\t\tINFO: install: $APP_NAME"
  downloadApp
}

function readme() {
  echo -e "\t\tINFO: readme: '$APP_NAME'"
  less $APP_DIR/README
}

function reportApp() {
  echo -e "\t\tINFO: report: '$APP_NAME'"
  less $REPORT_FILE
}

function removeApp() {
  echo -e "\t\tINFO: remove: '$APP_NAME'"
}

function runApp() {
  echo -e "\t\tINFO: run: '$APP_NAME'"
  cd $APP_DIR && ./lynis audit system -Q
  #./lynis --check-all --no-log --quick # -c deprecated
}

function runCronApp() {
  # to see only warning
  #cd $APP_DIR && ./lynis --check-all --cronjob --quiet
  cd $APP_DIR && ./lynis audit system --cronjob --quiet
}

function runAppWithPause() {
  #pause_between_tests can be used to increase the wait\
  # time between tests. 
  sudo ./lynis audit system --profile pause_between_tests
  sudo ./lynis audit system --profile 
}

function saveSource() {
  echo -e "\t\tINFO: save source: '$APP_NAME'"
  echo -e "\t\tINFO: TODO !!!"
}

function sendNotification() {
  traceLog
  echo -e "\t\tINFO: send notification: '$APP_NAME'"
  echo -e "\t\tINFO: TODO !!!"
  
}

function tailApp() {
  echo -e "\t\tINFO: Tail '$APP_NAME' log file"
  #tail -100l $LOG_FILE
  less $LOG_FILE
}

function traceLogApp() {
  echo -e "\t\tINFO: trace: '$APP_NAME' log file"

  echo -e "\t\tWARNING: number of Warnings: \
    `awk '/Warning/{n++}; END {print n+0}' $LOG_FILE`"
  echo -e "\t\tWARNING: \n`awk '/Warning/' $LOG_FILE`"

  echo -e "\t\tERROR: number of Erorrs: \
    `awk '/Error/{n++}; END {print n+0}' $LOG_FILE`"
  echo -e "\t\tERROR: \n`awk '/Error/'  $LOG_FILE`"

  echo -e "\t\tWARNING: number of 'different value': \
    `awk '/different value/{n++}; END {print n+0}' $LOG_FILE`"
  echo -e "\t\tWARNING: \n`awk '/different value/'  $LOG_FILE`"

  echo -e "\t\tWARNING: number of 'root permission': \
    `awk '/root permission/{n++}; END {print n+0}' $LOG_FILE`"
  echo -e "\t\tWARNING: \n`awk '/root permission/'  $LOG_FILE`"

  echo -e "\t\tINFO: number of 'Suggestions': \
    `awk '/Suggestion/{n++}; END {print n+0}' $LOG_FILE`"
  echo -e "\t\tINFO: \n`awk '/Suggestion/'  $LOG_FILE`"

  # TODO 
  echo -e "\t\tINFO: https://cisofy.com/controls/KRNL-5830/"
  #echo -e "\t\tINFO: number of '[test': \
  #  `awk '/Suggestion/{n++}; END {print n+0}' $LOG_FILE`"
  #echo -e "\t\tINFO: \n`awk '/Suggestion/'  $LOG_FILE`"

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
      echo -e "\t--cronjob           run lynis as cronjob"
      echo -e "\t--configure         configure"
      echo -e "\t--debug             debug in /tmp run audit as sudo"
      echo -e "\t--install           download, untar, install as local"
      echo -e "\t--readme            README"
      echo -e "\t--remove            remove: '$APP_NAME'"
      echo -e "\t--report            report: '$REPORT_FILE'"
      echo -e "\t--run               run audit (sudo)"
      echo -e "\t--run_cron          run audit cron (sudo)"
      echo -e "\t--save              save source to $APP_DIR"
      echo -e "\t--send_notification send message"
      echo -e "\t--tail_log          tail log file"
      echo -e "\t--trace_log         trace log file"
      echo ""
      echo "#--------------------------------------------------------------------"
      exit 0
      ;;
    --cronjob)
      echo -e "\t\tINFO: cronjob '$APP_NAME'"
      cronjobApp
      ;;
    --configure)
      echo -e "\t\tINFO: configure '$APP_NAME'"
      configureApp
      ;;
    --debug)
      echo -e "\t\tINFO: debug mode '$APP_NAME'"
      debugApp
      ;;
    --info)
      echo -e "\t\tINFO: install '$APP_NAME'"
      infoApp
      ;;
    --install)
      echo -e "\t\tINFO: install '$APP_NAME'"
      installApp
      ;;
    --readme)
      echo -e "\t\tINFO: README '$APP_NAME'"
      readme
      ;;
    --remove)
      echo -e "\t\tINFO: remove '$APP_NAME'"
      removeApp
      ;;
    --report)
      echo -e "\t\tINFO: report '$APP_NAME'"
      reportApp
      ;;
    --run)
      echo -e "\t\tINFO: run '$APP_NAME'"
      runApp
      ;;
    --run_cron)
      echo -e "\t\tINFO: run '$APP_NAME' as cron"
      runCronApp
      ;;
    --save)
      echo -e "\t\tINFO: save source '$APP_NAME' to $APP_DIR"
      saveSource
      ;;
    --send_notification)
      echo -e "\t\tINFO: send notification from '$APP_NAME'"
      sendNotification
      ;;
    --tail_log)
      echo -e "\t\tINFO: tail '$APP_NAME' log"
      tailApp
      ;;
    --trace_log)
      echo -e "\t\tINFO: trace '$APP_NAME' log"
      traceLogApp
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

