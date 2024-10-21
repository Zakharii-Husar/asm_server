.section .rodata

sock_bind_err_msg:    .asciz "Faied to bind TCP socket!\n"
sock_bind_err_msg_length = . - sock_bind_err_msg

sock_bound_msg:    .asciz "Socket was bound\n"
sock_bound_msg_length = . - sock_bound_msg

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

 cmpq $0, %rax                           # Compare the return value with 0
 jl  handle_sock_bind_err                # Jump to error handling if %rax < 0
    
 lea sock_bound_msg(%rip), %rsi          # pointer to the message (from constants.s)
 movq $sock_bound_msg_length, %rdx       # length of the message (from constants.s)
 call print_info

 popq %rbp                               # restore the caller's base pointer
 ret                                     # return to the caller

handle_sock_bind_err:
 lea sock_bind_err_msg(%rip), %rsi           # pointer to the message (from constants.s)
 movq $sock_bind_err_msg_length, %rdx        # length of the message (from constants.s)
 call print_info
 call exit_program
