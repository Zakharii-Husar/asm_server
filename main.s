# main.s

# GLOBAL REGISTERS:
#   - %r12: socket file descriptor
#   - %r13: connection file descriptor
#   - %r14: pointer to client info
#   - %r15: server config pointer

.section .data

.include "./asm_server/constants.s"

test_path: .asciz "./asm_server/public/favicon.icos"

.section .bss
.lcomm test_buffer, 16777216    # Create a 16MB buffer (16 * 1024 * 1024)

.section .text
.include "./asm_server/mods/sock_create.s"
.include "./asm_server/mods/sock_bind.s"
.include "./asm_server/mods/sock_listen.s"
.include "./asm_server/mods/sock_accept.s"
.include "./asm_server/mods/sock_read.s"
.include "./asm_server/mods/sock_respond.s"
.include "./asm_server/mods/sock_close_conn.s"

.include "./asm_server/mods/process_fork.s"
.include "./asm_server/mods/fork_handle_child.s"
.include "./asm_server/mods/fork_handle_parent.s"

.include "./asm_server/mods/exit_program.s"

.include "./asm_server/utils/print_info.s"
.include "./asm_server/utils/int_to_str.s"
.include "./asm_server/utils/file_open.s"
.include "./asm_server/utils/extract_route.s"
.include "./asm_server/utils/build_file_path.s"
.include "./asm_server/utils/extract_method.s"
.include "./asm_server/utils/extract_extension.s"
.include "./asm_server/utils/str_len.s"
.include "./asm_server/utils/str_cmp.s"
.include "./asm_server/utils/str_concat.s"
.include "./asm_server/utils/str_find_char.s"
.include "./asm_server/utils/str_to_lower.s"
.include "./asm_server/utils/clear_buffer.s"
.include "./asm_server/utils/create_type_header.s"
.include "./asm_server/utils/create_status_header.s"
.include "./asm_server/utils/create_length_header.s"


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

    call process_fork # handles forking and error handling

    cmp $0, %rax               # Check if we're in the child or parent
    jg .parent_process

    # for child process handle user request and close the program 
    .child_process:
    call fork_handle_child     # handles killing the child process

    # for  parent process close connection and repeate the cycle
    .parent_process:
    call fork_handle_parent

jmp .main_loop
