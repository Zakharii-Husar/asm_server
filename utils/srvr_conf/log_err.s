.section .data
error_prefix: .asciz " ERROR: "
newline: .asciz "\n"

.section .bss
.lcomm error_log_buffer, access_log_buffer_size   # Buffer for constructing error log entry

.section .text
.globl log_err
log_err:
    # Parameters:
    # rdi - pointer to error description string
    # rsi - optional negative error code
    push %rbp
    mov %rsp, %rbp
    
    # Preserve registers
    push %r12
    push %r13
    push %r14
    
    # Start with empty buffer
    lea error_log_buffer(%rip), %rdi
    mov $access_log_buffer_size, %rsi
    call clear_buffer
    
    # Get timestamp and add it
    call get_time_now
    mov %rax, %rsi
    lea error_log_buffer(%rip), %rdi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_concat

    # Add error prefix
    lea error_log_buffer(%rip), %rdi
    lea error_prefix(%rip), %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_concat
    
    # Add error description
    lea error_log_buffer(%rip), %rdi
    mov %rdi, %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_concat
    
    # Check if error code is provided (negative number)
    test %rsi, %rsi
    jz .skip_error_code
    
    # Add space before error code
    lea error_log_buffer(%rip), %rdi
    lea spc(%rip), %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_concat
    
    # Convert error code to string
    mov %rsi, %rdi
    call int_to_str
    
    # Add error code
    lea error_log_buffer(%rip), %rdi
    mov %rax, %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_concat

.skip_error_code:
    # Add newline
    lea error_log_buffer(%rip), %rdi
    lea newline(%rip), %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_concat
    
    # Write to log file
    lea error_log_buffer(%rip), %rdi
    call str_len
    mov %rax, %rdx
    lea error_log_buffer(%rip), %rsi
    mov CONF_ERROR_LOG_FD_OFFSET(%r15), %rdi
    mov $SYS_write, %rax
    syscall

    # Clean up
    pop %r14
    pop %r13
    pop %r12
    pop %rbp
    ret