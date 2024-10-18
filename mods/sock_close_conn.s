.section .rodata

sock_close_conn_err_msg:    .asciz "Faied to close connection!\n"
sock_close_conn_err_msg_length = . - sock_close_conn_err_msg

sock_close_conn_msg:    .asciz "Connection was closed\n"
sock_close_conn_msg_length = . - sock_close_conn_msg

.section .text

.type sock_close_conn, @function
sock_close_conn:

pushq %rbp                    # save the caller's base pointer
movq %rsp, %rbp               # set the new base pointer (stack frame)

movq    %rdi, %rdi           # socket file descriptor
movq    $SYS_close_fd, %rax             # sys_close (system call number for closing a file descriptor: 3)
syscall                      # close the connection

 cmpq $0, %rax                   # Compare the return value with 0
 jl  handle_sock_close_conn_err                 # Jump to error handling if %rax < 0
    
 lea sock_close_conn_msg(%rip), %rsi           # pointer to the message (from constants.s)
 movq $sock_close_conn_msg_length, %rdx        # length of the message (from constants.s)
 call print_info

popq %rbp                     # restore the caller's base pointer
ret                           # return to the caller

handle_sock_close_conn_err:
 lea sock_close_conn_err_msg(%rip), %rsi           # pointer to the message (from constants.s)
 movq $sock_close_conn_err_msg_length, %rdx        # length of the message (from constants.s)
 call print_info
 call exit_program
