.section .data

.section .text

  movq    $SYS_sock_bind, %rax            # sys_bind
  movq    %rbx, %rdi                      # socket file descriptor (saved in rbx)
  lea     addr_in(%rip), %rsi             # pointer to the address structure
  movq    $16, %rdx                       # size of the sockaddr_in structure
  syscall                                 # make syscall
