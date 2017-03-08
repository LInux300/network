#!/bin/bash

function installGo() {
  mkdir -p $HOME/go/work
  mkdir -p $HOME/go && cd $HOME/go
  go_version_file="go$GO_VERSION.linux-amd64.tar.gz"
  echo -e "INFO: https://storage.googleapis.com/golang/$go_version_file"
  curl -O https://storage.googleapis.com/golang/$go_version_file
  sha256sum_original="53ab94104ee3923e228a2cb2116e5e462ad3ebaeea06ff04463479d7f12d27ca  go1.8.linux-amd64.tar.gz"
  sha256sum_download="`sha256sum $go_version_file`"
  echo -e "INFO: sha256sum original: $sha256sum_original"
  echo -e "INFO: sha256sum download: $sha256sum_download"
  echo -e "INFO: Go file: $go_version_file"
  if [ "$sha256sum_original" ==  "$sha256sum_download" ]; then
    echo -e "INFO: sha256sum: OK"
    tar xvf $go_version_file
    mv go go$GO_VERSION
  else
    echo -e "INFO: sha256sum: BAD"
    exit 1
  fi
}

function installPipPackage() {
  echo -e "\tINFO: Install $PACKAGE_NAME"
  sourcePythonPip
  which python
  pip install --install-option="--prefix=$HOME/.local" $PACKAGE_NAME
  which $PACKAGE_NAME
}

function installAnsible() {
  # http://www.alphadevx.com/a/390-Installing-Ansible-on-Linux
  #cd $HOME
  #git clone git://github.com/ansible/ansible.git --recursive
  #cd ./ansible
  echo -e "\tINFO: Install Ansible"
  sourcePythonPip
  which python
  pip install --install-option="--prefix=$HOME/.local" ansible
  which ansible
}

function installPython() {
  # http://thelazylog.com/install-python-as-local-user-on-linux/
  mkdir -p $HOME/python && cd $HOME/python
  wget https://www.python.org/ftp/python/$VERSION/Python-$VERSION.tgz
  tar zxfv Python-$VERSION.tgz
  find $HOME/python -type d | xargs chmod 0755
  cd Python-$VERSION
  ./configure --prefix=$HOME/python
  make && make install
}

function installPip() {
  # https://pip.pypa.io/en/stable/reference/pip_install/
  wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py -O - | python - --user
}

function installRuby() {
  # https://www.ruby-lang.org/en/downloads/
  mkdir -p $HOME/ruby && cd $HOME/ruby
  echo -e "\tINFO: https://cache.ruby-lang.org/pub/ruby/$RUBY_VERSION/ruby-$RUBY_VERSION.$RUBY_VERSION_SUB.tar.gz"
  wget https://cache.ruby-lang.org/pub/ruby/$RUBY_VERSION/ruby-$RUBY_VERSION.$RUBY_VERSION_SUB.tar.gz
  tar -xzf ruby-$RUBY_VERSION.$RUBY_VERSION_SUB.tar.gz
  find $HOME/ruby -type d | xargs chmod 0755
  cd ruby-$RUBY_VERSION.$RUBY_VERSION_SUB
  ./configure --prefix=$HOME/ruby
  make && make install
}

function sourceGo() {
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
    'export GOROOT=$HOME/go/go'$GO_VERSION
    'export GOPATH=$HOME/go/work'
    'export GOBIN=$GOROOT/bin'
    'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin'
  )
  for line in "${LINES[@]}"; do
    if ! grep -qF "$line" $file ; then echo "$line" >> $file ; echo -e "\tINFO: '$line' added into '$file'"; fi
  done
  echo -e "\tINFO: cat $file"
  cat $file
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


SETENVS_FILE="$HOME/code/network/setenvs"
VERSION="2.7.13"
GO_VERSION="1.8"
RUBY_VERSION="2.4"
RUBY_VERSION_SUB="0"

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "#--------------------------------------------------------------------"
      echo "#  APP: $APP_NAME"
      echo "#--------------------------------------------------------------------"
      echo -e "\t-h|--help                       Help"
      echo ""
      echo "#--------------------------------------------------------------------"
      echo -e "\t-ia |--install_ansible       Install Ansible as Local User"
      echo -e "\t-ig |--install_go            Install Ansible as Local User"
      echo -e "\t-ipp|--install_pip_package   Install package via pip"
      echo -e "\t-ip |--install_python_pip    Install Python&Pip as Local User"
      echo -e "\t-ir |--install_ruby_sinatra  Install Ruby as Local User"
      echo -e "\t-sr |--source_ruby_sinatra   Source Ruby as Local User"
      echo "#--------------------------------------------------------------------"
      exit 0
      ;;
    -ig|--install_go)
      installGo;
      sourceGo;
      ;;
    -ia|--install_ansible)
      installAnsible;
      ;;
    -ipp|--install_pip_package)
      echo -n "Enter <pip package> and install to $HOME/.local [ENTER]: "
  read PACKAGE_NAME
      installPipPackage;
      ;;
    -ip|--install_python)
      #installPython
      #installPip
      sourcePythonPip
      pip install --upgrade pip
      which pip
      ;;
    -ir|--install_ruby)
      installRuby;
      sourceRuby;
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


