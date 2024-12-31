.section .rodata
exit_err_msg: .asciz "CRITICAL: Failed to exit main process"
exit_err_len = . - exit_err_msg

kill_child_err_msg: .asciz "SEVERE: Failed to terminate child process"
kill_child_err_msg_len = . - kill_child_err_msg

.section .text

.type exit_program, @function
exit_program:
    push %rbp              # Preserve base pointer
    mov %rsp, %rbp        # Set up new stack frame
    sub $8, %rsp          # Align stack to 16-byte boundary
    
    mov %rdi, %r8         # Save process type flag
    mov $SYS_exit, %rax
    xor %rdi, %rdi        # return code 0
    syscall
    
    # If reached here, exit failed 
    # Check if it was child or main process
    cmp $1, %r8
    je .kill_child_err

    # Main process exit failed - Critical
    lea exit_err_msg(%rip), %rdi
    mov $exit_err_len, %rsi
    mov %rax, %rdx        # Pass error code
    call log_err
    
    # Try forceful exit with critical error code
    mov $SYS_exit_group, %rax
    mov $137, %rdi        # 128 + 9 (SIGKILL)
    syscall
    jmp .

.kill_child_err:
    # Child process exit failed - Severe
    lea kill_child_err_msg(%rip), %rdi
    mov $kill_child_err_msg_len, %rsi
    mov %rax, %rdx        # Pass error code
    call log_err
    
    # Try forceful exit with severe error code
    mov $SYS_exit_group, %rax
    mov $134, %rdi        # 128 + 6 (SIGABRT)
    syscall
    jmp .
