    # sys_call args
    .equ SYS_read, 0
    .equ SYS_write, 1
    .equ SYS_open, 2
    .equ SYS_close, 3
    .equ SYS_fstat, 5
    .equ SYS_stdout, 1
    .equ SYS_sock_create, 41
    .equ SYS_sock_bind, 49
    .equ SYS_sock_accept, 43
    .equ SYS_sock_listen, 50
    .equ SYS_fork, 57
    .equ SYS_sock_sendto, 44
    .equ SYS_exit, 60

    # create socket args
    .equ AF_INET, 2 
    .equ SOCK_STREAM, 1
    .equ SOCK_PROTOCOL, 0

    # sock bind args
    .equ PORT, 0x901F      # Port number (8080) in network byte order (use htons equivalent in assembly)
    .equ IP_ADDR, 0    # IP address (0.0.0.0 - binds to all interfaces)
    .equ PADDING, 8    # Padding (8 bytes to make the structure 16 bytes in total)


    # sock listen args
    .equ connection_backlog, 10   # backlog (max number of queued connections)

    # Max size for respons content buffer
    .equ response_content_buffer_size, 8192