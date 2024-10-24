.section .rodata

sock_create_err_msg:    .asciz "Faied to create TCP socket!\n"
sock_create_err_msg_length = . - sock_create_err_msg

sock_created_msg:    .asciz "Socket was created\n"
sock_created_msg_length = . - sock_created_msg

.section .text
# Create socket (AF_INET, SOCK_STREAM, 0)
.type sock_create, @function
sock_create:
 push %rbp                    # save the caller's base pointer
 mov %rsp, %rbp               # set the new base pointer (stack frame)

 mov $SYS_sock_create, %rax
 mov $AF_INET, %rdi
 mov $SOCK_STREAM, %rsi
 mov $SOCK_PROTOCOL, %rdx
 syscall

 cmp $0, %rax                   # Compare the return value with 0
 jl  handle_sock_create_err                 # Jump to error handling if %rax < 0
    
 lea sock_created_msg(%rip), %rsi           # pointer to the message (from constants.s)
 mov $sock_created_msg_length, %rdx        # length of the message (from constants.s)
 call print_info

 pop %rbp                     # restore the caller's base pointer
 ret                           # return to the caller

handle_sock_create_err:
 lea sock_create_err_msg(%rip), %rsi           # pointer to the message (from constants.s)
 mov $sock_create_err_msg_length, %rdx        # length of the message (from constants.s)
 call print_info
 call exit_program

