## REGISTERS

### Callee-Saved Registers:
- **%rbx** holding TCP Socket File Descriptor.
- **%r12** hodling Connection FIle Descriptor. 



## CREATING AND BINDING TCP SOCKET

### 1. sock_create

Parameters: none
Return values: none.
Side effects: creating a TCP socket and storing its FD in **%rbx**.

The syscall for creating a TCP socket requires 3 parameters:

 1. **%rdi**: domain in my case is TCP/IP. [AF_INET(Address family internet)](https://www.ibm.com/docs/en/i/7.3?topic=families-using-af-inet-address-family) . AF_INET is used for IPv4 while AF_INET6 is for  IPv6.
 2. **%rsi**: type specify the type of socket (read the AF_INET link above).In my case I'm using connection oriented address family sockets (type SOCK_STREAM) which is used fo TCP protocol, as opposed to connectionless (type SOCK_DGRAM) UDP or raw network protocol (type SOCK_RAW) as the transport protocol.
 3. **%rdx**: protocol is usually zero by default which means it's gonna let the system "decide" which protocol to use based on previous 2 parameters, e.g.:
 ````
 AF_INET + SOCK_STREAM → TCP (IPPROTO_TCP)
 AF_INET + SOCK_DGRAM → UDP (IPPROTO_UDP)
 AF_INET6 + SOCK_STREAM → TCP (IPPROTO_TCP)
 AF_INET6 + SOCK_DGRAM → UDP (IPPROTO_UDP)
 ````

After successfully making the syscall the TCP Socket [fd (file descriptor)](https://en.wikipedia.org/wiki/File_descriptor#:~:text=In%20Unix%20and%20Unix%2Dlike,a%20pipe%20or%20network%20socket.) is daved to **%rbx** register.


### 2.sock_bind

Parameters: none.
Return values: none.
Side effects: biding the created above socket to specific IP address and port.

The syscall for binding the above created  TCP socket takes 2 parameters:

 1. **%rdi**: socket file descriptor saved in **%rbx** during socket creation.
 2. **%rsi** : an address structure (**addr_in**), which contains the **address family**, **port**, and **IP address**.

### 3. sock_listen

Parameters: none.
Return values: none.
Side effects: Listening for incoming connection on specified address, port and protocol.

The listening syscall takes 2 arguments:

 1. **%rdi**: socket file descriptor (saved in **%rbx** while creating socket).
 2. **%rsi**: backlog (number of maximum connections that caan be in the que while server is busy to process their requests).

### 4. sock_accept

Parameters: none.
Return values: none.
Side effects: handling incoming connections.

Here we get the control over connection handling. It runs a loop and does following:

 1. Takes the earlier created and bound socket.
 2. Block (wait) until client tries to onnect.
 3. When a client connects, create a new socket for communication with that client.
 4. Return the file descriptor for the new socket, which will be used to send/receive data to/from that specific client.

Syscall parameters for accepting a connection:

 1. **%rdi**:  the listening socket file descriptor (in **%rbx** since socket creation).
 2. **rsi**: A pointer to a struct sockaddr where the client address will be stored (in my case I don't care about it so passing zero).
 3. **%rdx**: a pointer to a length of the address. Since I'm not providing an address in this example, this is also NULL

When connection is accepted its file descriptor is saved in **%rdi**.

The new socket file descriptor (now in **%rdi**) is the one I'll use to send and receive data with this client, such as responding to HTTP requests. The original listening socket (in **%rbx**) remains open for further connections.

It's possible to use syscalls like **read** and **write** on this new socket to interact with the client.

After handling the connection, I can loop back and wait for the next connection by calling accept again.

### 5. sock_fork

Parameters: none.
Return values: in **%rax** parent process returns child PID, child returns 0.
Side effects: Creates a new process by duplicating the current process.

The syscall fork doesn't take any parameters and creates an  exact copy of the current process. After fork, the child process runs independently of the parent and can execute different code or continue running the same program.
Based on **sock_for** return value I decide to jump to **fork_handle_child** or 
**fork_handle_parent**.

### 6. fork_handle_child
Parameters: none.
Return values: none.
Side effects: handling particular user interaction (request/response):

1. Send response.
2. Close connection.
3. Exit program (kill child process).

### 7. fork_handle_parent
Parameters: none.
Return values: none.
Side effects: Close connection.

### 8. sock_respond
Parameters: none.
Return values: none.
Side effects: Sending HTTP response to the client.

System call sendto(44) takes following parameters:

1. **%rdi** connection FD.
2. **%%rsi** address to the response.
3. **%rdx** data length.
4. **%r10** flags(type int): 0 (by default) do nothing, MSG_DONTWAIT, MSG_CONFIRM. 

Also (especially for UDP) destination address and destination length (but I omited since using already connected socket).

### 9. sock_close_conn

Parameters: **%rdi** boolean value (0 to indicate parent process, 1 for child).
Return values: none.
Side effects: Closing connection for parent and child.

The syscall for closing the connection takes 1 argument in **%rdi**: the connection File Descriptor.

## UTILS

### 1. print_info

Parameters:
- **%rsi** holds pointer to the string.
- **%rdx** holds length of the string.
Return value: void.
Side effects: making a system call to write to stdout.

Placed logic for printig any information to the terminal (status updates, errors etc). **%rax** and **%rdi** registers had to be pushed on stack before executing the function's code and popped back after the syscall to prevent register clobbering (otherwise the function was interfering with the Socket functions which were using the same registers while printing status updates about socket creation, binding etc).

### 2. int_to_string
Parameters:
- **%rdi** accepting an integer to convert to string.
- 
Return values: 
- **%rax** points to the first string character in the buffer.
- **%rdx** contains the string length.

Side effects: none.

To convert an integer to string i had to do the following:
 - Iterate through each digit in the number;
 - Convert it from ASCII number to string encoding;
 - Push the newly converted digit to a buffer;
 - Add zero character to the buffer to indicate the end of the string;

Iterating through a number was achieved by dividing dividend (the input number) by 10, which will cause the reminder(the number after the digit) to be the last digit of dividend and quotient (the result of the division) to be all the digits of the dividend except of reminder.
This is set up in a loop **jnz** starts it all over until quotient is zero. 

The only problem with that algorithm is that every iteration it always returns the last (least sagnificant) digit from the number. And if i push it directly to the buffer the whole number will be reversed. So Instead I'm writing from left to right in the buffer: loading buffer's effective address, then adding  buffer's length to buffer pointer to move the pointer in the end of the buffer. First character that will be written in the buffer is the string terminator(since technically it's in the end of the string): ``movb $0, (%rsi)``. After that, inside of a loop I decrement buffer pointer to move it backwards and start writing digits.

The way each character is converted inside of this loop is by **addb** instruction which takes the reminder value from **%dl** (which is lower part of **%rdx**)  and adds '0' to it (because in ASCII it represents 48 in decimal, could use either '0' or 48) for each digit. Since offset between a digit as integer and digit as a character for each digit is 48 in ASCII, for example:
digit 0 will be '0' as ASCII character and 48 as ASCII Value (Decimal), and digit 1 will be '1' as ASCII Character and 49 as ASCII Value (Decimal) and so on.

Then converted character is getting moved to the buffer: ``movb %dl, (%rsi)`` (**%rsi** holds current buffer position). After that we check if qutient is zero and either exit loop or decrement current buffer position by 1 byte and increment the string length counter.

### 3. file_open


