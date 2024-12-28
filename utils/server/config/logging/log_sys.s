.section .rodata
sys_prefix_base: .asciz " SYSTEM: "
sys_prefix_base_length = . - sys_prefix_base

.equ sys_log_B_size, 1024

.section .bss
.lcomm sys_log_B, sys_log_B_size   # Buffer for constructing socket log entry

.section .text
.globl log_sys
log_sys:
    # Parameters:
    # rdi - pointer to socket event description string
    # rsi - string length
    push %rbp
    mov %rsp, %rbp
    
    # Preserve registers
    push %r12
    push %r13
    
    mov %rdi, %r12   # Save description pointer
    mov %rsi, %r13   # Save length
    
    # Start with empty buffer
    lea sys_log_B(%rip), %rdi
    mov $sys_log_B_size, %rsi
    call clear_buffer
    
    # Get timestamp and add it
    call get_time_now
    mov %rax, %rsi
    xor %rdx, %rdx
    lea sys_log_B(%rip), %rdi
    mov $sys_log_B_size, %rcx
    call str_cat

    # Add socket prefix
    lea sys_log_B(%rip), %rdi
    lea sys_prefix_base(%rip), %rsi
    mov $sys_prefix_base_length, %rdx
    mov $sys_log_B_size, %rcx
    call str_cat

    # Add event description
    lea sys_log_B(%rip), %rdi
    mov %r12, %rsi        # Description string
    mov %r13, %rdx        # Length
    mov $sys_log_B_size, %rcx
    call str_cat

    # Add newline
    lea sys_log_B(%rip), %rdi
    lea newline_char(%rip), %rsi
    mov $1, %rdx
    mov $sys_log_B_size, %rcx
    call str_cat
    
    # Write to access log file
    lea sys_log_B(%rip), %rdi
    call str_len
    mov %rax, %rdx
    lea sys_log_B(%rip), %rsi
    mov CONF_SYSTEM_LOG_FD_OFFSET(%r15), %rdi
    mov $SYS_write, %rax
    syscall

    lea sys_log_B(%rip), %rdi
    xor %rsi, %rsi
    call print_info

    # Clean up
    pop %r13
    pop %r12
    pop %rbp
    ret
    