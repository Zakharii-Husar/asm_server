.section .data
log_file_flags: .long 0644                    # File permissions (rw-r--r--)
log_open_file_mode:  .long 02102                   # O_APPEND | O_CREAT | O_WRONLY
log_create_file_mode: .long 02502                  # O_APPEND | O_CREAT | O_EXCL | O_WRONLY

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

    # SAVE LOG FILES INITIAL STATE (-1 OR PATHS)
    lea CONF_WARNING_LOG_PATH_OFFSET(%r15), %r8
    lea CONF_ERROR_LOG_PATH_OFFSET(%r15), %r9
    lea CONF_ACCESS_LOG_PATH_OFFSET(%r15), %r10
    
    # CHECK IF LOGS FILE PATHS ARE SET, IF NOT SET THEM TO DEFAULT
    cmp $-1, CONF_WARNING_LOG_PATH_OFFSET(%r15)
    jne .check_error_log
    lea .default_warning_log(%rip), %rdi
    mov %rdi, CONF_WARNING_LOG_PATH_OFFSET(%r15)

.check_error_log:
    cmp $-1, CONF_ERROR_LOG_PATH_OFFSET(%r15)
    jne .check_access_log
    lea .default_error_log(%rip), %rdi
    mov %rdi, CONF_ERROR_LOG_PATH_OFFSET(%r15)

.check_access_log:
    cmp $-1, CONF_ACCESS_LOG_PATH_OFFSET(%r15)
    jne .continue_opening_files
    lea .default_access_log(%rip), %rdi
    mov %rdi, CONF_ACCESS_LOG_PATH_OFFSET(%r15)

.continue_opening_files:
    
    # TRY TO CREATE WARNING LOG FILE IF IT DOESN'T EXIST
    lea CONF_WARNING_LOG_PATH_OFFSET(%r15), %rdi
    mov log_file_flags(%rip), %rdx
    mov log_create_file_mode(%rip), %rsi
    mov $SYS_open, %rax
    syscall
    cmp $-17, %rax
    je .open_warning_log # file already exists, open it
    cmp $0, %rax
    jl .exit_server # some other error. Exit server
    # SAVE NEW WARNING LOG FILE DESCRIPTOR
    mov %rax, CONF_WARNING_LOG_FD_OFFSET(%r15)
    # LOG CREATION OF WARNING LOG FILE
    lea create_warning_log_msg(%rip), %rdi
    mov $create_warning_log_len, %rsi
    call log_warn
    jmp .create_error_log

    # OPEN EXISTING WARNING LOG FILE
    .open_warning_log:
    lea CONF_WARNING_LOG_PATH_OFFSET(%r15), %rdi
    mov log_file_flags(%rip), %rdx
    mov log_open_file_mode(%rip), %rsi
    mov $SYS_open, %rax
    syscall
    cmp $0, %rax
    jl .exit_server # some other error. Exit server
    mov %rax, CONF_WARNING_LOG_FD_OFFSET(%r15)

    # TRY TO CREATE ERROR LOG FILE IF IT DOESN'T EXIST
    .create_error_log:
    lea CONF_ERROR_LOG_PATH_OFFSET(%r15), %rdi
    mov log_file_flags(%rip), %rdx
    mov log_create_file_mode(%rip), %rsi
    mov $SYS_open, %rax
    syscall
    cmp $-17, %rax
    je .open_error_log # file already exists, open it
    cmp $0, %rax
    jl .exit_server # some other error. Exit server
    # SAVE NEW ERROR LOG FILE DESCRIPTOR
    mov %rax, CONF_ERROR_LOG_FD_OFFSET(%r15)
    # LOG CREATION OF ERROR LOG FILE
    lea create_error_log_msg(%rip), %rdi
    mov $create_error_log_len, %rsi
    call log_warn   
    jmp .create_access_log

    # OPEN EXISTING ERROR LOG FILE
    .open_error_log:
    lea CONF_ERROR_LOG_PATH_OFFSET(%r15), %rdi
    mov log_file_flags(%rip), %rdx
    mov log_open_file_mode(%rip), %rsi
    mov $SYS_open, %rax
    syscall
    cmp $0, %rax
    jl .exit_server # some other error. Exit server
    mov %rax, CONF_ERROR_LOG_FD_OFFSET(%r15)

    # TRY TO CREATE ACCESS LOG FILE IF IT DOESN'T EXIST
    .create_access_log:
    lea CONF_ACCESS_LOG_PATH_OFFSET(%r15), %rdi
    mov log_file_flags(%rip), %rdx
    mov log_create_file_mode(%rip), %rsi
    mov $SYS_open, %rax
    syscall
    cmp $-17, %rax
    je .open_access_log # file already exists, open it
    cmp $0, %rax
    jl .exit_server # some other error. Exit server
    # SAVE NEW ACCESS LOG FILE DESCRIPTOR
    mov %rax, CONF_ACCESS_LOG_FD_OFFSET(%r15)
    # LOG CREATION OF ACCESS LOG FILE
    lea create_access_log_msg(%rip), %rdi
    mov $create_access_log_len, %rsi
    call log_warn
    jmp .log_default_paths_warnings

    # OPEN EXISTING ACCESS LOG FILE
    .open_access_log:
    lea CONF_ACCESS_LOG_PATH_OFFSET(%r15), %rdi
    mov log_file_flags(%rip), %rdx
    mov log_open_file_mode(%rip), %rsi
    mov $SYS_open, %rax
    syscall
    cmp $0, %rax
    jl .exit_server # some other error. Exit server
    mov %rax, CONF_ACCESS_LOG_FD_OFFSET(%r15)

    .log_default_paths_warnings:
    cmp $-1, %r8
    jne .validate_error_log_path
    lea .access_log_path_warn_msg(%rip), %rdi
    mov $access_log_path_warn_msg_len, %rsi
    call log_warn

    .validate_error_log_path
    cmp $-1, %r9
    jne .validate_warning_log_path
    lea .error_log_path_warn_msg(%rip), %rdi
    mov $error_log_path_warn_msg_len, %rsi
    call log_warn

    .validate_warning_log_path:
    cmp $-1, %r10
    jne .exit_open_log_files
    lea .warning_log_path_warn_msg(%rip), %rdi
    mov $warning_log_path_warn_msg_len, %rsi
    call log_warn

    .exit_open_log_files:
    pop %rbp
    ret

    .exit_server:
    mov %rax, %rdi
    call int_to_str
    mov %rax, %rdi
    xor %rsi, %rsi
    call print_info
    call exit_program
    