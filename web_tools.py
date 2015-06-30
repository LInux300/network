import urllib, subprocess, random, re
from bs4 import BeautifulSoup  # http://www.crummy.com/software/BeautifulSoup/bs4/doc/#
import socket, struct, binascii

class Web():

  def getHeader(self, url):
    """Get Header Info"""
    http_r = urllib.urlopen(url)
    if http_r.code == 200:
      return http_r.headers
    else:
      return "No Header"

  def getBsObject(self, url):
    ht= urllib.urlopen(url)
    html_page = ht.read()
    bs_object = BeautifulSoup(html_page)
    return bs_object    

  def getParticularClass(self,url):
    bs_object = self.getBsObject(url)
    """Get All Repository from the Github"""
    repos = bs_object.findAll('span', {'class':"repo"})
    return repos

  def getLinks(self, url):
    bs_object = self.getBsObject(url)
    print bs_object.title.text
    for link in bs_object.find_all('a'):
       print(link.get('href'))
  
  def errorHandling(self, url):
    u = chr(random.randint(97,122))
    url2 = url+u
    http_r = urllib.urlopen(url2)
    content= http_r.read()
    flag =0
    i=0
    list1 = []
    a_tag = "<*address>"
    file_text = open("web_error_handling_result.txt",'a')
    while flag ==0:
      if http_r.code == 404:
        file_text.write("--------------")
        file_text.write(url)
        file_text.write("--------------\n")
        file_text.write(content)
        for match in re.finditer(a_tag,content):
          i=i+1
          s= match.start()
          e= match.end()
          list1.append(s)
          list1.append(e)
        if (i>0):
          print "Coding is not good"
        if len(list1)>0:
          a= list1[1]
          b= list1[2]
          print content[a:b]
        elif http_r.code == 200:
          print "Web page is using custom Error Page"
          break
        else:
          print "Error handling seems to be OK."
          flag =1
        
  def bannerGrabber(self):
    """Banner grabbing or OS fingerprinting is a method to determine the operating system that is running on a target web server"""
    s = socket.socket(socket.PF_PACKET, socket.SOCK_RAW, socket.ntohs(0x0800))
    while True:
      pkt = s.recvfrom(2048)
      banner = pkt[0][54:533]
      print banner
      print "--"*40

if __name__ == '__main__':
  subprocess.call('clear',shell=True)
  myWeb = Web()
  url = "https://github.com/rudolfvavra"
  print myWeb.getParticularClass(url)
  print myWeb.getHeader(url)
  myWeb.getLinks(url)
  myWeb.errorHandling(url)
  #myWeb.bannerGrabber()   # have to run as sudo user
