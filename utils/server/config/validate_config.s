.section .data
# Error messages for each config key
host_err_msg: .asciz "MODERATE: No valid host was provided. Using default 0.0.0.0 in validate_config.s"
host_err_msg_len = . - host_err_msg

port_err_msg: .asciz "MODERATE: Invalid port (must be between 1-65535). Using default 8080 in validate_config.s"
port_err_msg_len = . - port_err_msg

buffer_err_msg: .asciz "MODERATE: Invalid buffer size (must be between 1KB-64MB). Using default 16MB in validate_config.s"
buffer_err_msg_len = . - buffer_err_msg

conf_timezone_err_msg: .asciz "MODERATE: Invalid timezone offset (must be between -1200 and +1400). Using default 0 in validate_config.s"
conf_timezone_err_msg_len = . - conf_timezone_err_msg

max_conn_err_msg: .asciz "MODERATE: Invalid max connections (must be between 1-1000). Using default 100 in validate_config.s"
max_conn_err_len = . - max_conn_err_msg

public_dir_err_msg: .asciz "MODERATE: Invalid public directory path. Using default ./public in validate_config.s"
public_dir_err_len = . - public_dir_err_msg

default_file_err_msg: .asciz "MODERATE: Invalid default file. Using default index.html in validate_config.s"
default_file_err_len = . - default_file_err_msg

server_name_err_msg: .asciz "MODERATE: Invalid server name. Using default MyASMServer/1.0 in validate_config.s"
server_name_err_len = . - server_name_err_msg

# Default values
.default_port_str: .asciz "8080"
.default_host_str: .asciz "0.0.0.0"
.default_buffer: .quad 16777216  # 16MB
.default_timezone: .quad 0
.default_max_conn: .quad 100
.default_public_dir: .asciz "./public"
.default_file: .asciz "index.html"
.default_server_name: .asciz "MyASMServer/1.0"

.section .text
.type validate_config, @function
validate_config:
    push %rbp
    mov %rsp, %rbp
    push %r12
    push %r13
    
    # 1. Validate HOST
    mov CONF_HOST_OFFSET(%r15), %eax    # Get the network-formatted IP
    cmp $-1, %eax                       # Check if uninitialized (-1)
    je .invalid_host                    # Jump if uninitialized
    jmp .check_port

.invalid_host:
    lea host_err_msg(%rip), %rdi
    mov $host_err_msg_len, %rsi
    xor %rdx, %rdx
    call log_err
    # Convert default host to network format
    lea .default_host_str(%rip), %rdi
    call ip_to_network
    mov %eax, CONF_HOST_OFFSET(%r15)    # Store the network-formatted IP

.check_port:
    # 2. Validate PORT
    movzwl CONF_PORT_OFFSET(%r15), %eax  # Zero-extend 16-bit port to 32-bit
    cmp $1, %eax
    jl .invalid_port
    cmp $65535, %eax
    jg .invalid_port
    jmp .check_buffer_size

.invalid_port:
    lea port_err_msg(%rip), %rdi
    mov $port_err_msg_len, %rsi
    xor %rdx, %rdx
    call log_err
    # Convert default port to network format
    lea .default_port_str(%rip), %rdi
    call str_to_int
    mov %rax, %rdi
    call htons
    movw %ax, CONF_PORT_OFFSET(%r15)

.check_buffer_size:
    # 3. Validate BUFFER_SIZE
    mov CONF_BUFFER_SIZE_OFFSET(%r15), %rax
    cmp $1024, %rax           # Min 1KB
    jl .invalid_buffer
    cmp $67108864, %rax      # Max 64MB
    jg .invalid_buffer
    jmp .check_timezone

.invalid_buffer:
    lea buffer_err_msg(%rip), %rdi
    mov $buffer_err_msg_len, %rsi
    xor %rdx, %rdx
    call log_err
    mov .default_buffer(%rip), %rax
    mov %rax, CONF_BUFFER_SIZE_OFFSET(%r15)

.check_timezone:
    # 4. Validate TIMEZONE
    mov CONF_TIMEZONE_OFFSET(%r15), %rax
    cmp $1400, %rax
    jg .invalid_timezone
    cmp $-1200, %rax
    jl .invalid_timezone
    jmp .check_max_conn

.invalid_timezone:
    lea conf_timezone_err_msg(%rip), %rdi
    mov $conf_timezone_err_msg_len, %rsi
    xor %rdx, %rdx
    call log_err
    mov .default_timezone(%rip), %rax
    mov %rax, CONF_TIMEZONE_OFFSET(%r15)

.check_max_conn:
    # 5. Validate MAX_CONN
    mov CONF_MAX_CONN_OFFSET(%r15), %rax
    cmp $1, %rax
    jl .invalid_max_conn
    cmp $1000, %rax
    jg .invalid_max_conn
    jmp .check_public_dir

.invalid_max_conn:
    lea max_conn_err_msg(%rip), %rdi
    mov $max_conn_err_len, %rsi
    xor %rdx, %rdx
    call log_err
    mov .default_max_conn(%rip), %rax
    mov %rax, CONF_MAX_CONN_OFFSET(%r15)

.check_public_dir:
    # 6. Validate PUBLIC_DIR (check if empty)
    lea CONF_PUBLIC_DIR_OFFSET(%r15), %rdi
    call str_len
    cmp $0, %rax
    je .invalid_public_dir
    jmp .check_default_file

.invalid_public_dir:
    lea public_dir_err_msg(%rip), %rdi
    mov $public_dir_err_len, %rsi
    xor %rdx, %rdx
    call log_err
    lea CONF_PUBLIC_DIR_OFFSET(%r15), %rdi
    lea .default_public_dir(%rip), %rsi
    xor %rdx, %rdx
    mov $CONF_PUBLIC_DIR_SIZE, %rcx
    call str_concat

.check_default_file:
    # 9. Validate DEFAULT_FILE
    lea CONF_DEFAULT_FILE_OFFSET(%r15), %rdi
    call str_len
    cmp $0, %rax
    je .invalid_default_file
    jmp .check_server_name

.invalid_default_file:
    lea default_file_err_msg(%rip), %rdi
    mov $default_file_err_len, %rsi
    xor %rdx, %rdx
    call log_err
    lea CONF_DEFAULT_FILE_OFFSET(%r15), %rdi
    lea .default_file(%rip), %rsi
    xor %rdx, %rdx
    mov $CONF_DEFAULT_FILE_SIZE, %rcx
    call str_concat

.check_server_name:
    # 10. Validate SERVER_NAME
    lea CONF_SERVER_NAME_OFFSET(%r15), %rdi
    call str_len
    cmp $0, %rax
    je .invalid_server_name
    jmp .validation_complete

.invalid_server_name:
    lea server_name_err_msg(%rip), %rdi
    mov $server_name_err_len, %rsi
    xor %rdx, %rdx
    call log_err
    lea CONF_SERVER_NAME_OFFSET(%r15), %rdi
    lea .default_server_name(%rip), %rsi
    xor %rdx, %rdx
    mov $CONF_SERVER_NAME_SIZE, %rcx
    call str_concat

.validation_complete:
    mov $1, %rax     # Return success

    pop %r13
    pop %r12
    pop %rbp
    ret
