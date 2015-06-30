import threading, thread
import socket, subprocess,sys
import time
from datetime import datetime
import shelve, collections

class myThread (threading.Thread):
  def __init__(self, threadName,host,startPort,middlePort,timeout):
    threading.Thread.__init__(self)
    self.threadName = threadName
    self.host = host
    self.startPort = startPort
    self.middlePort = middlePort
    self.timeout =timeout
  def run(self):
    scantcp(self.threadName,self.host,self.startPort,self.middlePort,self.timeout)

def scantcp(threadName,host,startPort,middlePort,timeout):
  try:
    for port in range(startPort,middlePort):
      sock= socket.socket(socket.AF_INET,socket.SOCK_STREAM) # TCP
      #sock= socket.socket(socket.AF_INET,socket.SOCK_DGRAM) # UDP
      socket.setdefaulttimeout(timeout)
      result = sock.connect_ex((host,port))
      if result==0:
        dic[port] = "Port: %s is opened; Service %s" % (port, data.get(port, "Not in Database"))
        sock.close()
  except KeyboardInterrupt:
    print "You stop this "
    sys.exit()
  except socket.gaierror:
    print "Hostname could not be resolved"
    sys.exit()
  except socket.error:
    print "could not connect to server"
    sys.exit()
  shelf.close()

def getHostPorts():
  host=''
  while(host==''):
    d=raw_input("\ t Press D for Domain Name or Press I for IP Address\t")
    if (d=='D' or d=='d'):
      rmserver = raw_input("\t Enter the Domain Name to scan:\t")
      host = socket.gethostbyname(rmserver)
    elif(d=='I' or d=='i'):
      host = raw_input("\t Enter the IP Address to scan: ")
    else:
      print "Wrong input"
  startPort = int(raw_input("\t Enter the start port number\t"))
  endPort = int (raw_input("\t Enter the last port number\t"))
  return host, startPort, endPort

def getTimeout():
  conect=raw_input("For low connectivity press L and High connectivity Press H\t")
  if (conect=='L' or conect=='l'):
    timeout =1.5
  elif(conect =='H' or conect=='h'):
    timeout=0.5
  else:
    timeout = 1
    print "\t wrong Input, time connectivity is 1"
  return timeout

def dividePorts (endPort,startPort):
  stepPort=endPort-startPort
  tnumber =30   # tnumber number of port handled by one thread
  tnum=stepPort/tnumber # tnum number of threads
  if (stepPort%tnumber != 0):
    tnum= tnum+1
  if (tnum > 300):
    tnumber = stepPort/300
    tnumber= tnumber+1
    tnum=stepPort/tnumber
    if (stepPort%tnumber != 0):
      tnum= tnum+1
  print "\tNumber of threads: %s" % tnum
  return tnum, tnumber

def multiThreads (tnum, startPort, tnumber, timeout, host):
  threads= []
  try:
    for i in range(tnum):
      middlePort=startPort+tnumber
      thread = myThread("T%s" %i,host,startPort,middlePort,timeout)
      thread.start()
      threads.append(thread)
      startPort=middlePort
  except:
    print "Error: unable to start thread"
  print "\t Number of Threads active:", threading.activeCount()
  for t in threads:
    t.join()
  print "Exiting Main Thread"

if __name__ == '__main__':
  subprocess.call('clear',shell=True)
  shelf = shelve.open("Scan_ports.raj")
  data=(shelf['desc'])
  dic = collections.OrderedDict()
  print "-"*75
  print " \tPort scanner\n "
  host, startPort, endPort = getHostPorts()
  timeout = getTimeout()
  print "\n Scanner is working on ",host
  print "-"*75
  startTime= datetime.now()
  tnum,tnumber = dividePorts(endPort,startPort)
  multiThreads (tnum, startPort, tnumber, timeout, host)
  sortDict = collections.OrderedDict(sorted(dic.items()))   # sort ports
  for key in sortDict:
    print sortDict[key],":-)"
  endTime= datetime.now()
  totalTime =endTime-startTime
  print "Scanning complete in: " , totalTime


