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

    lea server_config_struct(%rip), %r15

    # Initialize all the server config struct fields to -1
    # This is to make it easier to check during validation
    movl $-1, CONF_HOST_OFFSET(%r15)          # Host IP
    movw $-1, CONF_PORT_OFFSET(%r15)          # Port
    movq $-1, CONF_BUFFER_SIZE_OFFSET(%r15)   # Buffer size
    movq $-1, CONF_TIMEZONE_OFFSET(%r15)      # Timezone
    movq $-1, CONF_MAX_CONN_OFFSET(%r15)      # Max connections


    lea server_conf_file_B(%rip), %rdi
    mov $server_conf_file_B_size, %rsi
    call clear_buffer

    # LOAD SERVER CONFIG FILE
    lea server_conf_path(%rip), %rdi
    lea server_conf_file_B(%rip), %rsi
    mov $server_conf_file_B_size, %rdx
    mov $1, %rcx
    call file_open
    
    # Check return value
    test %rax, %rax
    jns .parse_config_file

    # Skip parsing config file if failed to open config file
    call open_log_files
    jmp .exit_init_config

    # PARSE SERVER CONFIG FILE
    .parse_config_file:
    lea server_conf_file_B(%rip), %rdi
    call parse_srvr_config
    call open_log_files
    
    

.exit_init_config:
    # Check if config is valid and all fields are set, otherwise fallback to default config
    call validate_config
    pop %rbp
    ret
