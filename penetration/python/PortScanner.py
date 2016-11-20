import argparse
from socket import *

# Usage: python PortScanner.py -a 192.168.0.103 -p 21,80

def printBanner(connSock, tgtPort):
  try:
    # send data to target
    if(tgtPort == 80):
      connSock.send("GET HTTP/1.1 \r\n")
    else:
      connSock.send("\r\n")

    # Receive data from target, wait for server, buffer
    results = connSock.recv(4096)
    print '[+] Banner: ' + str(results)
  except:
    print '[-] Banner not available\n'

def connScan(tgtHost,tgtPort):
  try:
    # AF_INET = IP4
    # SOCK_STREAM = TCP
    connSock = socket(AF_INET, SOCK_STREAM)
    # try to connect
    connSock.connect((tgtHost,tgtPort))
    print '[+] %d tcp open' % tgtPort
    printBanner(connSock,tgtPort)
  except:
    print '[+] %d tcp closed' % tgtPort
  finally:
    # close the socket object
    connSock.close()

def portScan(tgtHost,tgtPorts):
  try:
    tgtIP = gethostbyname(tgtHost)
  except:
    print "[-] Error: Unknown Host"

  try:
    tgtName = gethostbyaddr(tgtIP)
    print "[+]--- Scan result for: " + tgtName[0] + " ---"
  except:
    print "[+]--- Scan result for: " + tgtIP + " ---"
    
  setdefaulttimeout(10)

  # For each port call connScan
  for tgtPort in tgtPorts:
    connScan(tgtHost,int(tgtPort))

def main():
  # Parse the command line args
  parser = argparse.ArgumentParser('INFO: TCP Client Scan')
  parser.add_argument("-a", "--address", type=str, help="The target IP address")
  parser.add_argument("-p", "--port", type=str, help="The port number to connect with")
  args = parser.parse_args()

  ipaddress = args.address
  portNumbers = args.port.split(',')

  portScan(ipaddress,portNumbers)


if __name__ == "__main__":
  main()


