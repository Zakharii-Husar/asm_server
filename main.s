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

     cmpq $0, %rax                   # Compare the return value with 0
    jl  exit_program4_lbl                 # Jump to error handling if %rax < 0

    lea sock_accepted_msg(%rip), %rsi           # pointer to the message (from constants.s)
    movq $sock_accepted_msg_length, %rdx        # length of the message (from constants.s)
    call print_info

    # --------------------------------
    # 5. Send "Hello, World" response
    # --------------------------------
    call sock_respond

     cmpq $0, %rax                   # Compare the return value with 0
    jl  exit_program5_lbl                 # Jump to error handling if %rax < 0

    # --------------------------------
    # 6. Close the connection
    # --------------------------------
    call sock_close_conn

     cmpq $0, %rax                   # Compare the return value with 0
    jl  exit_program6_lbl                 # Jump to error handling if %rax < 0

    # Jump back to the start of the loop to accept new connections
    jmp main_loop

    exit_program_lbl:
    call exit_program

    exit_program2_lbl:
    lea sock_err2_msg(%rip), %rsi           # pointer to the message (from constants.s)
    movq $sock_err2_msg_length, %rdx        # length of the message (from constants.s)
    call print_info
    call exit_program

    exit_program3_lbl:
    lea sock_err3_msg(%rip), %rsi           # pointer to the message (from constants.s)
    movq $sock_err3_msg_length, %rdx        # length of the message (from constants.s)
    call print_info
    call exit_program

    exit_program4_lbl:
    lea sock_err4_msg(%rip), %rsi           # pointer to the message (from constants.s)
    movq $sock_err4_msg_length, %rdx        # length of the message (from constants.s)
    call print_info
    call exit_program

    exit_program5_lbl:
    lea sock_err5_msg(%rip), %rsi           # pointer to the message (from constants.s)
    movq $sock_err5_msg_length, %rdx        # length of the message (from constants.s)
    call print_info
    call exit_program

    exit_program6_lbl:
    lea sock_err6_msg(%rip), %rsi           # pointer to the message (from constants.s)
    movq $sock_err6_msg_length, %rdx        # length of the message (from constants.s)
    call print_info
    call exit_program
