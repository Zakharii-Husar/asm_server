.section .rodata

sock_fork_msg:    .asciz "Socket was forked\n"
sock_fork_msg_length = . - sock_fork_msg

sock_fork_err_msg:    .asciz "Faied to fork!\n"
sock_fork_err_msg_length = . - sock_fork_err_msg

.section .text

.type sock_fork, @function
sock_fork:
 pushq %rbp                    # save the caller's base pointer
 movq %rsp, %rbp               # set the new base pointer (stack frame)

# Parent process:
movq $SYS_fork, %rax        # Fork the process
syscall

cmpq $0, %rax               # Check if we are in parent or child
jg parent_process
jl handle_sock_fork_err

# child_process: 
call sock_respond            # Send response
movq $1, %rdi                # passing 1 to indicate child process on sock_close
call sock_close_conn         # Close the connection for the child
call exit_program            # Exit the child process
     
parent_process:
movq $0, %rdi                # passing 0 to indicate parent process on sock_close
call sock_close_conn         # Close the connection for the parent
jmp main_loop                # Go back to accept new connections

popq %rbp                     # restore the caller's base pointer
ret                           # return to the caller
 
handle_sock_fork_err:
 lea sock_fork_err_msg(%rip), %rsi           # pointer to the message (from constants.s)
 movq $sock_fork_err_msg_length, %rdx        # length of the message (from constants.s)
 call print_info
 call exit_program
 