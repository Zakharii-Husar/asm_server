.section .data



.section .text

movq    $SYS_sock_listen, %rax
movq    %rbx, %rdi                 # socket file descriptor (saved in rbx while creating socket)
movq    $connection_backlog, %rsi
syscall
