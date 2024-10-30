.section .data

.include "./asm_server/constants.s"

.section .text

    # Include function files
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
    .include "./asm_server/utils/int_to_string.s"
    .include "./asm_server/utils/file_open.s"

    .global _start

_start:

.type main, @function
main:

# FUNCTION ARGS

call file_open
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
main_loop:
    # ----------------------------
    # 4. Accept connection (blocking call)
    # ----------------------------
    call sock_accept
    # --------------------------------
    # 5. Fork the process(child reads and responds to a user and parent
    # is going back to accepting new connections)
    # --------------------------------

    call process_fork
    cmp $0, %rax               # Check if we're in the child or parent
    jg parent_process

    # for child process handle user request and close the program 
    child_process:
    call fork_handle_child

    # for  parent process close connection and repeate the cycle
    parent_process:
    call fork_handle_parent

jmp main_loop
