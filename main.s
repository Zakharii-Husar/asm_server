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
    .include "./asm_server/utils/int_to_string.s"

    .global _start

_start:

    call int_to_string         # Call the conversion routine

    call exit_program
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
    call sock_fork

    exit_program_lbl:
    call exit_program
