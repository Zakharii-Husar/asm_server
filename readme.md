# ASM Server

A lightweight HTTP server written entirely in x86_64 assembly language for Linux systems.

## Overview

This project implements a fully functional HTTP server in assembly language, capable of:
- Serving static files
- Handling concurrent connections through process forking
- Configurable settings via server.conf
- Comprehensive logging system
- Graceful shutdown handling

## Features

- **Pure Assembly**: Written entirely in x86_64 assembly language
- **Configuration**: Customizable through server.conf file
- **Logging System**: Separate logs for access, errors, warnings, and system events
- **Static File Serving**: Serves files from configured public directory
- **Process Management**: Uses forking for handling concurrent connections
- **Error Pages**: Custom error pages for 400, 404, 405, and 500 responses
- **Signal Handling**: Graceful shutdown on SIGINT (Ctrl+C)

## Configuration

The server can be configured through `server.conf`:

## REGISTERS

### Callee-Saved Registers:
- **%r12** holding the socket FD;
- **%r13** holding Connection FD;
- **%r14** holding the client's IP after sock_accept call;
- **%r15** holds all the server's configuration after parsing configure values (host, port, default directories etc) if parsing server.conf was successful, otherwise hardcoded fallback values;



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

If socket creation was successful, we're making a syscall to set the SO_REUSEADDR option to 1. This option allows the socket to reuse the address even if it's already in use by another socket.
The reason I added this, because I want to be able to restart the server without having to wait for the port to be released.


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
 2. Block (wait) until client tries to connect.
 3. When a client connects, create a new socket for communication with that client.
 4. Return the file descriptor for the new socket, which will be used to send/receive data to/from that specific client.

Syscall parameters for accepting a connection:

 1. **%rdi**:  the listening socket file descriptor (in **%r12** since socket creation).
 2. **%rsi**: A pointer to a struct sockaddr where the client address will be stored (in my case I don't care about it so passing zero).
 3. **%rdx**: a pointer to a length of the address. Since I'm not providing an address in this example, this is also NULL

When connection is accepted its file descriptor is saved in **%r13**.

The new socket file descriptor (in **%r13**) is the one I'll use to send and receive data with this client, such as responding to HTTP requests. The original listening socket (in **%r12**) remains open for further connections.

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

1. **%rdi** connection FD (copied from **%r13**).
2. **%rsi** address to the response.
3. **%rdx** data length.
4. **%r10** flags(type int): 0 (by default) do nothing, MSG_DONTWAIT, MSG_CONFIRM. 

Also (especially for UDP) destination address and destination length (but I omited since using already connected socket).

### 9. sock_close_conn

Parameters: **%rdi** boolean value (0 to indicate parent process, 1 for child).
Return values: none.
Side effects: Closing connection for parent and child.

The syscall for closing the connection takes 1 argument in **%rdi**: the connection File Descriptor.

## Configuration, Validation & Logging System
The server has robust configuration, validation and logging system with fallbacks to default values.

### Configuration & Validation flow
- Configuration file is parsed.
- Log files are opened based on config paths or created if files or paths are missing.
- If something was missing it's reported to warning log.
- Configuration values are validated.
- If something was missing it's reported to warning log.

### Configuration **File**
The server uses a configuration file located at `./conf/server.conf`. Each setting follows the format: KEY=VALUE.

### Configuration **Parsing**
All configuration values are initialized in the `server_init` function
with 0s for strings and -1 for numbers.
The server parses the configuration file upon startup. Found values rewrite 0s or -1 .If some values are missing, the parser skips them.

### Configuration **Validation**
The server validates provided config values in the global struct. If some values are missing(or even if the whole file is missing), the server falls back to default values.

### Logging **System**
The server uses a logging system to record access, error, warning, and system events. Logs are stored in the `./logs` directory.

### Error **Pages**
The server uses custom error pages for 400, 404, 405, and 500 responses.

### Graceful **Shutdown**
The server handles graceful shutdown on SIGINT (Ctrl+C)
by preventing exiting immediately and instead waiting for all the connections and files to be closed.

## Supported File Formats

The server supports serving the following file types with appropriate MIME types:

### Web Documents
- HTML (`.html`) - `text/html`
- CSS (`.css`) - `text/css`
- JavaScript (`.js`) - `text/javascript`

### Images
- JPEG (`.jpg`, `.jpeg`) - `image/jpeg`
- PNG (`.png`) - `image/png`
- GIF (`.gif`) - `image/gif`
- WebP (`.webp`) - `image/webp`
- SVG (`.svg`) - `image/svg+xml`
- ICO (`.ico`) - `image/x-icon`

All other file types will be served as `application/octet-stream` by default.

## Security

### Preventing Buffer Overflows
The server uses size checks everywhere (functions like str_cat).
If the size of the string is greater than the buffer, the function will truncate the string and writes entry to the error log.

### Preventing Directory Traversal
The server checks for directory traversal in the file path.
If the path contains "..\" or "../" or ".." or "%", the server will not serve the file and writes entry to the error log.

### HTTP Request Validation
The server validates the HTTP request.
Only GET requests are supported.
If the request is not valid, the server will serve 405 error page.
