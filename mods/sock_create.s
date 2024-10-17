
.section .text

# Create socket (AF_INET, SOCK_STREAM, 0)
.type sock_create, @function
sock_create:
 pushq %rbp                    # save the caller's base pointer
 movq %rsp, %rbp               # set the new base pointer (stack frame)

 mov $SYS_sock_create, %rax
 mov $AF_INET, %rdi
 mov $SOCK_STREAM, %rsi
 mov $SOCK_PROTOCOL, %rdx
 syscall

 cmpq $0, %rax                   # Compare the return value with 0
 jl  handle_sock_create_err                 # Jump to error handling if %rax < 0
    
 lea sock_created_msg(%rip), %rsi           # pointer to the message (from constants.s)
 movq $sock_created_msg_length, %rdx        # length of the message (from constants.s)
 call print_info

 mov %rax, %rbx                    # store socket fd in %rbx

 popq %rbp                     # restore the caller's base pointer
 ret                           # return to the caller

handle_sock_create_err:
 lea sock_create_err_msg(%rip), %rsi           # pointer to the message (from constants.s)
 movq $sock_create_err_msg_length, %rdx        # length of the message (from constants.s)
 call print_info
 call exit_program

