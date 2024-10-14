# main.s

.section .data

    
.section .text

    # Include function files
    .include "./asm_server/mods/sock_create.s"
    .include "./asm_server/mods/sock_bind.s"
    .include "./asm_server/mods/sock_listen.s"
    .include "./asm_server/mods/sock_accept.s"

    .include "./asm_server/utils/print_info.s"

    .include "./asm_server/constants.s"
    .global _start

_start:


    # ----------------------------
    # 1. Create Socket
    # ----------------------------
    call sock_create
    call print_info
    # ----------------------------
    # 2. Bind Socket
    # ----------------------------
    movq    $SYS_sock_bind, %rax            # sys_bind
    movq    %rbx, %rdi                      # socket file descriptor (saved in rbx)
    lea     addr_in(%rip), %rsi             # pointer to the address structure
    movq    $16, %rdx                       # size of the sockaddr_in structure
    syscall                                 # make syscall
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
