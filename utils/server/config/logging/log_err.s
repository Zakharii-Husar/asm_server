.section .rodata
error_prefix_base: .asciz " ERROR"
error_prefix_base_length = . - error_prefix_base
.equ err_log_B_size, 1024


.section .bss
.lcomm err_log_B, err_log_B_size   # Buffer for constructing error log entry

.section .text
.globl log_err
.type log_err, @function
# Function: log_err
# Parameters:
#   - %rdi: pointer to error description string
#   - %rsi: error string length
#   - %rdx: error code
# Global Registers:
#   - %r15: server configuration pointer (for log file paths)
# Return Values:
#   - None
# Error Handling:
#   - Attempts to write to stderr if log file write fails
# Side Effects:
#   - Writes to error log file
#   - Writes to stderr if logging fails
#   - Modifies err_log_B buffer
log_err:
    push %rbp
    mov %rsp, %rbp
    # Preserve registers
    push %r12
    push %r13
    push %r14

    mov %rdi, %r12
    mov %rsi, %r13
    mov %rdx, %r14
    
    # Start with empty buffer
    lea err_log_B(%rip), %rdi
    mov $err_log_B_size, %rsi
    call clear_buffer

    
    # Get timestamp and add it
    call get_time_now
    mov %rax, %rsi
    xor %rdx, %rdx
    lea err_log_B(%rip), %rdi
    mov $err_log_B_size, %rcx
    call str_cat

    # Add base error prefix
    lea err_log_B(%rip), %rdi
    lea error_prefix_base(%rip), %rsi
    mov $error_prefix_base_length, %rdx
    mov $err_log_B_size, %rcx
    call str_cat
    
    # Check if error code is provided (negative number)
    test %r14, %r14  # Check error code in rdx (saved in r14)
    jz .skip_error_code
    
    # Add hash_char symbol since we have an error code
    lea err_log_B(%rip), %rdi
    lea hash_char(%rip), %rsi
    mov $1, %rdx
    mov $err_log_B_size, %rcx
    call str_cat
    
    # Convert error code to string
    mov %r14, %rdi
    call int_to_str
    inc %rax # skip minus sign
    dec %rdx # remove minus sign from length
    
    # Add error code
    lea err_log_B(%rip), %rdi
    mov %rax, %rsi
    # mov %rdx, %rdx int_to_str returns length in %rdx
    mov $err_log_B_size, %rcx
    call str_cat
    

.skip_error_code:

    lea semicolon_char(%rip), %rsi
    lea err_log_B(%rip), %rdi
    mov $1, %rdx # string length
    mov $err_log_B_size, %rcx
    call str_cat

    # Add error description
    lea err_log_B(%rip), %rdi
    mov %r12, %rsi
    mov %r13, %rdx # string length
    mov $err_log_B_size, %rcx
    call str_cat
    # Add newline_char
    lea err_log_B(%rip), %rdi
    lea newline_char(%rip), %rsi
    mov $1, %rdx # string length
    mov $err_log_B_size, %rcx
    call str_cat
    
    # Write to log file
    lea err_log_B(%rip), %rdi
    call str_len
    mov %rax, %rdx
    lea err_log_B(%rip), %rsi
    mov CONF_ERROR_LOG_FD_OFFSET(%r15), %rdi
    mov $SYS_write, %rax
    syscall

    lea err_log_B(%rip), %rdi
    xor %rsi, %rsi
    call print_info 

    # Clean up
    pop %r14
    pop %r13
    pop %r12
    leave                     # restore stack frame
    ret
    