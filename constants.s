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
    .equ SYS_time, 201
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

    # Buffers sizes
    .equ req_method_B_size, 8
    .equ req_B_size, 1024                  # For reading user request
    .equ req_route_B_size, 256             # For extracted route
    .equ file_path_B_size, 256             # For built file path
    .equ extension_B_size, 32              # For extracted extension
    .equ response_content_B_size, 16777216    # Create a 16MB buffer (16 * 1024 * 1024)
    .equ response_B_size, 4096             # Add this line

    # HTTP Requests status codes

    .equ HTTP_OK_code, 200
    .equ HTTP_bad_req_code, 400
    .equ HTTP_file_not_found_code, 404
    .equ HTTP_method_not_allowed_code, 405
    .equ HTTP_serve_err_code, 500
    