
.section .text

.type sock_listen, @function
sock_listen:
 pushq %rbp                    # save the caller's base pointer
 movq %rsp, %rbp               # set the new base pointer (stack frame)

 movq    $SYS_sock_listen, %rax
 movq    %rbx, %rdi                 # socket file descriptor (saved in rbx while creating socket)
 movq    $connection_backlog, %rsi
 syscall

 popq %rbp                     # restore the caller's base pointer
 ret                           # return to the caller
