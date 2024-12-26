.section .rodata
socket_prefix_base: .asciz " SOCKET"
socket_prefix_base_length = . - socket_prefix_base

.equ sock_log_B_size, 1024

.section .bss
.lcomm sock_log_B, sock_log_B_size   # Buffer for constructing socket log entry

.section .text
.globl log_sock
log_sock:
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
    lea sock_log_B(%rip), %rdi
    mov $sock_log_B_size, %rsi
    call clear_buffer
    
    # Get timestamp and add it
    call get_time_now
    mov %rax, %rsi
    xor %rdx, %rdx
    lea sock_log_B(%rip), %rdi
    mov $sock_log_B_size, %rcx
    call str_cat

    # Add socket prefix
    lea sock_log_B(%rip), %rdi
    lea socket_prefix_base(%rip), %rsi
    mov $socket_prefix_base_length, %rdx
    mov $sock_log_B_size, %rcx
    call str_cat
    
    # Add semicolon separator
    lea sock_log_B(%rip), %rdi
    lea semicolon_char(%rip), %rsi
    mov $1, %rdx
    mov $sock_log_B_size, %rcx
    call str_cat

    # Add event description
    lea sock_log_B(%rip), %rdi
    mov %r12, %rsi        # Description string
    mov %r13, %rdx        # Length
    mov $sock_log_B_size, %rcx
    call str_cat

    # Add newline
    lea sock_log_B(%rip), %rdi
    lea newline_char(%rip), %rsi
    mov $1, %rdx
    mov $sock_log_B_size, %rcx
    call str_cat
    
    # Write to access log file
    lea sock_log_B(%rip), %rdi
    call str_len
    mov %rax, %rdx
    lea sock_log_B(%rip), %rsi
    mov CONF_ACCESS_LOG_FD_OFFSET(%r15), %rdi
    mov $SYS_write, %rax
    syscall

    # Clean up
    pop %r13
    pop %r12
    pop %rbp
    ret