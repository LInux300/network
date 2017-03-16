#!/bin/bash

function ldapSearch() {
  # http://www.flatmtn.com/article/setting-ldap-back-sql
  ldapsearch -x -b 'dc=example,dc=com' 'objectclass=*'
  ldapsearch -x -b 'o=samba,dc=example,dc=com' 'objectclass=sambaAccount'

  # Search everything from tree base down with login as cn=manager and prompt for password:
  ldapsearch -x -b 'dc=example,dc=com' \
  'objectclass=*' -D 'cn=manager,dc=example,dc=com' -W
}

#------------------------------------------------------------------------------
function createRootCertificate() {
  APP_DIR=$HOME/certificates/root_certificate
  mkdir -p $APP_DIR && cd $APP_DIR
  mkdir sslcert
  chmod 0700 sslcert
  cd sslcert
  mkdir certs private

  #  Create a database to keep track of each certificate signed
  echo '100001' >serial
  touch certindex.txt

  echo -e "\tINFO: create the openssl.cnf file"

  openssl req -new -x509 -extensions v3_ca -keyout \
  private/cakey.pem -out cacert.pem -days 365 -config ./openssl.cnf
}
function createPkcs12Certificates() {
      echo -e "\tINFO: forEachPersonCreateKeyAndSigningRequest"
  openssl req -new -nodes -out req.pem -keyout key.pem -days 365 -config ./openssl.cnf
      echo -e "\tINFO: Sign each request"
  openssl ca -out cert.pem -days 365 -config ./openssl.cnf -infiles req.pem

      echo -e "\tINFO: Create the PKCS12"
      echo -e "\t      key.pem' is the private key and should be guarded"
      echo -e "\t      cert.pem is the public certificate"
      echo -e "\t      cert.p12 is The cert.p12 file is the one to give the person. ( user manually copies to browser"
  openssl pkcs12 -export -in cert.pem -inkey key.pem -certfile cacert.pem -name "[friendly name]" -out cert.p12
}
#------------------------------------------------------------------------------

function whereAreStoredCA() {
  echo -e "\tINFO: Red Hat: /usr/share/ssl/misc/CA"
}

function createSelfSignedSSLCertificate() {
  echo -e "\tINFO: create files: server.crt|csr|key|key.org"
  APP_DIR=$HOME/certificates/self_signed
  mkdir -p $APP_DIR && cd $APP_DIR
  openssl genrsa -des3 -out server.key 1024 #generate a Private Key
  openssl req -new -key server.key -out server.csr #generate a CSR

  cp server.key server.key.org
  openssl rsa -in server.key.org -out server.key #remove Passphrase from Key;
  openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt #generate a Self-Signed Certificate

  copySSLCertToNginx;
}
function copySSLCertToNginx() {
  mkdir -p $HOME/nginx/conf/ssl.crt
  mkdir -p $HOME/nginx/conf/ssl.key
  cp server.crt $HOME/nginx/conf/ssl.crt
  cp server.key $HOME/nginx/conf/ssl.key
  #addCertificateAndPrivateKeyToNginx
  #restartNginx

  #cp server.crt /usr/local/apache/conf/ssl.crt #installing the private and certificate
  #cp server.key /usr/local/apache/conf/ssl.key
  #addCertificateAndPrivateKeyToApache
  #restartApache

  pwd
  ls -la
  less server.crt
}

function addCertificateAndPrivateKeyToApache() {
  echo -e "\tTODO"
  exit 1
  SSLEngine on
  SSLCertificateFile /usr/local/apache/conf/ssl.crt/server.crt
  SSLCertificateKeyFile /usr/local/apache/conf/ssl.key/server.key
  SetEnvIf User-Agent ".*MSIE.*" nokeepalive ssl-unclean-shutdown
  CustomLog logs/ssl_request_log \
  "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \"%r\" %b"
}

function generateCertificateRequest() {
  mkdir -p $HOME/certificates && cd $HOME/certificates
  openssl req -new -newkey rsa:4096 -nodes -keyout key.pem -out req.pem
  ls -lat
}

function generateSelfSignedKey() {
  echo -e "\tINFO: Generate Self Signed Key: cert.pem, key.pem"
  # keyout is private key
  mkdir -p $HOME/certificates && cd $HOME/certificates
  openssl req -x509 -days 365 -nodes -newkey rsa:4096 \
              -keyout key.pem -out cert.pem
  ls -lat
}

function showServerCertificate() {

  openssl s_client -connect $1:443 -showcerts
}

function createUserCertificateP12File() {
  echo -e "INFO: Create User's certificate "
  mkdir -p $HOME/certificates && cd $HOME/certificates
  NAME="John Eape"
  EMAIL="john.eape@email.com"
  FILE=${EMAIL/@/_}
  ssh-keygen -f $FILE
  openssl req -x509 subj "/C=DK/ST=Interstate/L=Capital/O=Acme/QU=IT/CN=$NAME/emailAdress=$EMAIL" -out $FILE.pem
  openssl pkcs12 -export -in $FILE.pem -inkey $FILE -out $FILE.p12
  pwd
  ls -la
  cat $FILE
}

function sshKeygenAgentAdd() {
  ssh-keygen -t rsa -b 4096 -C "rudolfvavra@gmail.com" -f $MY_KEY
  eval "$(ssh-agent -s)"
  ssh-add $MY_KEY
}
function sshCopyID() {
  echo -e "\tINFO: Copy ssh pub key on <myuser@myserver>"
  ssh-copy-id -i $MY_KEY $MY_USER@$MY_SERVER
}

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

MY_KEY=$HOME/.ssh/id_mykey01
MY_SERVER="192.168.1.95"
MY_USER="xp"

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "#--------------------------------------------------------------------"
      echo "#  APP: $APP_NAME"
      echo "#--------------------------------------------------------------------"
      echo -e "\t-h|--help                       Help"
      echo "#--------------------------------------------------------------------"
      echo -e "\t-cuc |--create_user_certificate   TODO: User certificate for browser"
      echo -e "\t-cssk|--create_self_signed_key    create: cert.pem, key.pem"
      echo -e "\t-cssc|--create_self_signed_cert   create: server.crt|csr|key|key.org"
      echo ""
      echo -e "\t-crc |--create_root_certificate   create: cacert.pem,"
      echo -e "\t-cpu |--create_p12_user           create: cert.p12 "
      echo ""
      echo -e "\t-ls |--ldap_search"
      echo -e "\t-ssc|--show_server_certificates"
      echo ''
      echo -e "\t-ia |--install_ansible       Install Ansible as Local User"
      echo -e "\t-ig |--install_go            Install Ansible as Local User"
      echo -e "\t-ipp|--install_pip_package   Install package via pip"
      echo -e "\t-ip |--install_python_pip    Install Python&Pip as Local User"
      echo -e "\t-ir |--install_ruby_sinatra  Install Ruby as Local User"
      echo -e "\t-sr |--source_ruby_sinatra   Source Ruby as Local User"
      echo ""
      echo -e "\t-sci|--ssh_copy_id           Copy MY_KEY on <MY_USER@MY_SERVER>"
      echo "#--------------------------------------------------------------------"
      exit 0
      ;;
    -ssc|--show_server_certificates)
      showServerCertificate
      ;;
    -ls|--ldap_search)
      ldapSearch
      ;;
    -cssk|--create_self_signed_key)
      generateSelfSignedKey
      ;;
    -cssc|--create_self_signed_cert)
      createSelfSignedSSLCertificate;
      ;;
    -cuc|--create_user_certificate)
      createUserCertificateP12File;
      ;;
    -sci|--ssh_copy_id)
      #sshKeygenAgentAdd
      sshCopyID;
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


