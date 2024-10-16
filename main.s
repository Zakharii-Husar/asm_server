# main.s

.section .data

.include "./asm_server/constants.s"

.section .text

    # Include function files
    .include "./asm_server/mods/sock_create.s"
    .include "./asm_server/mods/sock_bind.s"
    .include "./asm_server/mods/sock_listen.s"
    .include "./asm_server/mods/sock_accept.s"
    .include "./asm_server/mods/sock_respond.s"

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
    # 3. Listen for requests
    # ----------------------------
    call sock_listen

    lea sock_listen_msg(%rip), %rsi           # pointer to the message (from constants.s)
    movq $sock_listen_msg_length, %rdx        # length of the message (from constants.s)

    call print_info

    # 4. Accept connection
    # ----------------------------

    call sock_accept


    # --------------------------------
    # 5. Send "Hello, World" response
    # --------------------------------

    call sock_respond

    # --------------------------------
    # 6. Close the connection
    # --------------------------------
    movq    %rdi, %rdi           # socket file descriptor
    movq    $3, %rax             # sys_close (system call number for closing a file descriptor: 3)
    syscall                      # close the connection

     # Exit the program
    mov $SYS_exit, %rax
    xor %rdi, %rdi       # return code 0
    syscall

