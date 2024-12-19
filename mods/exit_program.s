.section .data
exit_err_msg: .asciz "Critical: Failed to exit program"
exit_err_len = . - exit_err_msg

.section .text

.type exit_program, @function
exit_program:
    mov $SYS_exit, %rax
    xor %rdi, %rdi       # return code 0
    syscall
    
    # If reached here, exit failed 
    # Prepare error message for logging
    lea exit_err_msg(%rip), %rdi
    mov $exit_err_len, %rsi
    mov %rax, %rdx      # Pass error code
    call log_err
    
    # Try forceful exit as fallback
    mov $SYS_exit_group, %rax
    mov $1, %rdi        # Error exit code
    syscall
    
    # If we somehow get here, enter infinite loop as last resort
    jmp .
