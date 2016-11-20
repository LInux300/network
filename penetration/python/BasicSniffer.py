import socket

# USAGE: terminal_1: python BasicSniffer.py
#        terminal_2: ping 192.168.0.103 -c 3

# create the sniffer the raw socket obj
#   listening for ICMP packets
#   can also TCP packet or UDP packet
sniffer = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_ICMP)

# bind to localhost, port 0 is officially a reserved port in TCP networking
# port 0 is programming technique for specifying allocation the ports
# in this case 0 is connection parametr and operation system 
# will automaticaly search for next avaiable port in dynamic port range
sniffer.bind(('0.0.0.0',0))

# make sure that the IP header is included
sniffer.setsockopt(socket.IPPROTO_IP, socket.IP_HDRINCL,1)

print 'sniffer is listening for incoming connections'

# get a single packet
print sniffer.recvfrom(65535)
