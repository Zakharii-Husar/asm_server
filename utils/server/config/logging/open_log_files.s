.section .data
log_open_flags: .long 0644    # File permissions (rw-r--r--)
log_file_mode:  .long 02102   # O_APPEND | O_CREAT | O_WRONLY

.section .text
.globl open_log_files
open_log_files:
    push %rbp
    mov %rsp, %rbp

    # Open access log file
    # Get access log path from struct (already in r15)
    lea CONF_ACCESS_LOG_PATH_OFFSET(%r15), %rdi  # First arg: path
    mov log_open_flags(%rip), %rdx               # Third arg: mode
    mov log_file_mode(%rip), %rsi               # Second arg: flags
    mov $SYS_open, %rax                         # syscall number for open
    syscall

    # Store access log FD in struct
    mov %rax, CONF_ACCESS_LOG_FD_OFFSET(%r15)

    # Open error log file
    # Get error log path from struct
    lea CONF_ERROR_LOG_PATH_OFFSET(%r15), %rdi   # First arg: path
    mov log_open_flags(%rip), %rdx               # Third arg: mode
    mov log_file_mode(%rip), %rsi               # Second arg: flags
    mov $SYS_open, %rax                         # syscall number for open
    syscall

    # Store error log FD in struct
    mov %rax, CONF_ERROR_LOG_FD_OFFSET(%r15)


    pop %rbp
    ret
    