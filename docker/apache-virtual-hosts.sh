#!/bin/bash
echo "RUN: as 'sudo bash $0'"
#------------------------------------------------------------------------------
# Apache Virtual Hosts
# Ubuntu 14.04 LTS
# https://www.digitalocean.com/community/tutorials/how-to-set-up-apache-virtual-hosts-on-ubuntu-14-04-lts
#------------------------------------------------------------------------------

DOMENA_NAME_1='example.com'
DOMENA_NAME_2='test.com'
DOMENA_NAME_3='virtual.com'

apacheInstall() {
    sudo apt-get update
    sudo apt-get install apache2
}

apacheDirVirtualHosts() {
    echo "# INFO: Create Directory Structure for $1"
    sudo mkdir -p /var/www/$1/public_html

    echo "# INFO: Grant Permissions for $1"
    sudo chown -R $USER:$USER /var/www/$1/public_html
    sudo chmod -R 755 /var/www
}
apacheDirVirtualHosts $DOMENA_NAME_2
apacheDirVirtualHosts $DOMENA_NAME_3


apacheDemoPage() {
    echo "# INFO: Create Demo Pages for virtual host: $1"
    file="/var/www/$1/public_html/index.html"
    cat > $file <<EOF
<html>
  <head>
    <title>Welcome to $1!</title>
  </head>
  <body>
    <h1>Success!  The $1 virtual host is working!</h1>
  </body>
</html>
EOF
}
apacheDemoPage $DOMENA_NAME_2
apacheDemoPage $DOMENA_NAME_3


apacheHostFiles() {
    echo "# INFO: Create New Virtual Host Files for $1"
    echo "# INFO: Default file: /etc/apache2/sites-available/000-default.conf"
    file="/etc/apache2/sites-available/$1.conf"
    cat > $file <<EOF
<VirtualHost *:80>
    ServerAdmin admin@$1
    ServerName $1
    ServerAlias www.$1
    DocumentRoot /var/www/$1/public_html
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

}
apacheHostFiles $DOMENA_NAME_2
apacheHostFiles $DOMENA_NAME_3

apacheEnableVirtualHost() {
    echo "# INFO: Enable the New Virtual Host File for $1"
    sudo a2ensite $1.conf
    sudo service apache2 restart
}
apacheEnableVirtualHost $DOMENA_NAME_2
apacheEnableVirtualHost $DOMENA_NAME_3


apacheSetLocalHostFile() {
    echo "# INFO: Optional, Set Up Local Hosts File"
    file='/etc/hosts'
    # TODO: asign ip address
    string="
111.111.111.111 $1
"
    #echo $string >> $file
}

apacheHttpTest() {
    echo "# INFO: Test your Results"
    wget http://$1
}
apacheHttpTest $DOMENA_NAME_2
apacheHttpTest $DOMENA_NAME_3

apacheHelps() {
    echo "# INFO: Apache 2 Virtual Hosts"
    echo "# INFO: https://httpd.apache.org/docs/current/vhosts/name-based.html"
    echo "# INFO: IP-based virtual hosts"
    echo "# INFO: Name-based virtual hosting is usually simpler, since you need"
    echo "        only configure your DNS"
    echo "--------------------------------------------------------------------"
    # sudo apt-get install links2
    # links2 www.google.com
}


#------------------------------------------------------------------------------
# MAIN
#------------------------------------------------------------------------------
apacheHelps
# apacheInstall

apacheDirVirtualHosts $DOMENA_NAME_1
apacheDemoPage $DOMENA_NAME_1
apacheHostFiles $DOMENA_NAME_1
apacheEnableVirtualHost $DOMENA_NAME_1
apacheHttpTest $DOMENA_NAME_1

sudo service apache2 restart
echo "# INFO: Apache Status: 'systemctl status apache2.service'"
echo "#-----------------------------------------------------------------------"
systemctl status apache2.service
echo "# INFO: Apache Status: 'journalctl -xe'"
echo "#-----------------------------------------------------------------------"
#journalctl -xe

