#!/bin/bash

function installPython() {
  # http://thelazylog.com/install-python-as-local-user-on-linux/
  mkdir -p ~/python && cd ~/python
  wget https://www.python.org/ftp/python/$VERSION/Python-$VERSION.tgz
  tar zxfv Python-$VERSION.tgz
  find ~/python -type d | xargs chmod 0755
  cd Python-$VERSION
  ./configure --prefix=$HOME/python
  make && make install
}

function installPip() {
  wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py -O - | python - --user
}

function sourcePythonPip() {
  file=$SETENVS_FILE
  echo -e "\tINFO: Add into $file"
  if [ ! -e "$file" ] ; then
    touch "$file"
  fi
  if [ ! -w "$file" ] ; then
    echo -e "\tINFO: cannot write to $file"
    exit 1
  fi

  declare -a LINES=(
    'export PATH=$HOME/python/Python-'$VERSION'/:$PATH'
    'export PYTHONPATH=$HOME/python/Python-'$VERSION
    'export PATH=$PATH:$HOME/.local/bin'
  )
  for line in "${LINES[@]}"; do
    if ! grep -qF "$line" $file ; then echo "$line" >> $file ; echo -e "\tINFO: '$line' added into '$file'"; fi
  done
  echo -e "\tINFO: cat $file"
  cat $file
}


SETENVS_FILE="setenvs.dev"
VERSION="2.7.13"

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "#--------------------------------------------------------------------"
      echo "#  APP: $APP_NAME"
      echo "#--------------------------------------------------------------------"
      echo -e "\t-h|--help                       Help"
      echo ""
      echo "#--------------------------------------------------------------------"
      echo -e "\t-ip |--install_python    Install Python as Local User"
      echo "#--------------------------------------------------------------------"
      exit 0
      ;;
    -ip|--install_python)
      installPython
      installPip
      sourcePythonPip
      pip install --upgrade pip
      which pip
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


