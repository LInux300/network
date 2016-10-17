import os, platform, collections
import socket, subprocess,sys
import threading
from datetime import datetime

class myThread (threading.Thread):
  def __init__(self,startLastOctet,endLastOctet):
    threading.Thread.__init__(self)
    self.startLastOctet = startLastOctet
    self.endLastOctet = endLastOctet
  def run(self):
    runThread(self.startLastOctet,self.endLastOctet)

def getNetwork():
  net = raw_input("Enter the Network Address:\t\t ")
  netSplit= net.split('.')
  a = '.'
  firstThreeOctet = netSplit[0]+a+netSplit[1]+a+netSplit[2]+a
  startLastOctet = int(raw_input("Enter the beginning of last Octet:\t "))
  endLastOctet = int(raw_input("Enter the end od last Octet:\t\t "))
  endLastOctet =endLastOctet+1
  dic = collections.OrderedDict()
  oper = platform.system()
  if (oper=="Windows"):
    pingCmd = "ping -n 1 "
  elif (oper== "Linux"):
    pingCmd = "ping -c 1 "
  else :
    pingCmd = "ping -c 1 "
  return firstThreeOctet, startLastOctet, endLastOctet, dic, pingCmd

def runThread(startLastOctet,endLastOctet):
  #print "Scanning in Progess"
  for ip in xrange(startLastOctet,endLastOctet):
    addr = firstThreeOctet+str(ip)
    pingAddress = pingCmd+addr
    response = os.popen(pingAddress)
    for line in response.readlines():
      #if(line.count("TTL")):
      #  break
      if (line.count("ttl")):
        #print addr, "--> Live"
        dic[ip]= addr
        break

if __name__ == '__main__':
  subprocess.call('clear',shell=True)
  print "-" * 75
  print "This program search for life IPs in last octet, with multiple threads "
  print "\tFor example: 192.168.11.xxx - 192.168.11.yyy"
  print "-" * 75
  firstThreeOctet, startLastOctet, endLastOctet, dic, pingCmd = getNetwork()
  t1= datetime.now()

  total_ip =endLastOctet-startLastOctet
  tn =3 # number of ip handled by one thread
  total_thread = total_ip/tn
  total_thread=total_thread+1
  threads= []
  try:
    for i in xrange(total_thread):
      en = startLastOctet+tn
      if(en >endLastOctet):
        en =endLastOctet
      thread = myThread(startLastOctet,en)
      thread.start()
      threads.append(thread)
      startLastOctet =en
  except:
    print "Error: unable to start thread"

  print "\t Number of Threads active:", threading.activeCount()
  for t in threads:
    t.join()
  print "\tExiting Main Thread"

  sortedIPs = collections.OrderedDict(sorted(dic.items()))
  for key in sortedIPs:
    print "IP address: {} \t --> Live".format(sortedIPs[key])
  t2= datetime.now()
  total =t2-t1
  print "Scanning complete in " , total


