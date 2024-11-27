.section .rodata

.sock_accepted_msg:    .asciz "\033[32mConnection was accepted 🔄\033[0m\n"
.sock_accept_err_msg:    .asciz "\033[31mFailed to accept connection ❌\033[0m\n"

.section .data
connection_info:
    .zero 16              # sockaddr_in structure
    .quad 0               # additional space for fd if needed
client_len:
    .quad 16              # size of sockaddr_in

.section .text

# Function: sock_accept
# Parameters: 
#   - %rdi: Socket file descriptor (fd) to accept connections on
# Return Values: 
#   - Returns a new socket file descriptor on success
#   - Calls exit_program on failure

.type sock_accept, @function
sock_accept:
 push %rbp                                    # save the caller's base pointer
 mov %rsp, %rbp                               # set the new base pointer (stack frame)
 
 mov %r12, %rdi                               # move socket fd into %rdi (1st arg for accept)
 lea connection_info(%rip), %rsi              # store client info in our structure
 lea client_len(%rip), %rdx                   
 mov $SYS_sock_accept, %rax
 syscall                                      # make syscall

 cmp $0, %rax                                 # Compare the return value with 0
 jl  .handle_sock_accept_err                   # Jump to error handling if %rax < 0

 mov    %rax, %r13                             # save the new connection file descriptor in r13
    
 lea connection_info(%rip), %r14               # r14 points to client info
 lea .sock_accepted_msg(%rip), %rsi            # pointer to the message (from constants.s)
 call print_info

 pop %rbp                                      # restore the caller's base pointer
 ret                                           # return to the caller
 
.handle_sock_accept_err:
 lea .sock_accept_err_msg(%rip), %rsi           # pointer to the message (from constants.s)
 call print_info
 call exit_program
