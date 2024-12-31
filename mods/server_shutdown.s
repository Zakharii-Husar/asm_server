.section .rodata
shutdown_msg: .asciz "Shutting down server..."
shutdown_msg_len = . - shutdown_msg

.section .text
.global server_shutdown
.type server_shutdown, @function
server_shutdown:
    push %rbp
    mov %rsp, %rbp
    sub $8, %rsp              # align stack to 16-byte boundary

    # Log shutdown message
    lea shutdown_msg(%rip), %rdi
    mov $shutdown_msg_len, %rsi
    call log_sys

    # Close connection if exists
    cmp $0, %r13
    jle .skip_conn_close
    mov %r13, %rdi
    mov $SYS_close, %rax
    syscall
    
.skip_conn_close:
    # Close socket
    mov %r12, %rdi
    mov $SYS_close, %rax
    syscall

    # Close log files
    # Close warning log
    mov CONF_WARNING_LOG_FD_OFFSET(%r15), %rdi
    mov $SYS_close, %rax
    syscall

    # Close error log
    mov CONF_ERROR_LOG_FD_OFFSET(%r15), %rdi
    mov $SYS_close, %rax
    syscall

    # Close access log
    mov CONF_ACCESS_LOG_FD_OFFSET(%r15), %rdi
    mov $SYS_close, %rax
    syscall

    # Close system log
    mov CONF_SYSTEM_LOG_FD_OFFSET(%r15), %rdi
    mov $SYS_close, %rax
    syscall

    # No need to restore stack since exit_program never returns
    xor %rdi, %rdi        # exit code 0
    call exit_program
    