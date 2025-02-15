.section .rodata
http_ver: .asciz " HTTP/1.1"
.equ access_log_buffer_size, 1024

.section .bss
.lcomm access_log_buffer, access_log_buffer_size   # Buffer for constructing log entry

.section .text
.globl log_access
.type log_access, @function
# Parameters:
#   - %rdi: HTTP method string pointer
#   - %rsi: request path string pointer
#   - %rdx: HTTP status code
# Global Registers:
#   - %r14: client IP string pointer
#   - %r15: server configuration pointer
# Return Values:
#   - None
# Error Handling:
#   - Attempts to write to stderr if log file write fails
# Side Effects:
#   - Writes to access log file
#   - Modifies access_log_buffer
log_access:

    push %rbp
    mov %rsp, %rbp
    sub $16, %rsp        # Allocate 16 bytes to maintain stack alignment
    # First preserve non-volatile registers
    push %r12
    push %r13
    
    mov %rdi, -8(%rbp)   # Store method pointer in local variable
    
    # Store path and status in preserved registers
    mov %rsi, %r12        # path
    mov %rdx, %r13        # status code
    
    # Start with empty buffer
    lea access_log_buffer(%rip), %rdi
    mov $access_log_buffer_size, %rsi
    call clear_buffer
    
    # Get timestamp and add it
    call get_time_now
    mov %rax, %rsi
    lea access_log_buffer(%rip), %rdi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_cat


    # Add space_char
    lea access_log_buffer(%rip), %rdi
    lea space_char(%rip), %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_cat
    
    
    # Add quote_char
    lea access_log_buffer(%rip), %rdi
    lea quote_char(%rip), %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_cat
    
    # Add method (using local variable instead of pop)
    mov -8(%rbp), %rsi    # Load method pointer from local variable
    lea access_log_buffer(%rip), %rdi
    xor %rdx, %rdx        # string length
    mov $access_log_buffer_size, %rcx
    call str_cat
    
    # Add space_char
    lea access_log_buffer(%rip), %rdi
    lea space_char(%rip), %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_cat
    
    # Add path (using r12)
    lea access_log_buffer(%rip), %rdi
    mov %r12, %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_cat
    
    # Add HTTP version
    lea access_log_buffer(%rip), %rdi
    lea http_ver(%rip), %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_cat
    
    
    # Add quote_char
    lea access_log_buffer(%rip), %rdi
    lea quote_char(%rip), %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_cat
    
    # Add space_char
    lea access_log_buffer(%rip), %rdi
    lea space_char(%rip), %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_cat
    
    # Convert status code to string and add it (using r13)
    mov %r13, %rdi
    call int_to_str
    
    lea access_log_buffer(%rip), %rdi
    mov %rax, %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_cat
    
    # Add space_char
    lea access_log_buffer(%rip), %rdi
    lea space_char(%rip), %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_cat

    # Add IP (using %r14 which contains the client IP pointer)
    lea access_log_buffer(%rip), %rdi
    mov %r14, %rsi                # Use actual client IP pointer from %r14
    xor %rdx, %rdx               # string length
    mov $access_log_buffer_size, %rcx
    call str_cat


    # Add newline_char
    lea access_log_buffer(%rip), %rdi
    lea newline_char(%rip), %rsi
    xor %rdx, %rdx # string length
    mov $access_log_buffer_size, %rcx
    call str_cat


    
    # Write to log file
    lea access_log_buffer(%rip), %rdi
    call str_len
    mov %rax, %rdx
    lea access_log_buffer(%rip), %rsi
    mov CONF_ACCESS_LOG_FD_OFFSET(%r15), %rdi
    mov $SYS_write, %rax
    syscall

    # Clean up in reverse order
    pop %r13            # restore preserved registers
    pop %r12
    add $16, %rsp        # Deallocate local variables
    leave              # restore stack frame
    ret
