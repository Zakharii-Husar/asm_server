    # sys_call args
    .equ SYS_write, 1
    .equ SYS_sock_create, 41
    .equ SYS_sock_bind, 49
    .equ SYS_sock_accept, 43
    .equ SYS_sock_listen, 50
    .equ SYS_exit, 60

    # create socket args
    .equ AF_INET, 2 
    .equ SOCK_STREAM, 1
    .equ SOCK_PROTOCOL, 0

    .equ msg_length, 18
     msg:    .asciz "Socket was created"

        # sock bind args
    .equ PORT, 0x901F      # Port number (8080) in network byte order (use htons equivalent in assembly)
    .equ IP_ADDR, 0    # IP address (0.0.0.0 - binds to all interfaces)
    .equ PADDING, 8    # Padding (8 bytes to make the structure 16 bytes in total)

    # sock listen args
    .equ connection_backlog, 10   # backlog (max number of queued connections)

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
