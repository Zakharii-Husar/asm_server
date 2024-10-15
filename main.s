# main.s

.section .data

.include "./asm_server/constants.s"

.section .text

    # Include function files
    .include "./asm_server/mods/sock_create.s"
    .include "./asm_server/mods/sock_bind.s"
    .include "./asm_server/mods/sock_listen.s"
    .include "./asm_server/mods/sock_accept.s"

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
    # 3. Listen for requests
    # ----------------------------
    movq    $SYS_sock_listen, %rax
    movq    %rbx, %rdi                 # socket file descriptor (saved in rbx while creating socket)
    movq    $connection_backlog, %rsi
    syscall
    # 4. Accept connection
    # ----------------------------
    movq    $SYS_sock_accept, %rax
    movq    %rbx, %rdi                   # socket file descriptor (saved in rbx)
    xorq    %rsi, %rsi                   # addr (NULL, since we don’t care about the client address here)
    xorq    %rdx, %rdx                   # addrlen (NULL)
    syscall                              # make syscall

    movq    %rax, %rdi                   # save the new connection file descriptor in rdi

    # --------------------------------
    # 5. Send "Hello, World" response
    # --------------------------------
    movq    %rax, %rdi           # socket file descriptor from accept (in %rax) is moved to %rdi
    lea     response(%rip), %rsi # address of the response in %rsi
    movq    $response_len, %rdx  # length of the response in %rdx
    movq    $44, %rax            # sys_sendto (system call number for sending data: 44)
    xorq    %r10, %r10           # flags = 0
    syscall                      # send the data (response to browser)

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
