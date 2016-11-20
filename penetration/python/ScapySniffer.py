from scapy.all import *
import pygeoip
# to know private ip addresses
from IPy import IP as IPLIB
from socket import *
import time
import netifaces

# dictionary extends to avoid dublications
conversations = {}
# exclude packages to my host i want only packages comming out
exclude_ips = [netifaces.ifaddresses(iface)[netifaces.AF_INET][0]['addr'] for iface in netifaces.interfaces() if netifaces.AF_INET in netifaces.ifaddresses(iface)]

def saveToFile(traceInfo):
  try:
    filename = 'network_monitoring_log_' + time.strftime("%d_%m_%Y") + '.txt'
    fileLog = open(filename,'a')
    fileLog.write(traceInfo)
    fileLog.write('\r\n')
    fileLog.write('-----------------------------------------------')
    fileLog.write('\r\n')
    fileLog.close()
  except:
    pass

def getInfo(ipAddress):
  try:
    hostName = gethostbyaddr(ipAddress)[0]
  except:
    hostName = ""

  # convert IP to IP object
  ip = IPLIB(ipAddress)
  if (ip.iptype() == 'PRIVATE'):
    return 'private IP, Host Name: ' + hostName

  try:
    # initialize the GEOIP object
    geoip = pygeoip.GeoIP('GeoIP.dat')
    ipRecord = geoip.record_by_addr(ipAddress)
    country = ipRecord('country_name')
    return 'Country: %s, Host: %s' % (country, hostName)
  except Exception, ex:
    return "Can't locate %s Host: %s" % (ipAddress, hostName)
  

def printPacket(sourceIP, destinationIP):
  traceInfo = '[+] Source (%s): %s ---> Destination (%s): %s' % (sourceIP, getInfo(sourceIP), destinationIP,getInfo(destinationIP))
  print traceInfo
  saveToFile(traceInfo)

def startMonitoring(pkt):
  try:
    if pkt.haslayer(IP):
      sourceIP = pkt.getlayer(IP).src
      destinationIP = pkt.getlayer(IP).dst

      if destinationIP in exclude_ips:
        return

      # avoid duplication
      uniqueKey = sourceIP + destinationIP    

      if(not conversations.has_key(uniqueKey)):
        conversations[uniqueKey] = 1
        printPacket(sourceIP, destinationIP)

  except Exception, ex:
    print "Exception: " + str(ex)   
    pass

def main():
  # store=0 we don't want to store in the memory, app is faster
  sniff(prn=startMonitoring, store=0, filter="ip")

if __name__ == '__main__':
  main()


