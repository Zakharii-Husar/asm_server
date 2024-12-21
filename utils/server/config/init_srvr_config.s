.section .data
server_conf_path: .asciz "./conf/server.conf"
config_load_err_msg: .asciz "\033[31mFailed to load server config! ❌\033[0m\n"
config_load_success_msg: .asciz "\033[32mServer config loaded successfully! ✅\033[0m\n"

server_conf_file_B_size = 4096

.section .bss
.align 8
.lcomm server_config_struct, SERVER_CONFIG_STRUCT_SIZE    # Allocate single contiguous block

.lcomm server_conf_file_B, server_conf_file_B_size  # Buffer for server config file

.section .text
.type init_srvr_config, @function
init_srvr_config:
    push %rbp
    mov %rsp, %rbp

    lea server_conf_file_B(%rip), %rdi
    mov $server_conf_file_B_size, %rsi
    call clear_buffer

    # Call file_open with path and buffer
    lea server_conf_path(%rip), %rdi
    lea server_conf_file_B(%rip), %rsi
    mov $server_conf_file_B_size, %rdx
    mov $1, %rcx
    call file_open

    # Check return value
    test %rax, %rax
    js .config_error

    # Parse config file and load struct
    lea server_config_struct(%rip), %r15
    lea server_conf_file_B(%rip), %rdi
    call parse_srvr_config

    # Validate config

    # Open log files and store FDs in the struct
    call open_log_files

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
    call validate_config
    pop %rbp
    ret
