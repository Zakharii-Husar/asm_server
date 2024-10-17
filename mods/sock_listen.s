.section .rodata

.equ sock_listen_msg_length, 43
sock_listen_msg:    .asciz "Socket is listening on http://0.0.0.0:8080\n"

.equ sock_listen_err_msg_length, 41
sock_listen_err_msg:    .asciz "Unable to listen on http://0.0.0.0:8080!\n"

.section .text

.type sock_listen, @function
sock_listen:
 pushq %rbp                    # save the caller's base pointer
 movq %rsp, %rbp               # set the new base pointer (stack frame)

 movq    $SYS_sock_listen, %rax
 movq    %rbx, %rdi                 # socket file descriptor (saved in rbx while creating socket)
 movq    $connection_backlog, %rsi
 syscall

cmpq $0, %rax                   # Compare the return value with 0
 jl  handle_sock_listen_err                 # Jump to error handling if %rax < 0
    
 lea sock_listen_msg(%rip), %rsi           # pointer to the message (from constants.s)
 movq $sock_listen_msg_length, %rdx        # length of the message (from constants.s)
 call print_info

 popq %rbp                     # restore the caller's base pointer
 ret                           # return to the caller

handle_sock_listen_err:
 lea sock_listen_err_msg(%rip), %rsi           # pointer to the message (from constants.s)
 movq $sock_listen_err_msg_length, %rdx        # length of the message (from constants.s)
 call print_info
 call exit_program
 