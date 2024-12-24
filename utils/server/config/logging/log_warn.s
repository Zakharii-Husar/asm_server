.section .data
warn_prefix_base: .asciz " WARN:"
warn_prefix_base_length = . - warn_prefix_base

.equ warn_log_B_size, 1024

.section .bss
.lcomm warn_log_B, warn_log_B_size   # Buffer for constructing warning log entry

.section .text
.globl log_warn
log_warn:
    # Parameters:
    # rdi - pointer to warning description string
    # rsi - string length
    push %rbp
    mov %rsp, %rbp
    
    # Preserve registers
    push %r12
    push %r13
    
    mov %rdi, %r12   # Save description pointer
    mov %rsi, %r13   # Save length
    
    # Start with empty buffer
    lea warn_log_B(%rip), %rdi
    mov $warn_log_B_size, %rsi
    call clear_buffer
    
    # Get timestamp and add it
    call get_time_now
    mov %rax, %rsi
    xor %rdx, %rdx
    lea warn_log_B(%rip), %rdi
    mov $warn_log_B_size, %rcx
    call str_concat

    # Add warning prefix
    lea warn_log_B(%rip), %rdi
    lea warn_prefix_base(%rip), %rsi
    mov $warn_prefix_base_length, %rdx
    mov $warn_log_B_size, %rcx
    call str_concat

    # Add warning description
    lea warn_log_B(%rip), %rdi
    mov %r12, %rsi
    mov %r13, %rdx
    mov $warn_log_B_size, %rcx
    call str_concat

    # Add newline
    lea warn_log_B(%rip), %rdi
    lea nl(%rip), %rsi
    mov $1, %rdx
    mov $warn_log_B_size, %rcx
    call str_concat
    
    # Write to log file
    lea warn_log_B(%rip), %rdi
    call str_len
    mov %rax, %rdx
    lea warn_log_B(%rip), %rsi
    mov CONF_WARNING_LOG_FD_OFFSET(%r15), %rdi
    mov $SYS_write, %rax
    syscall

    lea warn_log_B(%rip), %rdi
    xor %rsi, %rsi
    call print_info

    # Clean up
    pop %r13
    pop %r12
    pop %rbp
    ret
