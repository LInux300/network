#!/bin/bash
echo "Run as 'sudo bash $0'"

DOMENA_NAME_1='example.com'
DOMENA_NAME_2='test.com'
DOMENA_NAME_3='virtual.com'

primaryDNS='10.128.10.10'
secondaryDNS='10.128.10.20'
host1='10.128.10.30'
host2='10.128.10.40'
forward1='8.8.8.8';
forward2='8.8.4.4';

echo "# INFO: WEB: https://www.digitalocean.com/community/tutorials/how-to-configure-bind-as-a-private-network-dns-server-on-ubuntu-16-04"

installDNS() {
    sudo -apt-get update
    sudo apt-get install -y bind9 bind9utils bind9-doc

    echo "# INFO to 'sudo systemctl edit  --full bind9' do change:"
    echo "ExecStart=/usr/sbin/named -f -u bind"
    echo "ExecStart=/usr/sbin/named -f -u bind -4"
    sudo systemctl edit  --full bind9
    sudo systemctl daemon-reload
    sudo systemctl restart bind9
}
#installDNS
 
dnsConfigurePrimaryDNS() {
    file='/etc/bind/named.conf.options'
    echo "# INFO: PRIMARY DNS: $(cat $file)"
    confOptionsAclTrusted=$(cat $file | grep 'acl "trusted"')
    if [ ! $confOptionsAclTrusted ]; then
        echo '# INFO: Add  - acl "trusted"  to named.conf.options'
        echo '# INFO: in options adds forwarders, recursion yes, allow-recursion'
        echo '#       listen-on, allow-transfer'
        cat > $file <<EOF
acl "trusted" {
        $primaryDNS;    # ns1 - can be set to localhost
        $secondaryDNS;    # ns2
        $host1;  # host1
        $host2;  # host2
};

options {
        directory "/var/cache/bind";

        // If there is a firewall between you and nameservers you want
        // to talk to, you may need to fix the firewall to allow multiple
        // ports to talk.  See http://www.kb.cert.org/vuls/id/800113

        // If your ISP provided one or more IP addresses for stable
        // nameservers, you probably want to use them as forwarders.
        // Uncomment the following block, and insert the addresses replacing
        // the all-0's placeholder.

        // forwarders {
        //      0.0.0.0;
        // };

        recursion yes;                 # enables resursive queries
        allow-recursion { trusted; };  # allows recursive queries from "trusted" clients
        listen-on { $primaryDNS; };   # ns1 private IP address - listen on private network only
        allow-transfer { none; };      # disable zone transfers by default

        forwarders {
                $forward1;
                $forward2;
        };

        //========================================================================
        // If BIND logs error messages about the root key being expired,
        // you will need to update your keys.  See https://www.isc.org/bind-keys
        //========================================================================
        dnssec-validation auto;

        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };
};
EOF
    else
        echo '# INFO: your setting already have acl "trusted"'
    fi
}
dnsConfigurePrimaryDNS


dnsConfigureLocalFile() {
    file='/etc/bind/named.conf.local'
    echo "# INFO: $(cat $file)"
    confOptionsZone=$(cat $file | grep $1)
    if [[ ! $confOptionsZone ]]; then
       cat >> $file <<EOF
zone "nyc3.$1" {
    type master;
    file "/etc/bind/zones/db.nyc3.$1"; # zone file path
    allow-transfer { $secondaryDNS; };           # ns2 private IP address - secondary
};

zone "128.10.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.10.128";  # 10.128.0.0/16 subnet
    allow-transfer { $secondaryDNS; };  # ns2 private IP address - secondary
};
EOF
    else
        echo '# INFO: your zone files already has '$1''
    fi
}
dnsConfigureLocalFile $DOMENA_NAME_1

dnsCreateForwardZoneFile() {
    dir='/etc/bind/zones'
    echo "# INFO: Creates dir: $dir"
    mkdir $dir
    cd $dir

    file="./db.nyc3.$1"
    echo "# INFO: Creates a file: '$file'"
    cp '../db.local' $file
    cp $file "$file.default"

    echo "#--------------------------------------------------------------------"
    echo "# INFO: BEFORE: $(pwd)  $file.default"
    echo "#--------------------------------------------------------------------"
    echo "$(cat $file)"

    confOptionsZone=$(cat $file | grep $1)
    if [[ ! $confOptionsZone ]]; then
        domane="nyc3.$1"
        cat > $file <<EOF
;
; BIND data file for local loopback interface
; Update Serial +1
\$TTL    604800
@       IN      SOA     ns1.nyc3.$1. admin.nyc3.$1. (
                              3         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
; name servers - NS records
    IN      NS      ns1.$domane.
    IN      NS      ns2.$domane.

; name servers - A records
ns1.$domane.          IN      A       $primaryDNS
ns2.$domane.          IN      A       $secondaryDNS

; 10.128.0.0/16 - A records
host1.$domane.        IN      A      $host1
host2.$domane.        IN      A      $host2
EOF
        echo "#--------------------------------------------------------------------"
        echo "# INFO: AFTER: $file"
        echo "#--------------------------------------------------------------------"
        echo "$(cat $file)"
    else
        echo '# INFO: your Forward Zone File already exist for '$1''
    fi
}
dnsCreateForwardZoneFile $DOMENA_NAME_1

dnsCreateReverseZoneFile() {
    dir='/etc/bind/zones'
    cd $dir

    file="./db.10.128"
    cp '../db.127' $file
    cp $file "$file.default"
    echo "#--------------------------------------------------------------------"
    echo "# INFO: BEFORE: $(pwd) $file.default"
    echo "#--------------------------------------------------------------------"
    echo "$(cat $file)"

    confOptionsZone=$(cat $file | grep $1)
    if [[ ! $confOptionsZone ]]; then
        domane="nyc3.$1"
        cat > $file <<EOF
\$TTL    604800
@       IN      SOA     $domane. admin.$domane. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
; name servers
      IN      NS      ns1.$domane.
      IN      NS      ns2.$domane.

; PTR Records
11.10   IN      PTR     ns1.$domane.    ; $primaryDNS
12.20   IN      PTR     ns2.$domane.    ; $secondaryDNS
101.100 IN      PTR     host1.$domane.  ; $host1
102.200 IN      PTR     host2.$domane.  ; $host2
EOF
        echo "#--------------------------------------------------------------------"
        echo "# INFO: AFTER: $file"
        echo "#--------------------------------------------------------------------"
        echo "$(cat $file)"
        echo "#--------------------------------------------------------------------"
    else
        echo '# INFO: your Reverse Zone File already exist for '$1''
    fi
}
dnsCreateReverseZoneFile $DOMENA_NAME_1



echo "# INFO: PRIMARY DSN Cheks"
domena="nyc3.$DOMENA_NAME_1"
named-checkconf
named-checkzone $domane "db.$domane"
#sudo named-checkzone 128.10.in-addr.arpa /etc/bind/zones/db.10.128
sudo systemctl restart bind9
echo "# INFO: PRIMARY DSN end"
echo "#--------------------------------------------------------------------"
# IF you have the UFW firewall configured open up access to bind by typing
#sudo ufw allow Bind9

dnsConfigureSecondDns() {
    echo "#INFO: TODO"
}

linuxGetInterfaceNames() {
    ip addr
}

linuxGetAllEthernetInterfaces() {
    ifconfig -a | grep eth
}

linuxGetClassNetwork() {
    lshw -class network
}

installEthtool() {
    sudo apt install ethtool
}
#ethtool eth0

linuxAssignMultipleIpAddressesToOneInterface() {
    primaryDNS=$1
    secondaryDNS=$2
    host1=$3
    host2=$4
    echo "#--------------------------------------------------------------------"
    echo "# INFO: Virtual Hosts "
    echo "#--------------------------------------------------------------------"
    #sudo ip address add 172.01.200.1 dev docker0
    # TODO: networkInterface=$(ethtool wlp2s0)
 
    networkInterface='wlp2s0'
    networkInterface='eth0'
    networkInterface='docker0'
    networkInterface='wlan0'

    # Get Default
    ip route del default

    # TEMPORARY
    #ip addr add $primaryDNS dev $networkInterface
    #ip addr add $secondaryDNS dev $networkInterface
    #ip addr add $host1 dev $networkInterface
    #ip addr add $host2 dev $networkInterface

    # sudo ip addr add 192.168.0.2/24 dev eth1
    file='/etc/network/interfaces'
    cat > $file<<EOF
# interfaces(5) file used by ifup(8) and ifdown(8)
# add permanently
auto lo
iface lo inet loopback

# STATIC
# TEMPORARY: ifconfig eth0:0 123.123.22.22
iface $networkInterface:0 inet static
  address $host1
  netmask 255.0.0.0
#broadcast 123.255.255.255


#iface $networkInterface inet static
#    address $primaryDNS

#iface $networkInterface inet static
#    address $secondaryDNS

#iface $networkInterface inet static
#    address $host1

#iface $networkInterface inet static
#    address $host2

EOF
    echo "# INFO: ifdown && ifup network interfaces"
    echo "#--------------------------------------------------------------------"
    /etc/init.d/networking restart
    ifdown $networkInterface
    ifup $networkInterface
    linuxGetInterfaceNames
    # updta your dns settings
    resolvconf -u
    #sudo apt-get update
}
linuxAssignMultipleIpAddressesToOneInterface $primaryDNS $secondaryDNS $host1 $host2



dncConfigureDnsClients() {
    # TODO!
    file='/etc/network/interfaces'
    if [ $file ]; then
       cp $file "$file.default"
       cat > $file <<EOF
dns-nameservers $primaryDNS $secondaryDNS $forward1
dns-search nyc3.example.com
EOF
    else
      echo "#INFO: TODO"
    fi
}



#------------------------------------------------------------------------------
# MAIN
#------------------------------------------------------------------------------
#installDNS

echo "# INFO:  Host    Role                   Private FQDN                Private IP"
echo "# INFO:  ns1     Primary DNS Server     ns1.nyc3.$DOMENA_NAME_1     $primaryDNS"
echo "# INFO:  ns2     Secondary DNS          ns2.nyc3.$DOMENA_NAME_1     $secondaryDNS"
echo "# INFO:  host1   Generic Host 1         host1.nyc3.$DOMENA_NAME_1   $host1"
echo "# INFO:  host2   Generic Host 2         host2.nyc3.$DOMENA_NAME_1   $host2"

