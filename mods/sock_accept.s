
.section .text

.type sock_accept, @function
sock_accept:
 pushq %rbp                    # save the caller's base pointer
 movq %rsp, %rbp               # set the new base pointer (stack frame)

movq    $SYS_sock_accept, %rax
movq    %rbx, %rdi                   # socket file descriptor (saved in rbx)
xorq    %rsi, %rsi                   # addr (NULL, since we don’t care about the client address here)
xorq    %rdx, %rdx                   # addrlen (NULL)
syscall                              # make syscall

movq    %rax, %rdi                   # save the new connection file descriptor in rdi

 popq %rbp                     # restore the caller's base pointer
 ret                           # return to the caller
 