# Function: process_fork
# Parameters: None
# Return Values: 
#   - Returns 0 on successful fork
#   - Calls exit_program on failure

.section .rodata
fork_err_msg: .asciz "CRITICAL: Failed to fork process"
fork_err_msg_len = . - fork_err_msg

.section .text
.type process_fork, @function
process_fork:
    push %rbp
    mov %rsp, %rbp

    mov $SYS_fork, %rax
    syscall
    
    # Check if forking was successful
    cmp $0, %rax
    jl .handle_fork_err


.exit_process_fork:
    pop %rbp
    ret
 
.handle_fork_err:
    # Fork failed - this is a critical error
    push %rax                    # Save error code
    lea fork_err_msg(%rip), %rdi
    mov $fork_err_msg_len, %rsi
    pop %rdx                     # Error code for logging
    call log_err                 # Log the critical error
    jmp .exit_process_fork