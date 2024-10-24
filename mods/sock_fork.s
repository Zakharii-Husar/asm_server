.section .rodata

sock_fork_msg:    .asciz "Socket was forked\n"
sock_fork_msg_length = . - sock_fork_msg

sock_fork_err_msg:    .asciz "Failed to fork!\n"
sock_fork_err_msg_length = . - sock_fork_err_msg

.section .text

.type sock_fork, @function
sock_fork:
push %rbp                    # save the caller's base pointer
mov %rsp, %rbp               # set the new base pointer (stack frame)

mov $SYS_fork, %rax          # Fork the process
syscall

cmp $0, %rax                 # Check if forking was successful
jl handle_sock_fork_err

pop %rbp                     # restore the caller's base pointer
ret                          # return to the caller
 
handle_sock_fork_err:
 lea sock_fork_err_msg(%rip), %rsi           # pointer to the message (from constants.s)
 mov $sock_fork_err_msg_length, %rdx        # length of the message (from constants.s)
 call print_info
 call exit_program
 