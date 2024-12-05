.section .bss
# Server config struct
.align 8
server_config_struct:
    .lcomm conf_host, 256        # String buffer for hostname
    .lcomm conf_port, 8          # 64-bit integer for port
    .lcomm conf_public_path, 256 # String buffer for public path
    .lcomm conf_log_path, 256    # String buffer for log path
    .lcomm conf_max_conn, 8      # 64-bit integer for max connections
    .lcomm conf_buffer_size, 8   # 64-bit integer for buffer size
    .lcomm conf_timezone, 8      # 64-bit integer for timezone
server_config_struct_end:        # Label to calculate struct size

.lcomm server_conf_file_B, 4096  # Buffer for server config file

.section .data
server_conf_path: .asciz "./conf/server.conf"
config_load_err_msg: .asciz "\033[31mFailed to load server config! ❌\033[0m\n"
config_load_success_msg: .asciz "\033[32mServer config loaded successfully! ✅\033[0m\n"

.section .text
.type init_srvr_config, @function
init_srvr_config:
    push %rbp
    mov %rsp, %rbp

    # Load struct base address into r15
    lea server_config_struct(%rip), %r15

    # Call file_open with path and buffer
    lea server_conf_path(%rip), %rdi
    lea server_conf_file_B(%rip), %rsi
    call file_open

    # Check return value
    cmp $0, %rax
    jl .config_error

    # Call parse_srvr_config with buffer pointer
    lea server_conf_file_B(%rip), %rdi
    call parse_srvr_config

    # Success case
    lea config_load_success_msg(%rip), %rdi
    mov $0, %rsi                        # Let print_info calculate length
    call print_info
    jmp .exit_init_config

.config_error:
    lea config_load_err_msg(%rip), %rdi
    mov $0, %rsi                        # Let print_info calculate length
    call print_info

.exit_init_config:
    pop %rbp
    ret
