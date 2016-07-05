#!/bin/bash
echo "Run as 'sudo bash $0'"

DOMENA_NAME_1='example.com'
DOMENA_NAME_2='test.com'
DOMENA_NAME_3='virtual.com'

CONF_FILE="/etc/bind/named.conf"

dnsHelp() {
    echo "# INFO: https://www.digitalocean.com/community/tutorials/how-to-configure-bind-as-a-private-network-dns-server-on-ubuntu-16-04"
    echo "# INFO: https://www.youtube.com/watch?v=0fGv7x8q_n0"
    echo ""
}


dnsInstall() {
    echo "# INFO: Ubuntu DNS"
    echo "#-------------------------------------------------------------------"
    sudo apt -y install bind9
    echo "# INFO: Installation of dnsutils - for testing and troubleshooting"
    echo "#-------------------------------------------------------------------"
    sudo apt -y install dnsutils
}


dnsCreateARecordForBaseDomain() {
    #sudo cp /etc/bind/db.local /etc/bind/db.example.com
    file="/etc/bind/db.$1"
    cat > $file <<EOF
;
; BIND data file for site $1
;
$TTL    604800
@       IN      SOA          $1.        root.$1. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      $1.
@       IN      A       127.0.0.1
www     IN      A       127.0.0.1
ftp     IN      A       127.0.0.1
EOF
}


dnsCreateARecordForBaseDomainReverse() {
    #sudo cp /etc/bind/db.local /etc/bind/db.example.com
    file="/etc/bind/db.$1"
    cat > $file <<EOF
;
; BIND REVERSE data file for site $1
;
$TTL    604800
@       IN      SOA          $1.        root.$1. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      $1.
1.10.10 IN      PTR     $1.
EOF
}

#------------------------------------------------------------------------------
# Main
#------------------------------------------------------------------------------
dnsInstall
vim /etc/hosts
"
#172.10.10.1 server1.mysite.net server1
127.0.0.1 server1.mysite.net server1
"
vim /etc/resolv.conf
"
nameserver 8.8.8.8
nameserver 8.8.4.4
search mysite.net
"
vim /etc/bind/named.conf 
'
zone "mysite.net" {
     type master;
     file "forward";
};

zone "127.in-addr.arpa" {
     type master;
     file "reverse";
};
'

cd /home/users
cd /etc/bind/
ls -l
cp db.local /var/cache/bind/forward
vim /var/cache/bind/forward
"

"

cp /var/cache/bind/forward /var/cache/bind/reverse
vim /var/cache/bind/reverse


"

/etc/init.d/bind9 restart
nslookup mysite.net

nslookup 172.10.10.1

nslookup www.mysite.new
nslookup ftp.mysite.new

# sudo systemctl restart bind9.service



