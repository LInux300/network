#!/bin/bash

DIR_NAME=$(dirname $(readlink -f $0))

#------------------------------------------------------------------------------
# GET INFOS
#------------------------------------------------------------------------------
function harvester() {
  APP_NAME='harvester'
  mkdir -p $DIR_NAME/$APP_NAME && cd $DIR_NAME/$APP_NAME
  echo -en "\tEnter: 'install' 'README' 'USAGE' 'run|*': $APP_NAME: "
  read option
  case "$option" in
    "install")
      wget https://github.com/laramies/theHarvester/archive/master.zip
      unzip master.zip -d $DIR_NAME/$APP_NAME
      rm master.zip
    ;;
    "README")
      readme=$DIR_NAME/$APP_NAME/theHarvester-master/README
      less $readme
      echo -e "\tINFO SOURCE: $readme"
    ;;
    "usage")
      cd $DIR_NAME/$APP_NAME/theHarvester-master
      ./theHarvester.py	–h
    ;;
    *)
      echo -e "\tINFO Harvester"
      echo -en "\tEnter target domain: "
      read target_domain
      echo -en "\tEnter public repository for search (google,bing,pgp,all): "
      read pub_repo
      python $DIR_NAME/$APP_NAME/theHarvester-master/theHarvester.py –d $target_domain –l 50 –b $pub_repo
      #'-l 50' --> number of results"
    ;;
  esac
}

function netcraft() (
  firefox http://toolbar.netcraft.com/site_report
)

function infos() {
  echo -en "\tINFO: gather info from: nslookup, host, dig, whois: "
  echo -en "\tEnter domain: "
  read domain
  echo -en "\tINFO: nslookup $domain"
  nslookup $domain
  echo -en "\tINFO: host $domain"
  host $domain
  echo -en "\tINFO: dig $domain"
  dig $domain
  echo -en "\tINFO: whois $domain"
  echo -e "\t<INSTALL: apt-get install whois"
  whois $domain
}

function cewl() {
  APP_NAME='cewl'
  mkdir -p $DIR_NAME/$APP_NAME && cd $DIR_NAME/$APP_NAME
  echo -en "\tINFO: count words on page; password prifiling\n"
  echo -en "\tEnter: 'install' 'run|*': $APP_NAME: "
  read option
  case "$option" in
    "install")
      apt-get install cewl
    ;;
    *)
      echo -en "\tEnter domain: "
      read domain
      cewl -w "$domain.txt" -c -m 5 $domain
      #less $domain.txt
      #echo -en "\tINFO: count words on page; password prifiling\n"
      #echo -en "\tINFO: output: $DIR_NAME/$APP_NAME/$domain.txt \n"
    ;;
  esac
}

function passwordGenerator() {
  echo -en "\tINFO: 'Crunch' 'Wordlist Maker (WLM)' 'Common User Password Profiler(cupp)'\n"
  echo -en "\tINFO: http://www.pentestplus.co.uk/wlm.htm\n"
  echo -en "\tINFO: https://github.com/Mebus/cupp\n"
  APP_NAME='cupp'
  #mkdir -p $DIR_NAME/$APP_NAME && cd $DIR_NAME/$APP_NAME
  #git clone https://github.com/Mebus/cupp $DIR_NAME/$APP_NAME
  #cupp.py -i
}

function passwordRipper() {
  passwordGenerator
  APP_NAME='pass_gen'
  mkdir -p $DIR_NAME/$APP_NAME && cd $DIR_NAME/$APP_NAME
  echo -en "\tINFO: count words on page; password prifiling\n"
  echo -en "\tEnter: 'install' 'run|*': $APP_NAME: "
  read option
  case "$option" in
    "install")
      #git clone https://github.com/magnumripper/JohnTheRipper.git
      wget https://github.com/magnumripper/JohnTheRipper/archive/bleeding-jumbo.zip
      unzip bleeding-jumbo.zip
    ;;
    *)
      echo -en "\tINFO:JohnTheRipper http://www.openwall.com/john/doc/RULES.shtml \n"
      cd JohnTheRipper-bleeding-jumbo/run/
      john --stdout --wordlist=passwordlist.txt --rules
    ;;
  esac
}

#------------------------------------------------------------------------------
# SCANNING
#------------------------------------------------------------------------------
function scanning() {
  echo -e "\tINFO: info colection"
  echo -en "\t\tEnter domain: "
  read domain

  # --- NMAP ---
  echo -e "\tCMD: nmap -sT -p- -Pn $domain"
  echo -e "\t\t'-sS'--> SYN scan (faster than -sT)\n\t\t'-p-' --> all ports.\n\t\t'-Pn' --> skip host discovery" 
  #nmap -sS -p- -Pn $domain
  echo -e "\tINFO: Scanning for UDP"
  echo -e "\tCMD: nmap -sUD $domain"
  echo -e "\tCMD: nmap -sT -p 80-85 -Pn $domain"
  echo -e "\tCMD: nmap --script banner $domain"
  #nmap --script banner $domain
  echo -e "\tINFO: CSRF vulnerabilities; NSE—Vuln scan results."
  echo -e "\tCMD: nmap --script vuln $domain"
  nmap --script vuln $domain
cript
  echo -e "\tINFO: Idenfifying WAF"
  nmap -p 80,443 --script=http-waf-detect $domain
  nmap -p 80,443 --script=http-waf-fingerprint $domain

  # --- PING ---
  echo -e "\tINFO: fping $domain"
  echo -e "\tINSTALL: sudo apt-get install fping"
  fping domain
}

function nessus() {
  APP_NAME='nessus'
  echo -en "\tEnter: 'install' 'run|*': for $APP_NAME: "
  read option
  case "$option" in
    "install")
      echo -e "\tINFO: TODO"
      mkdir -p $DIR_NAME/$APP_NAME && cd $DIR_NAME/$APP_NAME
      firefox http://www.tenable.com/products/nessus/select-your-operating-system#tos
      sudo dpkg -i ~/Downloads/Nessus-6.9.1-ubuntu1110_amd64.deb 
      sudo /etc/init.d/nessusd start
      firefox https://localhost:8834/
    ;;
    *)
      cd $DIR_NAME/$APP_NAME
      echo -e "\tINFO: TODO"
    ;;
  esac
}

#------------------------------------------------------------------------------
# EXPLOITATION
#------------------------------------------------------------------------------
function medusa() {
  echo -e "\tCMD: sudo apt-get install medusa"
  medusa -d 
  echo -e "\tINFO: medusa –h target_ip –u username –p path_to_password_dictionar –M authentication_service_to_attack"
  echo -e "\tCMD: medusa -h 172.17.0.2 -U userlist.txt -P passwords.txt -M web-form"
}

function metasploit() {
  echo -e "\tINFO: https://www.metasploit.com/"
  APP_NAME='msfconsole'
  echo -en "\tEnter: 'install' 'run|*': for $APP_NAME: "
  read option
  case "$option" in
    "install")
      echo -e "\tINFO:"
      mkdir -p $DIR_NAME/$APP_NAME && cd $DIR_NAME/$APP_NAME
      #wget http://downloads.metasploit.com/data/releases/metasploit-latest-linux-x64-installer.run
      chmod +x metasploit-latest-linux-x64-installer.run
      ./metasploit-latest-linux-x64-installer.run
      curl localhost:3790
      
    ;;
    *)
      echo -e "\tINFO:"
      cd $DIR_NAME/$APP_NAME
      msfconsole
    ;;
  esac
}


SSH_PORTS=( 22 )
HTTP_PORTS=( 443 80 )
PORTS="-100,200-1024,T:2000-14000,U:60000-"
DOMAINS=( 192.168.1.95 192.168.1.191 192.168.1.1 )

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "#--------------------------------------------------------------------"
      echo "#  App: $APP_NAME"
      echo "#--------------------------------------------------------------------"
      echo "# Options:"
      echo ""
      echo -e "\t-h|--help           help"
      echo -e "\t--pass_ripper       password generators; john the ripper"
      echo ""
      echo "# GET"
      echo "#--------------------------------------------------------------------"
      echo -e "\t-1|--nmap          nmap -p 21,80 <dommain>"
      echo -e "\t-2|--nc            ssh,http; nc -v <serv> write: HEAD / HTTP/1.0"
      echo ""
      echo -e "\t--harvester        gathering e-mail, suddomain, ports .."
      echo "# GET INFOS:"
      echo "#--------------------------------------------------------------------"
      echo -e "\t--harvester        gathering e-mail, suddomain, ports .."
      echo -e "\t--infos            get info"
      echo -e "\t--cewl             web_profiling, page word counter"
      echo -e "\t--netcraft         firefox get info from browser"
      echo ""
      echo "# SCANNING:"
      echo "#--------------------------------------------------------------------"
      echo -e "\t--scanning         domain scanning"
      echo -e "\t--nessus           nessus"
      echo ""
      echo "# EXPLOITATION:"
      echo "#--------------------------------------------------------------------"
      echo -e "\t--medusa           http"
      echo -e "\t--metasploit       [*] "
      echo ""
      echo "#--------------------------------------------------------------------"
      exit 0
      ;;
    -1|--nmap)
      for i in ${DOMAINS[@]}; do
        nmap -p $PORTS $i
      done
      ;;
    -2|--nc)
      for i in ${DOMAINS[@]}; do
        for j in ${HTTP_PORTS[@]}; do
          echo -e "INFO: write: HEAD / HTTP/1.0"
          nc -v $i $j
        done
        for j in ${SSH_PORTS[@]}; do
          echo -e "INFO: ssh "
          nc -vzw 1 $i $j
        done
      done
      ;;
    --pass_ripper)
      passwordRipper
      ;;
    --harvester)
      harvester
      ;;
    --cewl)
      cewl
      ;;
    --netcraft)
      netcraft
      ;;
    --infos)
      infos
      ;;
    --scanning)
      scanning
      ;;
    --nessus)
      nessus
      ;;
    --metasploit)
      metasploit
      ;;
    *)
      break
      ;;
  esac
  exit 0
done


