# main.s

# GLOBAL REGISTERS:
#   - %r12: socket file descriptor
#   - %r13: connection file descriptor
#   - %r14: pointer to client ip (buffer holding string)
#   - %r15: server config pointer

.section .data

test_str:
    .asciz "/indexhtml- ./index.css ./index.js"


.include "./constants.s"

.section .bss

.lcomm buffer, 1024

.section .text
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

.include "./utils/print_info.s"
.include "./utils/int_to_str.s"
.include "./utils/extract_client_ip.s"
.include "./utils/file_open.s"
.include "./utils/extract_route.s"
.include "./utils/build_file_path.s"
.include "./utils/extract_method.s"
.include "./utils/extract_extension.s"
.include "./utils/str_len.s"
.include "./utils/str_cmp.s"
.include "./utils/str_concat.s"
.include "./utils/str_find_char.s"
.include "./utils/str_to_lower.s"
.include "./utils/str_to_int.s"
.include "./utils/clear_buffer.s"
.include "./utils/create_type_header.s"
.include "./utils/create_status_header.s"
.include "./utils/create_length_header.s"
.include "./utils/time/get_time_now.s"

.include "./utils/time/get_timestamp.s"
.include "./utils/time/is_leap_year.s"
.include "./utils/time/get_days_in_month.s"
.include "./utils/time/format_time.s"
.include "./utils/time/adjust_timezone.s"

.include "./utils/srvr_conf/init_srvr_config.s"
.include "./utils/srvr_conf/parse_srvr_config.s"

.global _start
_start:


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
