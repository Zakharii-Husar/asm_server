.section .rodata

sock_listen_msg:    .asciz "Socket is listening on http://0.0.0.0:8080\n"
sock_listen_msg_length = . - sock_listen_msg

sock_listen_err_msg:    .asciz "Unable to listen on http://0.0.0.0:8080!\n"
sock_listen_err_msg_length = . - sock_listen_err_msg

.section .text

.type sock_listen, @function
sock_listen:
 push %rbp                    # save the caller's base pointer
 mov %rsp, %rbp               # set the new base pointer (stack frame)

 push %rax                    # preserve socket file descriptor

 mov    %rax, %rdi                 # socket file descriptor (saved in rbx while creating socket)
 mov    $SYS_sock_listen, %rax
 mov    $connection_backlog, %rsi
 syscall

 cmp $0, %rax                   # Compare the return value with 0
 jl  handle_sock_listen_err                 # Jump to error handling if %rax < 0
    
 lea sock_listen_msg(%rip), %rsi           # pointer to the message (from constants.s)
 mov $sock_listen_msg_length, %rdx        # length of the message (from constants.s)
 call print_info

 pop %rax                     # ret socket file descriptor

 pop %rbp                     # restore the caller's base pointer
 ret                           # return to the caller

handle_sock_listen_err:
 lea sock_listen_err_msg(%rip), %rsi           # pointer to the message (from constants.s)
 mov $sock_listen_err_msg_length, %rdx        # length of the message (from constants.s)
 call print_info
 call exit_program
 