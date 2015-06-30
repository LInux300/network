import socket, errno
import sys, getopt, subprocess

class Ports:

  def __init__(self, origHost="localhost"):
    print "-" * 75
    print "Scanning Open Ports, example: $python Ports.py --host localhost -s 79 -e 83"
    print "\tHost Name is: %s" % origHost
    self.origHost = socket.gethostbyname(origHost)

  def find_open_port(self, min_port=1, max_port=65535):
    print "\tScan open ports from: %s to %s for ip: %s" % (min_port, max_port, self.origHost)
    print "-" * 75
    try:
      for port in range(min_port, max_port):
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        result = sock.connect_ex((self.origHost, port))
        if result == 0:
          try:
            print "Port: {} \t --> Open \t Service: %s".format(port) % socket.getservbyport(port)
          except:
            print "Port: {} \t --> Open".format(port)
        #else:
        #  print "Port %s is not open" % port
    except KeyboardInterrupt:
      print "You pressed Ctrl+C :-)"
      sys.exit()
    except socket.gaierror:
      print 'Hostname "%s" could not be resolved. Exiting' % self.origHost
      sys.exit()
    except socket.error, e:
      print e[1]
      #raise e
      sys.exit()

def getPorts(argv):
   startport = 1
   endport = 65535
   hostname = "localhost"
   try:
      opts, args = getopt.getopt(argv,"hs:e:host:",["sport=","eport=", "hostname="])
   except getopt.GetoptError:
      print 'Ports.py -s <startport> -e <endport> --host <hostname>'
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print 'Ports.py -s <startport> -e <endport> --host <hostname>'
         sys.exit()
      elif opt in ("-s", "--sport"):
         startport = arg
      elif opt in ("-e", "--eport"):
         endport = arg
      elif opt in ("--host", "--hostname"):
         hostname = arg
   return int(startport), int(endport), hostname

if __name__ == '__main__':
  subprocess.call('clear',shell=True)
  startport, endport, hostname = getPorts(sys.argv[1:])
  aPorts = Ports(hostname)
  aPorts.find_open_port(startport, endport)



