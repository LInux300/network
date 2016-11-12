#!/bin/bash

TITLE="System Information for $HOSTNAME"
RIGHT_NOW=$(date +"%x %r %Z")
TIME_STAMP="Updated on $RIGHT_NOW by $USER"
echo "$TITLE  $RIGHT_NOW by $USER"

fileDirTimeDate() {
  # input:  file or directory
  # output: 2016-06-29 19:45:29.227312397 +0200
  if [ ! "$1" ]
  then
    file_dir_name='.'
  else
    file_dir_name=$1
  fi

  echo ""
  echo "#  Time and Date of: '$file_dir_name' is:"
  echo "#----------------------------------------------------------------------"
  echo "      $(stat -c %y $file_dir_name)"
}


printParams()  {
  array_params=$1
  eval echo \${$array_params[*]}
  return
}

printScriptParams() {
  echo ""
  echo "#  Print Script's Parametrs of: ${ARR_PARAMS[0]}"
  echo "#----------------------------------------------------------------------"
  echo "      Indexes: ${!ARR_PARAMS[@]}"
  echo "      Params: ${ARR_PARAMS[@]}"
  
  for name in ${ARR_PARAMS[@]}
  do
    echo "      Show param: $name"
  done
}

readScriptParams() {
  for name in ${SCRIPT_PARAMS[@]}
  do
    echo "      Show param via export: $name"
  done
}

#------------------------------------------------------------------------------
# Initial Script
#------------------------------------------------------------------------------

addUser() {
  sudo apt-get update
  sudo adduser $1
  #sudo visudo
}

sshPubKey() {
  # Generate pub key
  ssh-keygen -t rsa -b 4
}

# GIT
# sudo add-apt-repository ppa:git-core/ppa
#------------------------------------------------------------------------------

gitInstall() {
  USER="rv"
  EMAIL="support@example.com"

  sudo apt-get install git-core
  git --version
  git config --global user.name $USER
  git config --global user.email $EMAIL
}



# Shell In a Box - WEB
#------------------------------------------------------------------------------
# https://help.ubuntu.com/community/shellinabox
# xxx.yyy.zzz.vvv:4200

shellinaboxInstall() {
  sudo apt-get install shellinabox
  sudo service shellinabox start
  
  sudo vim /etc/default/shellinabox
' change port to 443'
  sudo invoke-rc.d shellinabox restart

  # web based terminal emulator ubuntu
  # http://www.tecmint.com/linux-terminal-emulators/

  # On Fedora, CentOS or RHEL
  # $ sudo systemctl enable shellinaboxd.service
  # $ sudo systemctl start shellinaboxd.service 
 
  sudo netstat -nap | grep shellinabo
}


sshAgent() {
  eval "$(ssh-agent -s)"
  # Agent pid 42343
}

installRepos() {
  # Install repos
  mkdir ~/code
}

info() {
  # IP
  #------------------------------------------------------------------------------
  echo GET IP INFO: http://www.infobyip.com
}

declaration() {
  declare -F
  #declare -i
}

checkFilesDirs() {
  # The shell variable "$@" contains the list of command line arguments.
  # This technique is often used to process a list of files on the command line. 
  # Here is a another example:
  for filename in "$@"; do
    result=
    if [ -f "$filename" ]; then
        result="$filename is a regular file"
    else
        if [ -d "$filename" ]; then
            result="$filename is a directory"
        fi
    fi
    if [ -w "$filename" ]; then
        result="$result and it is writable"
    else
        #touch $result 
        result="$result and it is not writable"
    fi
    echo "$result"
  done
}


main() {
  echo "#----------------------------------------------------------------------"
  echo "#  Initial.sh  "
  echo "#----------------------------------------------------------------------"
  local -n ARR_PARAMS
  ARR_PARAMS=$2
  #printParams ARR_PARAMS
  #printScriptParams 
  
  readScriptParams
  #addUser "test"
  #info

  local -n SHELL_VARIABLES

  fileDirTimeDate $1
}

#export SCRIPT_PARAMS=($0 $1 $2 $3)
export SCRIPT_PARAMS=($@)
main $1 SCRIPT_PARAMS

checkFilesDirs $@
