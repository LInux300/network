import socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
host = "192.168.11.252" # server address
port =12345 #server port
#buf = bytearray("-" * 30) # buffer created
#print "Number of Bytes ",s.recv_into(buf)
#print buf
s.connect((host,port))
print s.recv(1024)
s.send("Hello Server")
s.close()
