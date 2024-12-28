.section .rodata
shutdown_msg: .asciz "Shutting down server..."
shutdown_msg_len = . - shutdown_msg

.section .text
.global server_shutdown
.type server_shutdown, @function
server_shutdown:
    # Save registers
    push %rbp
    mov %rsp, %rbp

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

    # Restore registers
    pop %rbp

    # Exit with success code
    xor %rdi, %rdi        # exit code 0
    call exit_program