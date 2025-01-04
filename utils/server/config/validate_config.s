.section .rodata
# Warning messages for each config key
host_warn_msg: .asciz "No valid host was provided. Using default 0.0.0.0 in validate_config.s"
host_warn_msg_len = . - host_warn_msg

port_warn_msg: .asciz "Invalid port (must be between 1-65535). Using default 8080 in validate_config.s"
port_warn_msg_len = . - port_warn_msg

buffer_warn_msg: .asciz "Invalid buffer size (must be between 1KB-64MB). Using default 16MB in validate_config.s"
buffer_warn_msg_len = . - buffer_warn_msg

conf_timezone_warn_msg: .asciz "Invalid timezone offset (must be between -1200 and +1400). Using default 0 in validate_config.s"
conf_timezone_warn_msg_len = . - conf_timezone_warn_msg

max_conn_warn_msg: .asciz "Invalid max connections (must be between 1-1000). Using default 100 in validate_config.s"
max_conn_warn_msg_len = . - max_conn_warn_msg

public_dir_warn_msg: .asciz "Invalid public directory path. Using default ./public in validate_config.s"
public_dir_warn_msg_len = . - public_dir_warn_msg

default_file_warn_msg: .asciz "Invalid default file. Using default index.html in validate_config.s"
default_file_warn_msg_len = . - default_file_warn_msg

server_name_warn_msg: .asciz "Invalid server name. Using default MyASMServer/1.0 in validate_config.s"
server_name_warn_msg_len = . - server_name_warn_msg

# Default values
.equ default_port, 8080
.default_host_str: .asciz "0.0.0.0"
.default_buffer: .quad 16777216  # 16MB
.default_timezone: .quad 0
.default_max_conn: .quad 100

.default_public_dir: .asciz "./public"
.default_file: .asciz "index.html"
.default_server_name: .asciz "MyASMServer/1.0"

.section .text
.type validate_config, @function
# Function: validate_config
# Parameters:
#   - None
# Global Registers:
#   - %r15: server configuration pointer
# Return Values:
#   - %rax: 0 on success, -1 on critical failure
# Error Handling:
#   - Logs warnings for invalid values and sets defaults
#   - Returns -1 for critical configuration errors
# Side Effects:
#   - Modifies server configuration structure
#   - Writes to log files for warnings
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
    lea host_warn_msg(%rip), %rdi
    mov $host_warn_msg_len, %rsi
    call log_warn
    # Convert default host to network format
    lea .default_host_str(%rip), %rdi
    call ip_to_network
    mov %eax, CONF_HOST_OFFSET(%r15)    # Store the network-formatted IP

.check_port:
    # 2. Validate PORT (comparing network byte order values)
    movzwl CONF_PORT_OFFSET(%r15), %eax  # Zero-extend 16-bit port to 32-bit
    
    # Compare with 1 in network byte order (0x0100)
    cmp $0x0100, %eax
    jl .invalid_port
    
    # Compare with 65535 in network byte order (0xFFFF)
    cmp $0xFFFF, %eax
    jg .invalid_port
    jmp .check_buffer_size

.invalid_port:
    lea port_warn_msg(%rip), %rdi
    mov $port_warn_msg_len, %rsi
    call log_warn
    # Convert default port to network format
    mov $default_port, %rdi
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
    lea buffer_warn_msg(%rip), %rdi
    mov $buffer_warn_msg_len, %rsi
    call log_warn
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
    lea conf_timezone_warn_msg(%rip), %rdi
    mov $conf_timezone_warn_msg_len, %rsi
    call log_warn
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
    lea max_conn_warn_msg(%rip), %rdi
    mov $max_conn_warn_msg_len, %rsi
    call log_warn
    mov .default_max_conn(%rip), %rax
    mov %rax, CONF_MAX_CONN_OFFSET(%r15)

.check_public_dir:
    # 6. Validate PUBLIC_DIR (check if empty)
    lea CONF_PUBLIC_DIR_OFFSET(%r15), %rdi
    cmpb $0, (%rdi)
    je .invalid_public_dir
    jmp .check_default_file

.invalid_public_dir:
    lea public_dir_warn_msg(%rip), %rdi
    mov $public_dir_warn_msg_len, %rsi
    call log_warn
    lea CONF_PUBLIC_DIR_OFFSET(%r15), %rdi
    lea .default_public_dir(%rip), %rsi
    xor %rdx, %rdx
    mov $CONF_PUBLIC_DIR_SIZE, %rcx
    call str_cat

.check_default_file:
    # 9. Validate DEFAULT_FILE
    lea CONF_DEFAULT_FILE_OFFSET(%r15), %rdi
    cmpb $0, (%rdi)
    je .invalid_default_file
    jmp .check_server_name

.invalid_default_file:
    lea default_file_warn_msg(%rip), %rdi
    mov $default_file_warn_msg_len, %rsi
    call log_warn
    lea CONF_DEFAULT_FILE_OFFSET(%r15), %rdi
    lea .default_file(%rip), %rsi
    xor %rdx, %rdx
    mov $CONF_DEFAULT_FILE_SIZE, %rcx
    call str_cat

.check_server_name:
    # 10. Validate SERVER_NAME
    lea CONF_SERVER_NAME_OFFSET(%r15), %rdi
    cmpb $0, (%rdi)
    je .invalid_server_name
    jmp .validation_complete

.invalid_server_name:
    lea server_name_warn_msg(%rip), %rdi
    mov $server_name_warn_msg_len, %rsi
    call log_warn
    lea CONF_SERVER_NAME_OFFSET(%r15), %rdi
    lea .default_server_name(%rip), %rsi
    xor %rdx, %rdx
    mov $CONF_SERVER_NAME_SIZE, %rcx
    call str_cat

.validation_complete:
    mov $1, %rax     # Return success

    pop %r13
    pop %r12
    leave                     # restore stack frame
    ret
