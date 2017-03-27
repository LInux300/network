#!/bin/bash

DIR_NAME=$(dirname $(readlink -f $0))

function macChanger() {
  macchanger eth0 -r
  ifconfig
}

function basicSniffer() {
  echo -e "\tINFO: show how Sniffer works"
  less BasicSniffer.py
} 

function bruteForce() {
  echo -e "\tINFO: FTP by bruto force"
  python BruteForce.py
}

function portScanner() {
  echo -e "\tINFO: Port Scanner"
  echo -en "\tEnter Server: "
  read server
  echo -en "\tEnter ports (example: 80,22,443): "
  read ports
  echo -en "\tEnter UDP or TCP: "
  read protocol
  case "$protocol" in
   "UDP")
    python PortScanner_udp.py --udp -a $server -p $ports
   ;;
   "TCP")
    python PortScanner_udp.py -a $server -p $ports
   ;;
   *) $0 --port-scanner
   ;;
  esac
}

function startTcpServer() {
  echo -e "\tINFO: Starting TCP server"
  echo -en "\tEnter TCP port: "
  read port
  python TcpServer.py -p $port
}

function startUdpServer() {
  echo -e "\tINFO: Starting UDP server"
  echo -en "\tEnter UDP port: "
  read port
  # -v  verbose  -l  listen   -u  udp
  netcat -v -l -u -p $port
}

function tcpSniffer() {
  echo -e "\tINFO: Starting TCP Sniffer"
  echo -e "\tINFO: test it terminal 'ping localhost -c 3'"
  echo -e "\tINFO: generate traffic with browser"
  python TcpSniffer.py
}

function scanNetwork() {
  nmap -sS -A 192.168.1.0/24
}

function scapySniffer() {
  echo -e "\tINFO: SCAPY: http://secdev.org/projects/scapy/doc/usage.html"
  cd $DIR_NAME
  echo -en "\tEnter 'install' or 'run|*': "
  read sniffer
  case "$sniffer" in
    "install")
      wget https://www.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
      gunzip GeoLiteCity.dat.gz
      mv GeoLiteCity.dat GeoIP.dat
      sudo easy_install pygeoip
      sudo apt-get install python-scapy python-ipy python-netifaces
    ;;
    *)
      sudo python ScapySniffer.py
    ;;
  esac
}

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "#--------------------------------------------------------------------"
      echo "#  App: $APP_NAME"
      echo "#--------------------------------------------------------------------"
      echo ""
      echo -e "\t-h  |--help              help"
      echo -e "\t-bs |--basic-sniffer     cat|show how sniffer works"
      echo -e "\t-bf |--brute-force       FTP by bruto force with passwords.txt"
      echo -e "\t-mc |--mac-changer       change mac address"
      echo -e "\t-ps |--port-scanner      Port Scanner"
      echo -e "\t-sts|--start-tcp-server  Start TCP Server"
      echo -e "\t-sus|--start-udp-server  Start UDP Server"
      echo -e "\t-ts |--tcp-sniffer       TCP Sniffer"
      echo -e "\t-sn |--scan-network      scan network"
      echo -e "\t-ss |--scapy-sniffer     more advance TCP Sniffer"
      echo ""
      echo "#--------------------------------------------------------------------"
      exit 0
      ;;
    -mc|--mac-changer)
      macChanger
      ;;
    -bs|--basic-sniffer)
      basicSniffer
      ;;
    -bf|--brute-force)
      bruteForce
      ;;
    -ps|--port-scanner)
      portScanner
      ;;
    -sts|--start-tcp-server)
      startTcpServer
      ;;
    -sus|--start-udp-server)
      startUdpServer
      ;;
    -tc|--tcp-sniffer)
      tcpSniffer
      ;;
    -sn|--scan-network)
      scanNetwork
      ;;
    -ss|--scapy-sniffer)
      scapySniffer
      ;;
    *)
      break
      ;;
  esac
  exit 0
done

