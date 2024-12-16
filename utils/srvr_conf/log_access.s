.section .data
space: .asciz " "
quote: .asciz "\"
http_ver: .asciz " HTTP/1.1"
newline: .asciz "\n"

.equ access_log_buffer_size, 1024

.section .bss
.lcomm access_log_buffer, access_log_buffer_size   # Buffer for constructing log entry

.section .text
.globl log_access
log_access:
    # Parameters:
    # rdi - HTTP method
    # rsi - path
    # rdx - status code (as number)
    # Note: client IP is available in %r14
    push %rbp
    mov %rsp, %rbp
    
    # Preserve r12 and r13
    push %r12
    push %r13
    push %rdi # Save only method on stack as we'll use it first
    
    # Store path and status in preserved registers
    mov %rsi, %r12        # path
    mov %rdx, %r13        # status code
    
    # Start with empty buffer
    lea access_log_buffer(%rip), %rdi
    mov $access_log_buffer_size, %rcx
    call clear_buffer
    
    # Get timestamp and add it
    call get_time_now
    mov %rax, %rsi
    lea access_log_buffer(%rip), %rdi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_concat
    
    # Add space
    lea access_log_buffer(%rip), %rdi
    lea space(%rip), %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_concat
    
    # Add quote
    lea access_log_buffer(%rip), %rdi
    lea quote(%rip), %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_concat
    
    # Add method
    pop %rdi
    mov %rdi, %rsi
    lea access_log_buffer(%rip), %rdi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_concat
    
    # Add space
    lea access_log_buffer(%rip), %rdi
    lea space(%rip), %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_concat
    
    # Add path (using r12)
    lea access_log_buffer(%rip), %rdi
    mov %r12, %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_concat
    
    # Add HTTP version
    lea access_log_buffer(%rip), %rdi
    lea http_ver(%rip), %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_concat
    
    # Add quote
    lea access_log_buffer(%rip), %rdi
    lea quote(%rip), %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_concat
    
    # Add space
    lea access_log_buffer(%rip), %rdi
    lea space(%rip), %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_concat
    
    # Convert status code to string and add it (using r13)
    mov %r13, %rdi
    call int_to_str
    
    lea access_log_buffer(%rip), %rdi
    mov %rax, %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_concat
    
    # Add space
    lea access_log_buffer(%rip), %rdi
    lea space(%rip), %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_concat
    
    # Add IP (using %r14 which contains the client IP pointer)
    lea access_log_buffer(%rip), %rdi
    mov %r14, %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_concat
    
    # Add newline
    lea access_log_buffer(%rip), %rdi
    lea newline(%rip), %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_concat
    
    # Write to log file
    mov CONF_ACCESS_LOG_FD_OFFSET(%r15), %rdi
    lea access_log_buffer(%rip), %rsi
    call str_len
    mov %rax, %rdx
    mov $SYS_write, %rax
    syscall
    
    # Clean up
    pop %r13            # restore preserved registers
    pop %r12
    
    pop %rbp
    ret