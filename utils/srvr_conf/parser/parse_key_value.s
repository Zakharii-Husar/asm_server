.section .data
timezone_key: .asciz "timezone"
port_key: .asciz "port"
host_key: .asciz "host"
localhost_str: .asciz "localhost"
localhost_ip: .asciz "0.0.0.0"
public_dir_key: .asciz "public_dir"
error_log_path_key: .asciz "error_log_path"
max_conn_key: .asciz "max_conn"
buffer_size_key: .asciz "buffer_size"
server_name_key: .asciz "server_name"
default_file_key: .asciz "default_file"
access_log_path_key: .asciz "access_log_path"

equal_sign: .asciz "="
n_line: .asciz "\n"

.section .bss
.lcomm config_key, 20
.lcomm config_value, 20
# str_find_char
# Parameters:
#   %rdi - Address of the beginning of the line
#   %rsi - Address of the '=' character
.section .text

.type parse_key_value, @function
parse_key_value:
    push %rbp
    mov %rsp, %rbp
    push %r12
    push %r13
    push %r14
    mov %rdi, %r12 # store address of beginning of line
    mov %rsi, %r13 # store address of '='

    # Clear config_key and config_value buffers
    lea config_key(%rip), %rdi
    mov $20, %rsi
    call clear_buffer

    lea config_value(%rip), %rdi
    mov $20, %rsi
    call clear_buffer


    # Calculate key length
    mov %r13, %rax    # Move '=' address to %rax
    sub %r12, %rax    # Subtract start address from '=' address
    mov %rax, %r14    # Store key length in r14

    # Copy key to config_key
    lea config_key(%rip), %rdi
    mov %r12, %rsi
    mov %r14, %rdx
    call str_concat

    # Convert key to lowercase
    lea config_key(%rip), %rdi
    call str_to_lower

    # Extract value first (common for all keys)
    mov %r13, %rdi           # Address of '=' character
    inc %rdi                 # Move past the '=' character
    mov $' ', %rsi          # Looking for space character
    mov $'\n', %rdx         # Or newline character
    call str_find_char      # Returns address of delimiter in %rax

    # Calculate value length and copy (common for all keys)
    mov %rax, %rdx          # Store delimiter address
    sub %r13, %rdx          # Calculate length (delimiter addr - '=' addr)
    dec %rdx                # Adjust for the '=' character

    # Copy value to config_value
    lea config_value(%rip), %rdi
    lea 1(%r13), %rsi
    call str_concat
    

    # Compare keys and handle accordingly
    lea config_key(%rip), %rdi
    lea timezone_key(%rip), %rsi
    call str_cmp
    cmp $1, %rax
    je .handle_timezone_key

    lea config_key(%rip), %rdi
    lea port_key(%rip), %rsi
    call str_cmp
    cmp $1, %rax
    je .handle_port_key

    lea config_key(%rip), %rdi
    lea host_key(%rip), %rsi
    call str_cmp
    cmp $1, %rax
    je .handle_host_key

    lea config_key(%rip), %rdi
    lea public_dir_key(%rip), %rsi
    call str_cmp
    cmp $1, %rax
    je .handle_public_dir_key

    lea config_key(%rip), %rdi
    lea error_log_path_key(%rip), %rsi
    call str_cmp
    cmp $1, %rax
    je .handle_error_log_path_key

    lea config_key(%rip), %rdi
    lea max_conn_key(%rip), %rsi
    call str_cmp
    cmp $1, %rax
    je .handle_max_conn_key

    lea config_key(%rip), %rdi
    lea buffer_size_key(%rip), %rsi
    call str_cmp
    cmp $1, %rax
    je .handle_buffer_size_key

    lea config_key(%rip), %rdi
    lea server_name_key(%rip), %rsi
    call str_cmp
    cmp $1, %rax
    je .handle_server_name_key

    lea config_key(%rip), %rdi
    lea default_file_key(%rip), %rsi
    call str_cmp
    cmp $1, %rax
    je .handle_default_file_key

    lea config_key(%rip), %rdi
    lea access_log_path_key(%rip), %rsi
    call str_cmp
    cmp $1, %rax
    je .handle_access_log_path_key

    jmp .exit_parse_key_value

.handle_timezone_key:
    lea config_value(%rip), %rdi
    call str_to_int
    mov %rax, CONF_TIMEZONE_OFFSET(%r15)
    jmp .exit_parse_key_value

.handle_port_key:
    lea config_value(%rip), %rdi
    call str_to_int
    mov %rax, %rdi
    call htons
    movw %ax, CONF_PORT_OFFSET(%r15)
    jmp .exit_parse_key_value

.handle_host_key:
    lea config_value(%rip), %rdi
    lea localhost_str(%rip), %rsi
    call str_cmp
    cmp $1, %rax
    je .handle_localhost

    lea config_value(%rip), %rdi
    call ip_to_network
    jmp .store_host_ip

  .handle_localhost:
      lea localhost_ip(%rip), %rdi
      call ip_to_network

  .store_host_ip:
      mov %eax, CONF_HOST_OFFSET(%r15)
      jmp .exit_parse_key_value

.handle_public_dir_key:
    lea CONF_PUBLIC_PATH_OFFSET(%r15), %rdi    # destination buffer
    lea config_value(%rip), %rsi               # source string
    mov $CONF_PUBLIC_PATH_SIZE, %rdx           # length
    call str_concat
    jmp .exit_parse_key_value

.handle_error_log_path_key:
    lea CONF_LOG_PATH_OFFSET(%r15), %rdi       # destination buffer
    lea config_value(%rip), %rsi               # source string
    mov $CONF_LOG_PATH_SIZE, %rdx              # length
    call str_concat
    jmp .exit_parse_key_value

.handle_max_conn_key:
    lea config_value(%rip), %rdi
    call str_to_int
    mov %rax, CONF_MAX_CONN_OFFSET(%r15)
    jmp .exit_parse_key_value

.handle_buffer_size_key:
    lea config_value(%rip), %rdi
    call str_to_int
    mov %rax, CONF_BUFFER_SIZE_OFFSET(%r15)
    jmp .exit_parse_key_value

.handle_server_name_key:
    lea CONF_SERVER_NAME_OFFSET(%r15), %rdi    # destination buffer
    lea config_value(%rip), %rsi               # source string
    mov $CONF_SERVER_NAME_SIZE, %rdx           # length
    call str_concat
    jmp .exit_parse_key_value

.handle_default_file_key:
    lea CONF_DEFAULT_FILE_OFFSET(%r15), %rdi   # destination buffer
    lea config_value(%rip), %rsi               # source string
    mov $CONF_DEFAULT_FILE_SIZE, %rdx          # length
    call str_concat
    jmp .exit_parse_key_value

.handle_access_log_path_key:

    lea CONF_ACCESS_LOG_PATH_OFFSET(%r15), %rdi # destination buffer
    lea config_value(%rip), %rsi                # source string
    mov $CONF_ACCESS_LOG_PATH_SIZE, %rdx        # length
    call str_concat
    jmp .exit_parse_key_value

.exit_parse_key_value:
    pop %r14
    pop %r13
    pop %r12
    pop %rbp
    ret
