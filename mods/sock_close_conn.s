# sock_close_conn.s
.section .rodata

.sock_close_parent_msg:    .asciz "\033[33mParent process was closed 🧔🔒\033[0m\n"
.sock_close_parent_msg_length = . - .sock_close_parent_msg

.sock_close_parent_err_msg:    .asciz "\033[31mFailed to close parent process! ❌\033[0m\n"
.sock_close_parent_err_msg_length = . - .sock_close_parent_err_msg

.sock_close_child_msg:    .asciz "\033[33mChild process was closed 👶🔒\033[0m\n"
.sock_close_child_msg_length = . - .sock_close_child_msg

.sock_close_child_err_msg:    .asciz "\033[31mFailed to close child process! ❌\033[0m\n"
.sock_close_child_err_msg_length = . - .sock_close_child_err_msg


.section .text

# Function: sock_close_conn
# Parameters:
#   - %rdi: 0 for parent, 1 for child
# Return Values:
#   - Returns 0 on successful closure of the connection
#   - Calls exit_program on failure

.type sock_close_conn, @function
sock_close_conn:
    push %rbp
    mov %rsp, %rbp
    sub $8, %rsp              # align stack to 16-byte boundary
    
    mov %rdi, %r8            # save process type flag

    # Check if connection FD is valid
    cmp $0, %r13
    jle .exit_sock_close

    mov %r13, %rdi
    mov $SYS_close, %rax
    syscall
    
    # Only check for errors if we're not shutting down
    movq server_shutdown_flag(%rip), %r9
    test %r9, %r9
    jnz .exit_sock_close
    
    cmp $0, %rax
    jl .handle_close_conn_error

.exit_sock_close:
    leave                    # restore stack frame
    ret

.handle_close_conn_error:
    cmp $0, %r8
    je .handle_sock_close_parent_err

.handle_sock_close_child_err:
    lea .sock_close_child_err_msg(%rip), %rdi
    mov $.sock_close_child_err_msg_length, %rsi
    call print_info
    call exit_program       # no need to clean up stack as this never returns

.handle_sock_close_parent_err:
    lea .sock_close_parent_err_msg(%rip), %rdi
    mov $.sock_close_parent_err_msg_length, %rsi
    call print_info
    call exit_program       # no need to clean up stack as this never returns

