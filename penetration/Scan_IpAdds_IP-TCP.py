import threading, thread
import time
import socket, subprocess, sys, collections
from datetime import datetime

class myThread (threading.Thread):
  def __init__(self,startLastOctet,endLastOctet):
    threading.Thread.__init__(self)
    self.startLastOctet = startLastOctet
    self.endLastOctet = endLastOctet
  def run(self):
    runThread(self.startLastOctet,self.endLastOctet)

def getNetwork():
  net = raw_input("Enter the Network Address:\t\t")
  netSplit= net.split('.')
  a = '.'
  firstThreeOctet = netSplit[0]+a+netSplit[1]+a+netSplit[2]+a
  startLastOctet = int(raw_input("Enter the beginning of last Octet:\t"))
  endLastOctet = int(raw_input("Enter the end od last Octet:\t\t"))
  endLastOctet=endLastOctet+1
  dic = collections.OrderedDict()
  return firstThreeOctet, startLastOctet, endLastOctet, dic

def scan(addr):
  sock= socket.socket(socket.AF_INET,socket.SOCK_STREAM)
  socket.setdefaulttimeout(1)
  result = sock.connect_ex((addr,135))
  #if result==0:  # this changed to status 111 --> when the machine was alive
  if result==111:
    sock.close()
    return 1
  else :
    sock.close()

def runThread(startLastOctet,endLastOctet):
  for ip in xrange(startLastOctet,endLastOctet):
    addr = firstThreeOctet+str(ip)
    if scan(addr):
      dic[ip]= addr

if __name__ == '__main__':
  subprocess.call('clear',shell=True)
  print "-" * 75
  print "This program search for life IPs in last octet, with multiple threads "
  print "IP/TCP solution"
  print "\tFor example: 192.168.11.xxx - 192.168.11.yyy"
  print "-" * 75
  firstThreeOctet, startLastOctet, endLastOctet, dic = getNetwork()

  startTime= datetime.now()

  total_ip =endLastOctet-startLastOctet
  tn =3 # number of ip handled by one thread
  total_thread = total_ip/tn
  total_thread=total_thread+1
  threads= []
  try:
    for i in xrange(total_thread):
      endPart = startLastOctet+tn
      if(endPart >endLastOctet):
        endPart =endLastOctet
      thread = myThread(startLastOctet,endPart)
      thread.start()
      threads.append(thread)
      startLastOctet =endPart
  except:
    print "Error: unable to start thread"

  print "\t Number of Threads active:", threading.activeCount()
  for t in threads:
    t.join()
  print "Exiting Main Thread"
  sortedIPs = collections.OrderedDict(sorted(dic.items()))
  for key in sortedIPs:
    print "IP address: {} \t --> Live".format(sortedIPs[key])
  endTime= datetime.now()
  totalTime =endTime-startTime
  print "Scanning complete in " , totalTime

