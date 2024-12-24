.section .data
log_file_flags: .long 0644                    # File permissions (rw-r--r--)
log_open_file_mode: .long 02                  # O_RDWR
log_create_file_mode: .long 02102             # O_RDWR | O_CREAT | O_APPEND

# Creation messages (to be logged after files are opened)
create_access_log_msg: .asciz "MODERATE: Created new access log file in open_log_files.s"
create_access_log_len = . - create_access_log_msg
create_error_log_msg: .asciz "MODERATE: Created new error log file in open_log_files.s"
create_error_log_len = . - create_error_log_msg
create_warning_log_msg: .asciz "MODERATE: Created new warning log file in open_log_files.s"
create_warning_log_len = . - create_warning_log_msg

.access_log_path_warn_msg: .asciz "MODERATE: Access log file path is not set, using default path in open_log_files.s"
.access_log_path_warn_msg_len = . - .access_log_path_warn_msg
.error_log_path_warn_msg: .asciz "MODERATE: Error log file path is not set, using default path in open_log_files.s"
.error_log_path_warn_msg_len = . - .error_log_path_warn_msg
.warning_log_path_warn_msg: .asciz "MODERATE: Warning log file path is not set, using default path in open_log_files.s"
.warning_log_path_warn_msg_len = . - .warning_log_path_warn_msg

.default_error_log: .asciz "./log/error.log"
.default_access_log: .asciz "./log/access.log"
.default_warning_log: .asciz "./log/warning.log"

.section .text
.globl open_log_files
open_log_files:
    push %rbp
    mov %rsp, %rbp
    
    push %r12
    push %r13
    push %r14

    # SAVE LOG FILES INITIAL STATE (-1 OR PATHS)
    mov CONF_WARNING_LOG_PATH_OFFSET(%r15), %r12
    mov CONF_ERROR_LOG_PATH_OFFSET(%r15), %r13
    mov CONF_ACCESS_LOG_PATH_OFFSET(%r15), %r14
    
    # CHECK IF LOGS FILE PATHS ARE SET, IF NOT SET THEM TO DEFAULT
    cmpq $-1, CONF_WARNING_LOG_PATH_OFFSET(%r15)
    jne .check_error_log_path
    lea .default_warning_log(%rip), %rdi
    mov %rdi, CONF_WARNING_LOG_PATH_OFFSET(%r15)

.check_error_log_path:
    cmpq $-1, CONF_ERROR_LOG_PATH_OFFSET(%r15)
    jne .check_access_log_path
    lea .default_error_log(%rip), %rdi
    mov %rdi, CONF_ERROR_LOG_PATH_OFFSET(%r15)

.check_access_log_path:
    cmpq $-1, CONF_ACCESS_LOG_PATH_OFFSET(%r15)
    jne .continue_opening_files
    lea .default_access_log(%rip), %rdi
    mov %rdi, CONF_ACCESS_LOG_PATH_OFFSET(%r15)

.continue_opening_files:
    # TRY TO OPEN WARNING LOG FILE
    mov CONF_WARNING_LOG_PATH_OFFSET(%r15), %rdi
    mov log_open_file_mode(%rip), %rsi
    mov log_file_flags(%rip), %rdx
    mov $SYS_open, %rax
    syscall
    
    cmp $0, %rax               # failed to open, create it
    jl .create_warning_log
    mov %rax, CONF_WARNING_LOG_FD_OFFSET(%r15)
    jmp .try_error_log

.create_warning_log:
    mov CONF_WARNING_LOG_PATH_OFFSET(%r15), %rdi
    mov log_create_file_mode(%rip), %rsi
    mov log_file_flags(%rip), %rdx
    mov $SYS_open, %rax
    syscall
    cmp $0, %rax
    jl .exit_server
    mov %rax, CONF_WARNING_LOG_FD_OFFSET(%r15)
    lea create_warning_log_msg(%rip), %rdi
    mov $create_warning_log_len, %rsi
    call log_warn

    # TRY TO OPEN ERROR LOG FILE IF IT EXISTS
    .try_error_log:
    mov CONF_ERROR_LOG_PATH_OFFSET(%r15), %rdi
    mov log_file_flags(%rip), %rdx
    mov log_open_file_mode(%rip), %rsi
    mov $SYS_open, %rax
    syscall
    cmp $0, %rax
    jl .create_error_log # failed to open, create it
    # SAVE NEW ERROR LOG FILE DESCRIPTOR
    mov %rax, CONF_ERROR_LOG_FD_OFFSET(%r15)
    jmp .try_access_log
    # CREATE ERROR LOG FILE
    .create_error_log:
    mov CONF_ERROR_LOG_PATH_OFFSET(%r15), %rdi
    mov log_create_file_mode(%rip), %rsi
    mov log_file_flags(%rip), %rdx
    mov $SYS_open, %rax
    syscall
    cmp $0, %rax
    jl .exit_server # some other error. Exit server
    mov %rax, CONF_ERROR_LOG_FD_OFFSET(%r15)
    lea create_error_log_msg(%rip), %rdi
    mov $create_error_log_len, %rsi
    call log_warn

    # TRY TO OPEN ACCESS LOG FILE IF IT EXISTS
    .try_access_log:
    mov CONF_ACCESS_LOG_PATH_OFFSET(%r15), %rdi
    mov log_file_flags(%rip), %rdx
    mov log_open_file_mode(%rip), %rsi
    mov $SYS_open, %rax
    syscall
    cmp $0, %rax
    jl .create_access_log  # failed to open, create it
    # SAVE NEW ACCESS LOG FILE DESCRIPTOR
    mov %rax, CONF_ACCESS_LOG_FD_OFFSET(%r15)
    jmp .validate_access_log_path
    # CREATE ACCESS LOG FILE
    .create_access_log:
    mov CONF_ACCESS_LOG_PATH_OFFSET(%r15), %rdi
    mov log_create_file_mode(%rip), %rsi
    mov log_file_flags(%rip), %rdx
    mov $SYS_open, %rax
    syscall
    cmp $0, %rax
    jl .exit_server # some other error. Exit server
    mov %rax, CONF_ACCESS_LOG_FD_OFFSET(%r15)
    lea create_access_log_msg(%rip), %rdi
    mov $create_access_log_len, %rsi
    call log_warn


    # LOG DEFAULT PATHS WARNINGS IF NOT SET
    .validate_access_log_path:
    cmpq $-1, %r12
    jne .validate_error_log_path
    lea .access_log_path_warn_msg(%rip), %rdi
    mov $.access_log_path_warn_msg_len, %rsi
    call log_warn

    .validate_error_log_path:
    cmpq $-1, %r13
    jne .validate_warning_log_path
    lea .error_log_path_warn_msg(%rip), %rdi
    mov $.error_log_path_warn_msg_len, %rsi
    call log_warn

    .validate_warning_log_path:
    cmpq $-1, %r14
    jne .exit_open_log_files
    lea .warning_log_path_warn_msg(%rip), %rdi
    mov $.warning_log_path_warn_msg_len, %rsi
    call log_warn

    .exit_open_log_files:
    pop %r14
    pop %r13
    pop %r12
    pop %rbp
    ret

    .exit_server:
    call exit_program
    