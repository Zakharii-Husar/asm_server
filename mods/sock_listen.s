.section .data

    # sys_call args
    .equ SYS_sock_listen, 50

    # sock listen args
    .equ connection_backlog, 10   # backlog (max number of queued connections)

.section .text

movq    $SYS_sock_listen, %rax
movq    %rbx, %rdi                 # socket file descriptor (saved in rbx while creating socket)
movq    $connection_backlog, %rsi
syscall
