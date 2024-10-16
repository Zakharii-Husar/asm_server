.section .data

.include "./asm_server/constants.s"

.section .text

    # Include function files
    .include "./asm_server/mods/sock_create.s"
    .include "./asm_server/mods/sock_bind.s"
    .include "./asm_server/mods/sock_listen.s"
    .include "./asm_server/mods/sock_accept.s"
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

    lea sock_created_msg(%rip), %rsi           # pointer to the message (from constants.s)
    movq $sock_created_msg_length, %rdx        # length of the message (from constants.s)
    call print_info

    # ----------------------------
    # 2. Bind Socket
    # ----------------------------
    call sock_bind

    lea sock_bound_msg(%rip), %rsi           # pointer to the message (from constants.s)
    movq $sock_bound_msg_length, %rdx        # length of the message (from constants.s)
    call print_info

    # ----------------------------
    # 3. Listen for requests
    # ----------------------------
    call sock_listen

    lea sock_listen_msg(%rip), %rsi           # pointer to the message (from constants.s)
    movq $sock_listen_msg_length, %rdx        # length of the message (from constants.s)
    call print_info

    # Main server loop
main_loop:
    # ----------------------------
    # 4. Accept connection (blocking call)
    # ----------------------------
    call sock_accept

    # --------------------------------
    # 5. Send "Hello, World" response
    # --------------------------------
    call sock_respond

    # --------------------------------
    # 6. Close the connection
    # --------------------------------
    call sock_close_conn

    # Jump back to the start of the loop to accept new connections
    jmp main_loop

    # possible to make server shut down on certain condition:
    call exit_program
