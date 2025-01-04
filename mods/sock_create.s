.section .rodata

.sock_create_err_msg:    .asciz "CRITICAL: Failed to create TCP socket in sock_create.s"
.sock_create_err_msg_length = . - .sock_create_err_msg  

.sock_create_msg:    .asciz "TCP socket created"
.sock_create_msg_length = . - .sock_create_msg  

.section .text
# Function: sock_create
# Parameters:
#   - None (uses predefined constants for socket creation)
# Return Values:
#   - none
# Side Effects:
#   - %r12: Socket file descriptor (fd)

.type sock_create, @function

sock_create:
    push %rbp                    # save the caller's base pointer
    mov %rsp, %rbp              # set the new base pointer (stack frame)

    mov $SYS_sock_create, %rax
    mov $AF_INET, %rdi
    mov $SOCK_STREAM, %rsi
    mov $SOCK_PROTOCOL, %rdx
    syscall

    cmp $0, %rax                # Compare the return value with 0
    jl  .handle_sock_create_err # Jump to error handling if %rax < 0
    mov %rax, %r12              # save socket fd to %r12

    lea .sock_create_msg(%rip), %rdi
    mov $.sock_create_msg_length, %rsi
    call log_sys

    .exit_sock_create:
    leave                       # restore stack frame
    ret                        # return to the caller

.handle_sock_create_err:
    lea .sock_create_err_msg(%rip), %rdi
    mov $.sock_create_err_msg_length, %rsi
    call log_err
    mov $-1, %rax
    jmp .exit_sock_create
