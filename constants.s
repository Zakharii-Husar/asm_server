    # GENERIC CHARACTERS
    .equ space_ascii, 32  

    dot_char: .asciz "."
    dash_char: .asciz "-"
    plus_char: .asciz "+"
    newline_char: .asciz "\n"
    space_char: .asciz " "
    hash_char: .asciz "#"
    semicolon_char: .asciz ":"
    open_square_bracket_char: .asciz "[" 
    close_square_bracket_char: .asciz "]"  
    zero_char: .asciz "0"
    time_separator_char: .asciz "T"
    slash_char: .asciz "/"
    quote_char: .asciz "\""

    # GENERIC STRINGS
    CRLF:        .asciz "\r\n"
    CRLF_length = . - CRLF
    
    # sys_call args
    .equ SYS_read, 0
    .equ SYS_write, 1
    .equ SYS_stdout, 1
    .equ SYS_open, 2
    .equ SYS_close, 3
    .equ SYS_fstat, 5
    .equ SYS_rt_sigaction, 13
    .equ SYS_rt_sigreturn, 15
    .equ SYS_sock_create, 41
    .equ SYS_sock_bind, 49
    .equ SYS_sock_accept, 43
    .equ SYS_sock_listen, 50
    .equ SYS_fork, 57
    .equ SYS_sock_sendto, 44
    .equ SYS_exit, 60
    .equ SYS_time, 201
    .equ SYS_exit_group, 231 # for forceful exit
    # create socket args
    .equ AF_INET, 2 
    .equ SOCK_STREAM, 1
    .equ SOCK_PROTOCOL, 0


    # Buffers sizes
    .equ req_method_B_size, 8
    .equ req_B_size, 1024                  # For reading user request
    .equ req_route_B_size, 256             # For extracted route
    .equ file_path_B_size, 256             # For built file path
    .equ extension_B_size, 32              # For extracted extension
    .equ response_content_B_size, 16777216    # Create a 16MB buffer (16 * 1024 * 1024)

    # HTTP Requests status codes

    .equ HTTP_OK_code, 200
    .equ HTTP_bad_req_code, 400
    .equ HTTP_file_not_found_code, 404
    .equ HTTP_method_not_allowed_code, 405
    .equ HTTP_serve_err_code, 500
    
    # Server Config Struct Field Sizes
    # Essential server settings
    .equ CONF_HOST_SIZE, 256
    .equ CONF_PORT_SIZE, 8
    .equ CONF_PUBLIC_DIR_SIZE, 256
    .equ CONF_DEFAULT_FILE_SIZE, 256      # Moved next to PUBLIC_DIR
    .equ CONF_MAX_CONN_SIZE, 8
    .equ CONF_BUFFER_SIZE_SIZE, 8
    .equ CONF_TIMEZONE_SIZE, 8
    .equ CONF_SERVER_NAME_SIZE, 256

    # Logging related sizes
    .equ CONF_ACCESS_LOG_PATH_SIZE, 256
    .equ CONF_ACCESS_LOG_FD_SIZE, 8
    .equ CONF_ERROR_LOG_PATH_SIZE, 256
    .equ CONF_ERROR_LOG_FD_SIZE, 8
    .equ CONF_WARNING_LOG_PATH_SIZE, 256
    .equ CONF_WARNING_LOG_FD_SIZE, 8
    .equ CONF_SYSTEM_LOG_PATH_SIZE, 256      # Add this
    .equ CONF_SYSTEM_LOG_FD_SIZE, 8          # Add this

    # Struct field offsets
    # Essential server settings offsets
    .equ CONF_HOST_OFFSET, 0
    .equ CONF_PORT_OFFSET, CONF_HOST_OFFSET + CONF_HOST_SIZE
    .equ CONF_PUBLIC_DIR_OFFSET, CONF_PORT_OFFSET + CONF_PORT_SIZE
    .equ CONF_DEFAULT_FILE_OFFSET, CONF_PUBLIC_DIR_OFFSET + CONF_PUBLIC_DIR_SIZE
    .equ CONF_MAX_CONN_OFFSET, CONF_DEFAULT_FILE_OFFSET + CONF_DEFAULT_FILE_SIZE
    .equ CONF_BUFFER_SIZE_OFFSET, CONF_MAX_CONN_OFFSET + CONF_MAX_CONN_SIZE
    .equ CONF_TIMEZONE_OFFSET, CONF_BUFFER_SIZE_OFFSET + CONF_BUFFER_SIZE_SIZE
    .equ CONF_SERVER_NAME_OFFSET, CONF_TIMEZONE_OFFSET + CONF_TIMEZONE_SIZE

    # Logging related offsets
    .equ CONF_ACCESS_LOG_PATH_OFFSET, CONF_SERVER_NAME_OFFSET + CONF_SERVER_NAME_SIZE
    .equ CONF_ACCESS_LOG_FD_OFFSET, CONF_ACCESS_LOG_PATH_OFFSET + CONF_ACCESS_LOG_PATH_SIZE
    .equ CONF_ERROR_LOG_PATH_OFFSET, CONF_ACCESS_LOG_FD_OFFSET + CONF_ACCESS_LOG_FD_SIZE
    .equ CONF_ERROR_LOG_FD_OFFSET, CONF_ERROR_LOG_PATH_OFFSET + CONF_ERROR_LOG_PATH_SIZE
    .equ CONF_WARNING_LOG_PATH_OFFSET, CONF_ERROR_LOG_FD_OFFSET + CONF_ERROR_LOG_FD_SIZE
    .equ CONF_WARNING_LOG_FD_OFFSET, CONF_WARNING_LOG_PATH_OFFSET + CONF_WARNING_LOG_PATH_SIZE
    .equ CONF_SYSTEM_LOG_PATH_OFFSET, CONF_WARNING_LOG_FD_OFFSET + CONF_WARNING_LOG_FD_SIZE
    .equ CONF_SYSTEM_LOG_FD_OFFSET, CONF_SYSTEM_LOG_PATH_OFFSET + CONF_SYSTEM_LOG_PATH_SIZE

    # Total struct size
    .equ SERVER_CONFIG_STRUCT_SIZE, CONF_SYSTEM_LOG_FD_OFFSET + CONF_SYSTEM_LOG_FD_SIZE
    