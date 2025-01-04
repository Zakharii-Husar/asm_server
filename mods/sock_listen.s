.section .rodata

.sock_listen_msg:    .asciz "TCP socket listening"
.sock_listen_msg_length = . - .sock_listen_msg

.sock_listen_err_msg:    .asciz "CRITICAL: Socket failed to listen in sock_listen.s"
.sock_listen_err_msg_length = . - .sock_listen_err_msg

.section .text

# Function: sock_listen
# Parameters:
#   - none
# Implicit Parameters:
#   - %r12: Socket file descriptor (fd)
# Return Values:
#   - none
# Side Effects:
#   - listen() syscall

.type sock_listen, @function
sock_listen:
    push %rbp                    # save the caller's base pointer
    mov %rsp, %rbp              # set the new base pointer (stack frame)

    mov %r12, %rdi                         # move socket fd into %rdi (1st arg for bind)
    mov $SYS_sock_listen, %rax
    lea CONF_MAX_CONN_OFFSET(%r15), %rsi
    syscall

    cmp $0, %rax                          # Compare the return value with 0
    jl  .handle_sock_listen_err           # Jump to error handling if %rax < 0

    lea .sock_listen_msg(%rip), %rdi
    mov $.sock_listen_msg_length, %rsi
    call log_sys

.exit_sock_listen:
    leave                                 # restore stack frame
    ret                                  # return to the caller

.handle_sock_listen_err:
    lea .sock_listen_err_msg(%rip), %rdi
    mov $.sock_listen_err_msg_length, %rsi
    call log_err
    mov $-1, %rax
    jmp .exit_sock_listen

 