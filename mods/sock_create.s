.section .rodata

.sock_created_msg:       .asciz "\033[32mTCP Sock was created ✅\033[0m\n"
.sock_create_err_msg:    .asciz "\033[31mFailed to create TCP socket ❌\033[0m\n"

.section .text
# Function: sock_create
# Parameters:
#   - None (uses predefined constants for socket creation)
# Return Values:
#   - Returns a socket file descriptor (fd) on success (fd >= 0)
#   - Calls exit_program on failure (fd < 0)

.type sock_create, @function

sock_create:
 push %rbp                    # save the caller's base pointer
 mov %rsp, %rbp               # set the new base pointer (stack frame)
 

 mov $SYS_sock_create, %rax
 mov $AF_INET, %rdi
 mov $SOCK_STREAM, %rsi
 mov $SOCK_PROTOCOL, %rdx
 syscall

 cmp $0, %rax                                # Compare the return value with 0
 jl  .handle_sock_create_err                 # Jump to error handling if %rax < 0
 mov %rax, %r12                              # save socket fd to %r12

 lea .sock_created_msg(%rip), %rsi
 call print_info

 pop %rbp                              # restore the caller's base pointer
 ret                                   # return to the caller

.handle_sock_create_err:
 lea .sock_create_err_msg(%rip), %rsi
 call print_info
 call exit_program

