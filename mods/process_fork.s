# Function: process_fork
# Parameters: None
# Return Values: 
#   - Returns 0 on successful fork
#   - Calls exit_program on failure

.section .rodata
fork_err_msg: .asciz "CRITICAL: Failed to fork process in process_fork.s"
fork_err_msg_len = . - fork_err_msg

.section .text
.type process_fork, @function
process_fork:
    push %rbp
    mov %rsp, %rbp
    sub $8, %rsp              # align stack to 16-byte boundary

    mov $SYS_fork, %rax
    syscall
    
    # Check if forking was successful
    cmp $0, %rax
    jl .handle_fork_err

.exit_process_fork:
    leave                     # restore stack frame
    ret
 
.handle_fork_err:
    # Fork failed - this is a critical error
    lea fork_err_msg(%rip), %rdi
    mov $fork_err_msg_len, %rsi
    mov %rax, %rdx                  # Error code for logging
    call log_err             # Log the critical error
    mov $-1, %rax
    jmp .exit_process_fork
    