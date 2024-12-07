.section .data
    .addr_in:                      # Just reserve the space, no initialization
    .space 16                      # 16 bytes for sockaddr_in structure

.section .rodata

.sock_bound_msg:    .asciz "\033[32mTCP Sock was bound 🔗\033[0m\n"
.sock_bound_msg_length = . - .sock_bound_msg

.sock_bind_err_msg:    .asciz "\033[31mFailed to bind TCP Socket ❌\033[0m\n"
.sock_bind_err_msg_length = . - .sock_bind_err_msg

.section .text

# Function: sock_bind
# Parameters: 
#   - %rdi: Socket file descriptor (fd) to bind
# Return Values: 
#   - Returns 0 on success
#   - Calls exit_program on failure

.type sock_bind, @function
sock_bind:
 push %rbp                              # save the caller's base pointer
 mov %rsp, %rbp                         # set the new base pointer (stack frame)
 
 # Initialize the struct before binding
 lea .addr_in(%rip), %rax               # Get pointer to struct
 movw $2, (%rax)                        # AF_INET
 movl CONF_PORT_OFFSET(%r15), %edx      # Get port from config into 32-bit register
 movw %dx, 2(%rax)                      # Store lower 16 bits into struct
 movl CONF_HOST_OFFSET(%r15), %edx      # Get host IP from config
 movl %edx, 4(%rax)                     # Store IP address into struct
 movq $0, 8(%rax)                       # Padding
 
 mov %r12, %rdi                         # move socket fd into %rdi (1st arg for bind)
 mov    $SYS_sock_bind, %rax            # sys_bind
 lea     .addr_in(%rip), %rsi           # pointer to the address structure
 mov    $16, %rdx                       # size of the sockaddr_in structure
 syscall                                # make syscall

 cmp $0, %rax                           # Compare the return value with 0
 jl  .handle_sock_bind_err               # Jump to error handling if %rax < 0
    
 # lea .sock_bound_msg(%rip), %rsi         # pointer to the message (from constants.s)
 # mov $.sock_bound_msg_length, %rdx       # length of the message (from constants.s)
 # call print_info

 pop %rbp                               # restore the caller's base pointer
 ret                                    # return to the caller

.handle_sock_bind_err:
 lea .sock_bind_err_msg(%rip), %rdi      # pointer to the message (from constants.s)
 mov $.sock_bind_err_msg_length, %rsi    # length of the message (from constants.s)
 call print_info
 call exit_program
