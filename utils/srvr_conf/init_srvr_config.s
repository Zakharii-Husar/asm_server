.section .bss
# Server config struct
.align 8
server_config_struct:
    .lcomm conf_host, CONF_HOST_SIZE
    .lcomm conf_port, CONF_PORT_SIZE
    .lcomm conf_public_path, CONF_PUBLIC_DIR_SIZE
    .lcomm conf_log_path, CONF_ERROR_LOG_PATH_SIZE
    .lcomm conf_max_conn, CONF_MAX_CONN_SIZE
    .lcomm conf_buffer_size, CONF_BUFFER_SIZE_SIZE
    .lcomm conf_timezone, CONF_TIMEZONE_SIZE
    .lcomm conf_server_name, CONF_SERVER_NAME_SIZE
    .lcomm conf_default_file, CONF_DEFAULT_FILE_SIZE
    .lcomm conf_access_log_path, CONF_ACCESS_LOG_PATH_SIZE
    .lcomm conf_error_log_fd, 8
server_config_struct_end:

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

    # Call file_open with path and buffer
    lea server_conf_path(%rip), %rdi
    lea server_conf_file_B(%rip), %rsi
    mov $1, %rdx
    call file_open

    # Check return value
    test %rax, %rax
    js .config_error

    # Load struct base address into r15
    lea server_config_struct(%rip), %r15
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
