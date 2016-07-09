#!/bin/bash
echo "RUN: as 'sudo bash $0'"
#------------------------------------------------------------------------------
# Apache Virtual Hosts
# Ubuntu 14.04 LTS
# https://www.digitalocean.com/community/tutorials/how-to-set-up-apache-virtual-hosts-on-ubuntu-14-04-lts
#------------------------------------------------------------------------------

DOMAIN_NAME_1='server210.com'
DOMAIN_NAME_2='server220.com'
DOMAIN_NAME_3='server230.com'
host1='192.168.1.210'
host2='192.168.1.220'
host3='192.168.1.230'
networkInterface='wlan0'

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

apacheDemoPage() {
    file="/var/www/$1/public_html/index.html"
    echo "# INFO: Create index.html for virtual host: '$1' in '$file'"
    echo "---------------------------------------------------------------------"
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

apacheHostFiles() {
    echo "# INFO: Create New Virtual Host Files for $1"
    echo "# INFO: Default file: /etc/apache2/sites-available/000-default.conf"
    echo "---------------------------------------------------------------------"
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

apacheEnableVirtualHost() {
    echo "# INFO: Enable the New Virtual Host File for $1"
    sudo a2ensite $1.conf
    sudo service apache2 restart
}

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

linuxVirtualNetworkInterfaces() {
    networkInterface=$1
    host1=$2
    host2=$3
    host3=$4
    file='/etc/network/interfaces'

    # TODO default reacrete & add
    if [ 'default' == 'default' ]; then
        cp $file $file.previous
        echo "# WARNING: Recreate '$file'"
        cat > $file<<EOF
# interfaces(5) file used by ifup(8) and ifdown(8)
# add permanently
auto lo
iface lo inet loopback

# STATIC
# TEMPORARY: ifconfig eth0:1 $host1
iface $networkInterface:0 inet static
  address $host1
  netmask 255.0.0.0

iface $networkInterface:1 inet static
  address $host2
  netmask 255.0.0.0

iface $networkInterface:2 inet static
  address $host3
  netmask 255.0.0.0
EOF
    else
        # TODO: $networkInterface:XXX  get correct number
        echo "# TODO: WARNING: Add to the file '$file'"
    fi
    #/etc/init.d/networking restart
    #ifdown $networkInterface:1
    #ifup $networkInterface:1

}

linuxEtcHostsAddHosts() {
    DOMAIN=$1
    HOST=$2
    file='/etc/hosts'

    #cat /etc/hosts | grep $DOMAIN | awk -F " " '{print $2}'
    DOMAIN_IS_PRESENT="$(cat /etc/hosts | grep $DOMAIN)"
    echo "# INFO: $DOMAIN_IS_PRESENT"
    if [[ -z "$DOMAIN_IS_PRESENT" ]]; then
        cp $file $file.previous
        echo "# INFO: To file '$file' add"
        echo "# INFO: $HOST $DOMAIN"
        echo "----------------------------------------------------------------"
        cat >> $file <<EOF
$HOST $DOMAIN
EOF
        cat "$file"
    else
        echo "# INFO: Domain: '$DOMAIN' already in '$file'"
    fi

    if [ 'default' == 'xxx' ]; then
        echo "# WARNING DEFAULT value for file '$file'"
        exit
        cat > $file <<EOF
127.0.0.1	localhost
127.0.1.1	kuntuzangpo

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

81.2.254.221 tibetanmedicine.com
# DEFAULT
EOF
    fi
}

apacheHttpTest() {
    echo "# INFO: Test Results"
    ping $1
}

#------------------------------------------------------------------------------
# MAIN
#------------------------------------------------------------------------------
linuxVirtualNetworkInterfaces $networkInterface $host1 $host2 $host3

linuxEtcHostsAddHosts $DOMAIN_NAME_1 $host1
linuxEtcHostsAddHosts $DOMAIN_NAME_2 $host2
linuxEtcHostsAddHosts $DOMAIN_NAME_3 $host3

#apacheHelps
# apacheInstall
#apacheHttpTest $DOMAIN_NAME_1
#apacheHttpTest $DOMAIN_NAME_2
#apacheHttpTest $DOMAIN_NAME_3

declare -a DOMAIN_ARRAY
DOMAIN_ARRAY=($DOMAIN_NAME_1 $DOMAIN_NAME_2 $DOMAIN_NAME_3)
for i in $array; do
    echo "# INFO: Domain: $1"
    echo "--------------------------------------------------------------------"
    apacheDirVirtualHosts $i
    apacheDemoPage $i
    apacheHostFiles $i
    apacheEnableVirtualHost $i
done

echo "# INFO: Virtual Network Interfaces down & up"
ifdown $networkInterface:0
ifup $networkInterface:0
ifdown $networkInterface:1
ifup $networkInterface:1
ifdown $networkInterface:2
ifup $networkInterface:2

service apache2 reload
#service apache2 restart
echo "# INFO: Apache Status: 'systemctl status apache2.service'"
echo "#-----------------------------------------------------------------------"
systemctl status apache2.service
echo "# INFO: Apache Status: 'journalctl -xe'"
echo "#-----------------------------------------------------------------------"
#journalctl -xe

