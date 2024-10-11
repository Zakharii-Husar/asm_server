### CREATING WEB SOCKET

1. Creating a TCP socket requires 3 parameters:

-domain in my case is TCP/IP. [AF_INET(Address family internet)](https://www.ibm.com/docs/en/i/7.3?topic=families-using-af-inet-address-family) . AF_INET is used for IPv4 while AF_INET6 is for  IPv6.

-type specify the type of socket (read the AF_INET link above).In my case I'm using connection oriented address family sockets (type SOCK_STREAM) which is used fo TCP protocol, as opposed to connectionless (type SOCK_DGRAM) UDP or raw network protocol (type SOCK_RAW) as the transport protocol.

-protocol is usually zero by default which means it's gonna let the system "decide" which protocol to use based on previous 2 parameters, e.g.:
````
AF_INET + SOCK_STREAM → TCP (IPPROTO_TCP)
AF_INET + SOCK_DGRAM → UDP (IPPROTO_UDP)
AF_INET6 + SOCK_STREAM → TCP (IPPROTO_TCP)
AF_INET6 + SOCK_DGRAM → UDP (IPPROTO_UDP)
````