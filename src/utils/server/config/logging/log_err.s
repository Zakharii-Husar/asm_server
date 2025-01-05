.section .rodata
error_prefix_base: .asciz " ERROR"
error_prefix_base_length = . - error_prefix_base
.equ err_log_B_size, 1024

.timestamp_error_prefix: .asciz "[FAILED TO GET TIME]"
.timestamp_error_prefix_length = . - .timestamp_error_prefix


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
    push %r12
    push %r13
    push %r14

    mov %rdi, %r12   # error message
    mov %rsi, %r13   # message length
    mov %rdx, %r14   # error code

    # Get timestamp
    call get_time_now
    # Check if timestamp is valid
    cmp $0, %rax
    jle .failed_to_get_time
    cmp $0, %rdx
    jle .failed_to_get_time

    mov %rax, %r8 # timestamp string
    mov %rdx, %r9 # timestamp length

    # Write timestamp
    mov %rax, %rsi          # timestamp string
    # mov %rdx, %rdx (already in %rdx)
    mov CONF_ERROR_LOG_FD_OFFSET(%r15), %rdi
    mov $SYS_write, %rax
    syscall

    mov %r8, %rdi
    mov %r9, %rsi
    call print_info

    jmp .append_error_prefix

    .failed_to_get_time:
    lea .timestamp_error_prefix(%rip), %rsi
    mov $.timestamp_error_prefix_length, %rdx
    dec %rdx # remove null terminator
    mov CONF_ERROR_LOG_FD_OFFSET(%r15), %rdi
    mov $SYS_write, %rax
    syscall

    lea .timestamp_error_prefix(%rip), %rdi
    mov $.timestamp_error_prefix_length, %rsi
    call print_info

    .append_error_prefix:
    # Write error prefix
    lea error_prefix_base(%rip), %rsi
    mov $error_prefix_base_length, %rdx
    dec %rdx # remove null terminator
    mov CONF_ERROR_LOG_FD_OFFSET(%r15), %rdi
    mov $SYS_write, %rax
    syscall

    lea error_prefix_base(%rip), %rdi
    mov $error_prefix_base_length, %rsi
    call print_info

    # Write error code if present
    test %r14, %r14
    jz .skip_error_code
    
    # Write hash symbol
    lea hash_char(%rip), %rsi
    mov $1, %rdx
    mov CONF_ERROR_LOG_FD_OFFSET(%r15), %rdi
    dec %rdx # remove null terminator
    mov $SYS_write, %rax
    syscall

    lea hash_char(%rip), %rdi
    mov $1, %rsi
    call print_info

    # Convert and write error code
    mov %r14, %rdi
    call int_to_str

    # preserve error code string and length 
    mov %rax, %r8 # error code string
    mov %rdx, %r9 # error code length

    mov %rax, %rsi
    # mov %rdx, %rdx (already in %rdx)
    dec %rdx # remove null terminator
    mov CONF_ERROR_LOG_FD_OFFSET(%r15), %rdi
    mov $SYS_write, %rax
    syscall

    mov %r8, %rdi
    mov %r9, %rsi
    call print_info

.skip_error_code:
    # Write semicolon
    lea semicolon_char(%rip), %rsi
    mov $1, %rdx
    mov CONF_ERROR_LOG_FD_OFFSET(%r15), %rdi
    mov $SYS_write, %rax
    syscall

    lea semicolon_char(%rip), %rdi
    mov $1, %rsi
    call print_info

    # Write error message
    mov %r12, %rsi
    mov %r13, %rdx
    mov CONF_ERROR_LOG_FD_OFFSET(%r15), %rdi
    mov $SYS_write, %rax
    syscall

    mov %r12, %rdi
    mov %r13, %rsi
    call print_info 

    # Write newline
    lea newline_char(%rip), %rsi
    mov $1, %rdx
    mov CONF_ERROR_LOG_FD_OFFSET(%r15), %rdi
    mov $SYS_write, %rax
    syscall

    lea newline_char(%rip), %rdi
    mov $1, %rsi
    call print_info

    pop %r14
    pop %r13
    pop %r12
    leave
    ret
    