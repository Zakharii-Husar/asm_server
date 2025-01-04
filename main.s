# main.s

# GLOBAL REGISTERS:
#   - %r12: socket file descriptor
#   - %r13: connection file descriptor
#   - %r14: pointer to client ip (buffer holding string)
#   - %r15: server config pointer


.section .data
.include "./constants.s"

.section .text
# Modules
.include "./mods/sock_create.s"
.include "./mods/sock_bind.s"
.include "./mods/sock_listen.s"
.include "./mods/sock_accept.s"
.include "./mods/sock_read.s"
.include "./mods/sock_respond.s"
.include "./mods/sock_close_conn.s"
.include "./mods/process_fork.s"
.include "./mods/fork_handle_child.s"
.include "./mods/fork_handle_parent.s"
.include "./mods/exit_program.s"
.include "./mods/signal_handler.s"
.include "./mods/server_shutdown.s"

# Core utilities
.include "./utils/core/io/print_info.s"
.include "./utils/core/io/file_open.s"
.include "./utils/core/memory/clear_buffer.s"
.include "./utils/core/validation/validate_file_path.s"

# Core string operations
.include "./utils/core/str/str_len.s"
.include "./utils/core/str/str_cmp.s"
.include "./utils/core/str/str_cat.s"
.include "./utils/core/str/str_find_char.s"
.include "./utils/core/str/str_to_lower.s"
.include "./utils/core/str/str_to_int.s"
.include "./utils/core/str/int_to_str.s"
.include "./utils/core/str/char_cmp.s"
.include "./utils/core/str/str_contains.s"

# Server configuration
.include "./utils/server/config/init_srvr_config.s"
.include "./utils/server/config/parse_srvr_config.s"
.include "./utils/server/config/write_config_struct.s"
.include "./utils/server/config/network/htons.s"
.include "./utils/server/config/network/ip_to_network.s"
.include "./utils/server/config/logging/open_log_files.s"
.include "./utils/server/config/logging/log_access.s"
.include "./utils/server/config/logging/log_warn.s"
.include "./utils/server/config/logging/log_err.s"
.include "./utils/server/config/logging/log_sys.s"
.include "./utils/server/config/validate_config.s"
# HTTP functionality
.include "./utils/server/http/headers/create_type_header.s"
.include "./utils/server/http/headers/create_status_header.s"
.include "./utils/server/http/headers/create_length_header.s"
.include "./utils/server/http/headers/create_server_header.s"
.include "./utils/server/http/request/extract_client_ip.s"
.include "./utils/server/http/request/extract_route.s"
.include "./utils/server/http/request/extract_method.s"
.include "./utils/server/http/request/extract_extension.s"

# Time utilities
.include "./utils/time/get_time_now.s"
.include "./utils/time/get_timestamp.s"
.include "./utils/time/is_leap_year.s"
.include "./utils/time/get_days_in_month.s"
.include "./utils/time/format_time.s"
.include "./utils/time/adjust_timezone.s"

# Server utilities
.include "./utils/build_file_path.s"
.include "./utils/check_stack.s"

.global _start
_start:

    # 0. Call signal handler to listen for Ctrl+C
    call signal_handler
    # 0. Initialize server config
    call init_srvr_config

    # ----------------------------
    # 1. Create Socket
    # ----------------------------
    call sock_create
    # ----------------------------
    # 2. Bind Socket
    # ----------------------------
    call sock_bind
    # ----------------------------
    # 3. Listen for requests
    # ----------------------------
    call sock_listen
    

    # Main server loop (parent process will jump here after forking)
.main_loop:
    movq server_shutdown_flag(%rip), %rax
    test %rax, %rax
    jnz .initiate_shutdown
    # ----------------------------
    # 4. Accept connection (blocking call)
    # ----------------------------
    call sock_accept
    # --------------------------------
    # 5. Fork the process(child reads and responds to a user and parent
    # is going back to accepting new connections)
    # --------------------------------

    call process_fork          # handles forking and error handling

    cmp $0, %rax               # Check if we're in the child or parent
    jg .parent_process

    # for child process handle user request and close the program 
    .child_process:
    call fork_handle_child     # handles killing the child process

    # for  parent process close connection and repeate the cycle
    .parent_process:
    call fork_handle_parent

jmp .main_loop
    .initiate_shutdown:
        call server_shutdown
        