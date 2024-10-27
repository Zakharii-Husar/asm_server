.section .rodata

sock_accepted_msg:    .asciz "\033[32mConnection was accepted 🔄\033[0m\n"
sock_accepted_msg_length = . - sock_accepted_msg

sock_accept_err_msg:    .asciz "\033[31mFailed to accept connection ❌\033[0m\n"
sock_accept_err_msg_length = . - sock_accept_err_msg

.section .text

.type sock_accept, @function
sock_accept:
 push %rbp                                    # save the caller's base pointer
 mov %rsp, %rbp                               # set the new base pointer (stack frame)
 
 mov %rbx, %rdi                               # move socket fd into %rdi (1st arg for bind)
 mov    $SYS_sock_accept, %rax
 xor    %rsi, %rsi                            # addr (NULL, since we don’t care about the client address here)
 xor    %rdx, %rdx                            # addrlen (NULL)
 syscall                                      # make syscall

 cmp $0, %rax                                 # Compare the return value with 0
 jl  handle_sock_accept_err                   # Jump to error handling if %rax < 0

mov    %rax, %r12                             # save the new connection file descriptor in r12
    
 lea sock_accepted_msg(%rip), %rsi            # pointer to the message (from constants.s)
 mov $sock_accepted_msg_length, %rdx          # length of the message (from constants.s)
 call print_info


 pop %rbp                                      # restore the caller's base pointer
 ret                                           # return to the caller
 
handle_sock_accept_err:
 lea sock_accept_err_msg(%rip), %rsi           # pointer to the message (from constants.s)
 mov $sock_accept_err_msg_length, %rdx         # length of the message (from constants.s)
 call print_info
 call exit_program
