#!/bin/bash

DIR_NAME=$(dirname $(readlink -f $0))
. $DIR_NAME/setenvs


CERFIFICATES=$VPNBOOK/certificates
APP_NAME='openvpn'

function downloadOpenvpnCertificate() {
  echo -e "\tINFO: download OpenVPN certificate"
  mkdir -p $CERFIFICATES && cd $CERFIFICATES
  wget http://www.vpnbook.com/free-openvpn-account/VPNBook.com-OpenVPN-Euro1.zip $CERFIFICATES
  wget http://www.vpnbook.com/free-openvpn-account/VPNBook.com-OpenVPN-Euro2.zip $CERFIFICATES
  wget http://www.vpnbook.com/free-openvpn-account/VPNBook.com-OpenVPN-US1.zip $CERFIFICATES
  wget http://www.vpnbook.com/free-openvpn-account/VPNBook.com-OpenVPN-US2.zip $CERFIFICATES
  wget http://www.vpnbook.com/free-openvpn-account/VPNBook.com-OpenVPN-CA1.zip $CERFIFICATES
  wget http://www.vpnbook.com/free-openvpn-account/VPNBook.com-OpenVPN-DE1.zip $CERFIFICATES
  unzip VPNBook.com-OpenVPN-Euro1.zip
  unzip VPNBook.com-OpenVPN-Euro2.zip
  unzip VPNBook.com-OpenVPN-US1.zip
  unzip VPNBook.com-OpenVPN-US2.zip
  unzip VPNBook.com-OpenVPN-CA1.zip
  unzip VPNBook.com-OpenVPN-DE1.zip
}

function infoApp() {
  echo -e "\tINFO: info '$APP_NAME'"
  echo -e "\tINFO: http://www.vpnbook.com/freevpn"
}

function installApp() {
  downloadOpenvpnCertificate
  echo -e "\tINFO: install '$APP_NAME'"
  sudo apt-get install openvpn
}

function runEuro1App() {
  userPassword
  echo -e "\tINFO: run '$APP_NAME'"
  sudo openvpn --config $CERFIFICATES/vpnbook-euro1-tcp443.ovpn
}

function runEuro2App() {
  userPassword
  echo -e "\tINFO: run '$APP_NAME'"
  sudo openvpn --config $CERFIFICATES/vpnbook-euro2-tcp443.ovpn
}

function userPassword() {
  echo -e "\tINFO: USER: vpnbook"
  echo -e "\tINFO: PASS: VeStubr6"
}

function runCa1App() {
  userPassword
  echo -e "\tINFO: run '$APP_NAME'"
  sudo openvpn --config $CERFIFICATES/vpnbook-ca1-tcp443.ovpn
}

function runDe1App() {
  userPassword
  echo -e "\tINFO: run '$APP_NAME'"
p sudo openvpn --config $CERFIFICATES/vpnbook-de233-tcp443.ovpn
}

function runUs1App() {
  userPassword
  echo -e "\tINFO: run '$APP_NAME'"
  sudo openvpn --config $CERFIFICATES/vpnbook-us1-tcp443.ovpn
}

function runUs2App() {
  userPassword
  echo -e "\tINFO: run '$APP_NAME'"
  sudo openvpn --config $CERFIFICATES/vpnbook-us2-tcp443.ovpn
}

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "#--------------------------------------------------------------------"
      echo "#  App: $APP_NAME"
      echo "#--------------------------------------------------------------------"
      echo "Options:"
      echo ""
      echo -e "\t-h|--help           help"
      echo -e "\t--info              info"
      echo -e "\t--install           install"
      echo -e "\t--run_euro1         EURO1 run over 443 (sudo)"
      echo -e "\t--run_euro2         EURO2 run over 443 (sudo)"
      echo -e "\t--run_ca1           Canada run over 443 (sudo)"
      echo -e "\t--run_de1           Germeny run over 443 (sudo)"
      echo -e "\t--run_us1           USA1 run over 443 (sudo)"
      echo -e "\t--run_us2           USA2 run over 443 (sudo)"
      echo ""
      echo "#--------------------------------------------------------------------"
      exit 0
      ;;
    --info)
      infoApp
      ;;
    --install)
      installApp
      ;;
    --run_euro1)
      runEuro1App
      ;;
    --run_euro2)
      runEuro2App
      ;;
    --run_ca1)
      runCa1App
      ;;
    --run_de1)
      runDe1App
      ;;
    --run_us1)
      runUs1App
      ;;
    --run_us2)
      runUs2App
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


