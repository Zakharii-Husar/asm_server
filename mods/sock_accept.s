.section .rodata

sock_accepted_msg:    .asciz "Connection was accepted\n"
sock_accepted_msg_length = . - sock_accepted_msg

sock_accept_err_msg:    .asciz "Faied to accept connection!\n"
sock_accept_err_msg_length = . - sock_accept_err_msg

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

 cmpq $0, %rax                   # Compare the return value with 0
 jl  handle_sock_accept_err                 # Jump to error handling if %rax < 0
    
 lea sock_accepted_msg(%rip), %rsi           # pointer to the message (from constants.s)
 movq $sock_accepted_msg_length, %rdx        # length of the message (from constants.s)
 call print_info

 movq    %rax, %rdi                   # save the new connection file descriptor in rdi

 popq %rbp                     # restore the caller's base pointer
 ret                           # return to the caller
 
handle_sock_accept_err:
 lea sock_accept_err_msg(%rip), %rsi           # pointer to the message (from constants.s)
 movq $sock_accept_err_msg_length, %rdx        # length of the message (from constants.s)
 call print_info
 call exit_program
