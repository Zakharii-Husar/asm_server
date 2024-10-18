.section .data

.include "./asm_server/constants.s"

.section .text

    # Include function files
    .include "./asm_server/mods/sock_create.s"
    .include "./asm_server/mods/sock_bind.s"
    .include "./asm_server/mods/sock_listen.s"
    .include "./asm_server/mods/sock_accept.s"
    .include "./asm_server/mods/sock_fork.s"
    .include "./asm_server/mods/sock_respond.s"
    .include "./asm_server/mods/sock_close_conn.s"
    .include "./asm_server/mods/exit_program.s"

    .include "./asm_server/utils/print_info.s"

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

    # Main server loop
main_loop:
    # ----------------------------
    # 4. Accept connection (blocking call)
    # ----------------------------
    call sock_accept
    # --------------------------------
    # 5. Fork the process for handling child request
    # --------------------------------
    call sock_fork
    # --------------------------------
    # 6. Handle user's request (all in child process)
    # --------------------------------
child_process:
    call sock_respond            # Send response
    call sock_close_conn         # Close the connection for the child
    jmp exit_program_lbl         # Exit the child process (reuse exit logic)
    # --------------------------------
    # 7. Close the connection and repeate cycle (parent process)
    # --------------------------------
parent_process:
call sock_close_conn         # Close the connection for the parent
jmp main_loop                # Go back to accept new connections

    exit_program_lbl:
    call exit_program
