.section .rodata

timezone_key: .asciz "timezone"
port_key: .asciz "port"
host_key: .asciz "host"
localhost_str: .asciz "localhost"
localhost_ip: .asciz "0.0.0.0"
public_dir_key: .asciz "public_dir"
max_conn_key: .asciz "max_conn"
buffer_size_key: .asciz "buffer_size"
server_name_key: .asciz "server_name"
default_file_key: .asciz "default_file"
access_log_path_key: .asciz "access_log_path"
warning_log_path_key: .asciz "warning_log_path"
error_log_path_key: .asciz "error_log_path"
system_log_path_key: .asciz "system_log_path"

.section .text

# Function: write_config_struct
# Parameters:
#   - %rdi: pointer to config key string
#   - %rsi: pointer to config value string
# Global Registers:
#   - %r15: server configuration pointer
# Return Values:
#   - None
# Error Handling:
#   - Skips invalid key-value pairs
#   - Validates values before writing
# Side Effects:
#   - Modifies server configuration structure fields
.type write_config_struct, @function
write_config_struct:
    push %rbp
    mov %rsp, %rbp
    push %r12
    push %r13
    sub $8, %rsp               # align stack to 16-byte boundary
    # %rdi contains pointer to config_key
    # %rsi contains pointer to config_value
    # Check if key pointer (%rdi) is null


    test %rdi, %rdi
    jz .exit_parse_key_value
    
    # Check if value pointer (%rsi) is null
    test %rsi, %rsi
    jz .exit_parse_key_value


    
    # Store parameters only if both are non-null
    mov %rdi, %r12  # store key pointer
    mov %rsi, %r13  # store value pointer

    # Convert key to lowercase (key is already in the buffer)
    mov %r12, %rdi
    call str_to_lower

    # Now compare keys and handle accordingly
    mov %r12, %rdi
    lea timezone_key(%rip), %rsi
    call str_cmp
    cmp $1, %rax
    je .handle_timezone_key

    mov %r12, %rdi
    lea port_key(%rip), %rsi
    call str_cmp
    cmp $1, %rax
    je .handle_port_key

    mov %r12, %rdi
    lea host_key(%rip), %rsi
    call str_cmp
    cmp $1, %rax
    je .handle_host_key

    mov %r12, %rdi
    lea public_dir_key(%rip), %rsi
    call str_cmp
    cmp $1, %rax
    je .handle_public_dir_key

    mov %r12, %rdi
    lea error_log_path_key(%rip), %rsi
    call str_cmp
    cmp $1, %rax
    je .handle_error_log_path_key

    mov %r12, %rdi
    lea max_conn_key(%rip), %rsi
    call str_cmp
    cmp $1, %rax
    je .handle_max_conn_key

    mov %r12, %rdi
    lea buffer_size_key(%rip), %rsi
    call str_cmp
    cmp $1, %rax
    je .handle_buffer_size_key

    mov %r12, %rdi
    lea server_name_key(%rip), %rsi
    call str_cmp
    cmp $1, %rax
    je .handle_server_name_key

    mov %r12, %rdi
    lea default_file_key(%rip), %rsi
    call str_cmp
    cmp $1, %rax
    je .handle_default_file_key

    mov %r12, %rdi
    lea access_log_path_key(%rip), %rsi
    call str_cmp
    cmp $1, %rax
    je .handle_access_log_path_key

    mov %r12, %rdi
    lea warning_log_path_key(%rip), %rsi
    call str_cmp
    cmp $1, %rax
    je .handle_warning_log_path_key

    mov %r12, %rdi
    lea system_log_path_key(%rip), %rsi
    call str_cmp
    cmp $1, %rax
    je .handle_system_log_path

    jmp .exit_parse_key_value

.handle_timezone_key:
    mov %r13, %rdi           # Pass config_value pointer
    call str_to_int
    mov %rax, CONF_TIMEZONE_OFFSET(%r15)

    jmp .exit_parse_key_value

.handle_port_key:
    mov %r13, %rdi           # Pass config_value pointer
    call str_to_int
    mov %rax, %rdi
    call htons
    movw %ax, CONF_PORT_OFFSET(%r15)
    jmp .exit_parse_key_value

.handle_host_key:
    mov %r13, %rdi           # Pass config_value pointer
    lea localhost_str(%rip), %rsi
    call str_cmp
    cmp $1, %rax
    je .handle_localhost

    mov %r13, %rdi           # Pass config_value pointer
    call ip_to_network
    jmp .store_host_ip

  .handle_localhost:
      lea localhost_ip(%rip), %rdi
      call ip_to_network

  .store_host_ip:
      mov %eax, CONF_HOST_OFFSET(%r15)
      jmp .exit_parse_key_value

.handle_public_dir_key:
    lea CONF_PUBLIC_DIR_OFFSET(%r15), %rdi    # destination buffer
    mov %r13, %rsi               # source string
    xor %rdx, %rdx
    mov $CONF_PUBLIC_DIR_SIZE, %rcx
    call str_cat

    jmp .exit_parse_key_value

.handle_error_log_path_key:
    lea CONF_ERROR_LOG_PATH_OFFSET(%r15), %rdi       # destination buffer
    mov %r13, %rsi               # source string
    xor %rdx, %rdx
    mov $CONF_ERROR_LOG_PATH_SIZE, %rcx
    call str_cat
    jmp .exit_parse_key_value

.handle_max_conn_key:
    mov %r13, %rdi
    call str_to_int
    mov %rax, CONF_MAX_CONN_OFFSET(%r15)
    jmp .exit_parse_key_value

.handle_buffer_size_key:
    mov %r13, %rdi
    call str_to_int
    mov %rax, CONF_BUFFER_SIZE_OFFSET(%r15)
    jmp .exit_parse_key_value

.handle_server_name_key:
    lea CONF_SERVER_NAME_OFFSET(%r15), %rdi    # destination buffer
    mov %r13, %rsi               # source string
    xor %rdx, %rdx
    mov $CONF_SERVER_NAME_SIZE, %rcx
    call str_cat
    
    jmp .exit_parse_key_value

.handle_default_file_key:
    lea CONF_DEFAULT_FILE_OFFSET(%r15), %rdi   # destination buffer
    mov %r13, %rsi               # source string
    xor %rdx, %rdx
    mov $CONF_DEFAULT_FILE_SIZE, %rcx
    call str_cat
    jmp .exit_parse_key_value

.handle_access_log_path_key:

    lea CONF_ACCESS_LOG_PATH_OFFSET(%r15), %rdi # destination buffer
    mov %r13, %rsi                # source string
    xor %rdx, %rdx
    mov $CONF_ACCESS_LOG_PATH_SIZE, %rcx
    call str_cat
    jmp .exit_parse_key_value

.handle_warning_log_path_key:
    lea CONF_WARNING_LOG_PATH_OFFSET(%r15), %rdi  # destination buffer
    mov %r13, %rsi                # source string
    xor %rdx, %rdx
    mov $CONF_WARNING_LOG_PATH_SIZE, %rcx
    call str_cat
    jmp .exit_parse_key_value

.handle_system_log_path:
    lea CONF_SYSTEM_LOG_PATH_OFFSET(%r15), %rdi  # destination buffer
    mov %r13, %rsi                # source string
    xor %rdx, %rdx
    mov $CONF_SYSTEM_LOG_PATH_SIZE, %rcx
    call str_cat
    jmp .exit_parse_key_value

.exit_parse_key_value:

    pop %r13
    pop %r12
    leave                     # restore stack frame
    ret
