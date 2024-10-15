
.section .text

.type sock_bind, @function
sock_bind:
 pushq %rbp                    # save the caller's base pointer
 movq %rsp, %rbp               # set the new base pointer (stack frame)

 movq    $SYS_sock_bind, %rax            # sys_bind
 movq    %rbx, %rdi                      # socket file descriptor (saved in rbx)
 lea     addr_in(%rip), %rsi             # pointer to the address structure
 movq    $16, %rdx                       # size of the sockaddr_in structure
 syscall                                 # make syscall

 popq %rbp                     # restore the caller's base pointer
 ret                           # return to the caller
