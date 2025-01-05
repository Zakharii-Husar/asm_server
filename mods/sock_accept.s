.section .rodata

.sock_accept_err_msg:    .asciz "CRITICAL: Failed to accept connection in sock_accept.s"
.sock_accept_err_msg_len = . - .sock_accept_err_msg

.section .data
 .align 4 
connection_info:
    .zero 16              # sockaddr_in structure
    .quad 0               # additional space for fd if needed
    .quad 0               # extra padding to match original size

connection_info_len:
    .quad 16              # size of sockaddr_in

.section .text

# Function: sock_accept
# Parameters: 
#   - %rdi: Socket file descriptor (fd) to accept connections on
# Return Values: 
#   - %rax: Returns a new socket file descriptor on success
#   - %rax: Returns -1 on failure

.type sock_accept, @function
sock_accept:
    push %rbp                                    # save the caller's base pointer
    mov %rsp, %rbp                              # set the new base pointer (stack frame)
 
    mov %r12, %rdi                              # move socket fd into %rdi (1st arg for accept)
    lea connection_info(%rip), %rsi             # store client info in connection_info structure
    lea connection_info_len(%rip), %rdx         # size of sockaddr_in  
    mov $SYS_sock_accept, %rax
    syscall                                     # make syscall

    cmp $0, %rax                               # Compare the return value with 0
    jl  .handle_sock_accept_err                # Jump to error handling if %rax < 0

    mov %rax, %r13                             # save the new connection file descriptor in r13

    lea connection_info(%rip), %rdi
    call extract_client_ip
 
.exit_sock_accept:
    leave                                      # restore stack frame
    ret                                        # return to the caller
 
.handle_sock_accept_err:
    # check if the server is shutting down
    movq server_shutdown_flag(%rip), %r8
    test %r8, %r8
    jnz .exit_sock_accept
    # if not, log the error
    lea .sock_accept_err_msg(%rip), %rdi
    mov $.sock_accept_err_msg_len, %rsi
    mov %rax, %rdx
    call log_err
    mov $-1, %rax
    jmp .exit_sock_accept
