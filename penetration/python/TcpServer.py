import socket
import threading
import argparse

def serveClient(clientToServeSocket, clientIPAddress, portNumber):
  # to receive data from client 
  clientRequest = clientToServeSocket.recv(4096)
  print "[!] Received data from the client (%s:%d):%s" % (clientIPAddress, portNumber, clientRequest)

  # reply back to client with a response
  clientToServeSocket.send("Server response, test me")
  clientToServeSocket.close()

def startServer(portNumber):
  server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  # servis is listening on all configured network interfaces
  server.bind(("0.0.0.0", portNumber))
  server.listen(20)
  print "[!] Listening locally on port %d ..." % portNumber

  while True:
    client, address = server.accept()
    print "[+] Connected with the client: %s:%d " % (address[0],address[1])

    # Handle clients through multi threading, advance listening
    serveClientThread = threading.Thread(target=serveClient, args=(client,address[0],address[1]))
    serveClientThread.start()

def main():
  parser = argparse.ArgumentParser('TCP Server')
  parser.add_argument("-p", "--port", type=int, help="The port number to connect with", default=5678)
  args = parser.parse_args()

  portNumber = args.port

  startServer(portNumber)

if __name__ == "__main__":
  main()
