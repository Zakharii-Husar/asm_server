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

## Configure & Deploy

### Compilation Instructions
1. **Navigate to the Project Directory**
   ```bash
   cd asm_server
   ```

2. **Compile the Server**
   Run the `compile_script.sh` script:
   ```bash
   ./compile_script.sh
   ```

   To compile with debug symbols, use the following command:
   ```bash
   ./compile_script.sh debug_mode
   ```

3. **Run the Server**
   After compilation, execute the server binary:
   ```bash
   ./asm_server
   ```

### Configuration Details

The server requires a configuration file named `server.conf` to be in the same directory as the server binary. If this file is missing or contains invalid/missing values, the server will fall back to default values. Warnings about missing or invalid values will be logged in the `warning.log` file.

#### Example `server.conf` File
```plaintext
# For changing the server config, edit this file and restart the server
#----------------------
# Essential Settings
#----------------------
HOST=localhost           # Host to listen on
PORT=8080                # Port to listen on
PUBLIC_DIR=./public      # Public directory
DEFAULT_FILE=index.html  # Default file to serve

#----------------------
# Server Behavior
#----------------------
MAX_CONN=100             # Maximum number of connections
BUFFER_SIZE=16777216     # Response MAX buffer size
TIMEZONE=-0600           # UTC offset

#----------------------
# Server Identity
#----------------------
SERVER_NAME=MyASMServer/1.0    # Server name
ACCESS_LOG_PATH=./log/access.log  # Access log path
WARNING_LOG_PATH=./log/warning.log # Warning log path
ERROR_LOG_PATH=./log/error.log    # Error log path
SYSTEM_LOG_PATH=./log/system.log  # System log path
```

### Default Hardcoded Fallback Values
In case the `server.conf` file is missing or some values are invalid, the server will use the following default settings:
- **Host**: `localhost`
- **Port**: `8080`
- **Public Directory**: `./public`
- **Default File**: `index.html`
- **Maximum Connections**: `100`
- **Buffer Size**: `16777216`
- **Timezone**: `-0600`
- **Server Name**: `MyASMServer/1.0`
- **Access Log Path**: `./log/access.log`
- **Warning Log Path**: `./log/warning.log`
- **Error Log Path**: `./log/error.log`
- **System Log Path**: `./log/system.log`

### Logs
If log files at the configured/default paths do not exist, they will be created automatically. A warning will be logged in the `warning.log` file. The following log files are used:
- **Access Log**: Tracks all HTTP requests.
- **Warning Log**: Logs warnings, such as missing or invalid configuration values.
- **Error Log**: Logs server errors.
- **System Log**: Logs system events.

### HTTP Error Pages
For proper error handling, you must create the following HTTP error pages in the `public` directory:
- `400.html` — Bad Request
- `404.html` — Not Found
- `405.html` — Method Not Allowed
- `500.html` — Internal Server Error


### Deployment Notes
1. **Restart Required**: After modifying the `server.conf` file, restart the server to apply changes.
2. **Directory Structure**: Ensure that the following directories and files are correctly set up:
   - `public` directory with HTML files (e.g., `index.html`, error pages).
   - `log` directory for log files (these will be created if missing).
   - `server.conf` file in the same directory as the server binary.

By following these steps, you can compile, configure, and deploy the server successfully.



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

## Project Structure
```
asm_server
├── asm_server
├── compile_script.sh
├── readme.md
├── server.conf
├── log
│   ├── access.log
│   ├── error.log
│   ├── system.log
│   └── warning.log
├── public
│   ├── 400.html
│   ├── 404.html
│   ├── 405.html
│   ├── 500.html
│   └── www
│       ├── favicon.ico
│       ├── ford.jpg
│       ├── index.css
│       ├── index.html
│       └── index.js
└── src
    ├── constants.s
    ├── main.s
    ├── mods
    │   ├── exit_program.s
    │   ├── fork_handle_child.s
    │   ├── fork_handle_parent.s
    │   ├── process_fork.s
    │   ├── server_shutdown.s
    │   ├── signal_handler.s
    │   ├── sock_accept.s
    │   ├── sock_bind.s
    │   ├── sock_close_conn.s
    │   ├── sock_create.s
    │   ├── sock_listen.s
    │   ├── sock_read.s
    │   └── sock_respond.s
    └── utils
        ├── build_file_path.s
        ├── core
        │   ├── io
        │   │   ├── file_open.s
        │   │   └── print_info.s
        │   ├── memory
        │   │   └── clear_buffer.s
        │   ├── str
        │   │   ├── int_to_str.s
        │   │   ├── str_cat.s
        │   │   ├── str_cmp.s
        │   │   ├── str_contains.s
        │   │   ├── str_find_char.s
        │   │   ├── str_len.s
        │   │   ├── str_to_int.s
        │   │   └── str_to_lower.s
        │   └── validation
        │       └── validate_file_path.s
        ├── server
        │   ├── config
        │   │   ├── init_srvr_config.s
        │   │   ├── logging
        │   │   │   ├── log_access.s
        │   │   │   ├── log_err.s
        │   │   │   ├── log_sys.s
        │   │   │   ├── log_warn.s
        │   │   │   └── open_log_files.s
        │   │   ├── network
        │   │   │   ├── htons.s
        │   │   │   └── ip_to_network.s
        │   │   ├── parse_srvr_config.s
        │   │   ├── validate_config.s
        │   │   └── write_config_struct.s
        │   └── http
        │       ├── headers
        │       │   ├── create_length_header.s
        │       │   ├── create_server_header.s
        │       │   ├── create_status_header.s
        │       │   └── create_type_header.s
        │       └── request
        │           ├── extract_client_ip.s
        │           ├── extract_extension.s
        │           ├── extract_method.s
        │           └── extract_route.s
        └── time
            ├── adjust_timezone.s
            ├── format_time.s
            ├── get_days_in_month.s
            ├── get_time_now.s
            ├── get_timestamp.s
            └── is_leap_year.s
```