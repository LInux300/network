#!/bin/bash

ubuntuAddRoot() {
    sudo -i
    sudo passwd root
}

linuxAddUser() {
    sudo adduser $1
}

linuxGetSudoers() {
    file='/etc/sudoers'
    echo "# INFO: All $file"
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
}

linuxGetUserGroups() {
   user=$1
   echo "# INFO: it shows groups of the user"
   groups $user
}

linuxInstallUfwAllowSshHttp() {
    apt-get install ufw
    echo "# INFO: Allow SSH, HTTP"
    ufw allow ssh
    ufw allow http
    ufw enable
    ufw status verbose
}
linuxInstallUfwAllowSshHttp

linuxSecureSharedMemory() {
}

linuxRootAccountsHaveUidSetTo0(){
    echo "# Check if only root is root"
    root="$(awk -F: '($3 == "0") {print}' /etc/passwd)"
    if [ $root == 'root:x:0:0:root:/root:/bin/bash' ]; then
        echo "# INFO root is root"
    else
        echo "# WARNING: Check cmd: '$root'"
        exit
    fi
}

linuxNoAccountsHaveEmptyPassword() {
    echo "# INFO: verification of no accounts without passwords"
    for i in $(awk -F: '($2 == "") {print}' /etc/shadow); do
        echo "# WARNING: account without password is: $i"
        passwd -l $i
    done
}
linuxNoAccountsHaveEmptyPassword


linuxFirewallAcceptConnectionOnlyFrom() {
    -A RH-Firewall-1-INPUT -s 192.168.1.0/24 -m state --state NEW -p tcp --dport 22 -j ACCEPT
    -A RH-Firewall-1-INPUT -s 202.54.1.5/29 -m state --state NEW -p tcp --dport 22 -j ACCEPT
    
}

linuxGenPasswd() {
	local l=$1
       	[ "$l" == "" ] && l=20
      	tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${l} | xargs
}
linuxGenPasswd 20

linuxSshCopyId() {
    user=$1
    server=$2
    echo "# Create keygen"
    ssh-keygen -b 4096
    ssh-copyid $user@$server
}

linuxSecurityHelp() {
    echo "https://www.thefanclub.co.za/how-to/how-secure-ubuntu-1604-lts-server-part-1-basics"
}


linuxcheckForRootkits() {
    echo '# INFO: RKHunter and CHKRootKit'
    apt-get install rkhunter chkrootkit
    chkrootkit
    rkhunter --update
    rkhunter --propupd
    rkhunter --check
}

#  Performing 'shared libraries' checks
#    Checking for preloading variables                        [ None found ]
#    Checking for preloaded libraries                         [ None found ]
#    Checking LD_LIBRARY_PATH variable                        [ Not found ]

#/usr/bin/lwp-request                                     [ Warning ]



# MAIN
#------------------------------------------------------------------------------
linuxRootAccountsHaveUidSetTo0

