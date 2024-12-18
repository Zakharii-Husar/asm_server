.section .data
error_prefix: .asciz " ERROR: "
nl: .asciz "\n"

.equ err_log_B_size, 1024

.section .bss
.lcomm err_log_B, err_log_B_size   # Buffer for constructing error log entry

.section .text
.globl log_err
log_err:
    # Parameters:
    # rdi - pointer to error description string
    # rsi - optional negative error code
    # rdx - error code
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
    lea err_log_B(%rip), %rdi
    xor %rdx, %rdx # string length
    mov $err_log_B_size, %rcx
    call str_concat

    # Add error prefix
    lea err_log_B(%rip), %rdi
    lea error_prefix(%rip), %rsi
    xor %rdx, %rdx # string length
    mov $err_log_B_size, %rcx
    call str_concat
    
    # Add error description
    lea err_log_B(%rip), %rdi
    mov %r12, %rsi
    mov %r13, %rdx # string length
    mov $err_log_B_size, %rcx
    call str_concat
    
    # Check if error code is provided (negative number)
    test %rsi, %rsi
    jz .skip_error_code
    
    
    # Convert error code to string
    mov %r14, %rdi
    call int_to_str
    
    # Add error code
    lea err_log_B(%rip), %rdi
    mov %rax, %rsi
    # mov %rdx, %rdx int_to_str returns length in %rdx
    mov $err_log_B_size, %rcx
    call str_concat

.skip_error_code:
    # Add nl
    lea err_log_B(%rip), %rdi
    lea nl(%rip), %rsi
    xor %rdx, %rdx # string length
    mov $err_log_B_size, %rcx
    call str_concat
    
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
    pop %r12
    pop %rbp
    ret
