    # sys_call args
    .equ SYS_write, 1
    .equ SYS_stdout, 1
    .equ SYS_sock_create, 41
    .equ SYS_sock_bind, 49
    .equ SYS_sock_accept, 43
    .equ SYS_sock_listen, 50
    .equ SYS_exit, 60

    # create socket args
    .equ AF_INET, 2 
    .equ SOCK_STREAM, 1
    .equ SOCK_PROTOCOL, 0

    .equ sock_created_msg_length, 19
     sock_created_msg:    .asciz "Socket was created\n"

    # sock bind args
    .equ PORT, 0x901F      # Port number (8080) in network byte order (use htons equivalent in assembly)
    .equ IP_ADDR, 0    # IP address (0.0.0.0 - binds to all interfaces)
    .equ PADDING, 8    # Padding (8 bytes to make the structure 16 bytes in total)

    .equ sock_bound_msg_length, 17
     sock_bound_msg:    .asciz "Socket was bound\n"

    # sock listen args
    .equ connection_backlog, 10   # backlog (max number of queued connections)

    .equ sock_listen_msg_length, 43
     sock_listen_msg:    .asciz "Socket is listening on http://0.0.0.0:8080\n"

    # client connected message
      .equ client_connected_msg_length, 18
     client_connected_msg:    .asciz "Client connected!\n"


    addr_in:
    .word   AF_INET
    .word   PORT
    .long   IP_ADDR
    .space  PADDING

    # Define HTTP response
    response:
        .ascii  "HTTP/1.1 200 OK\r\n"
        .ascii  "Content-Length: 13\r\n"
        .ascii  "Content-Type: text/plain\r\n"
        .ascii  "\r\n"
        .ascii  "Hello, World!\r\n"

    response_len = . - response
