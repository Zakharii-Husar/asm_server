.section .data

test_msg: .asciz "test"
test_msg_length = . - test_msg

fstat_err_msg:    .asciz "CRITICAL: failed to get fstat in file_open.s"
fstat_err_msg_length = . - fstat_err_msg

close_err_msg:    .asciz "CRITICAL: failed to close file in file_open.s"
close_err_msg_length = . - close_err_msg

read_err_msg:    .asciz "CRITICAL: failed to read file in file_open.s"
read_err_msg_length = . - read_err_msg

buffer_overflow_err_msg: .asciz "CRITICAL: buffer overflow in file_open.s"
buffer_overflow_err_msg_length = . - buffer_overflow_err_msg

directory_traversal_err_msg: .asciz "CRITICAL: directory traversal in file_open.s "
directory_traversal_err_msg_length = . - directory_traversal_err_msg

.equ stat_buffer_size, 144

.equ traversal_error_B_size, 1024

.section .bss
.lcomm stat_buffer, stat_buffer_size
.lcomm traversal_error_B, traversal_error_B_size


.section .text

.type file_open, @function
file_open:

    # Parameters:
    # %rdi contains the file path to open
    # %rsi contains the buffer to write into
    # %rdx contains the buffer size
    # %rcx contains null termination flag (1 = terminate, 0 = don't terminate)

    # Return value:
    # %rax on success returns file size

    # Error handling:
    # %rax returns -1

    # Side effects:
    # The file gets written to the buffer passed in %rsi on success  
    
    # Usage Example:
    # lea file_path(%rip), %rdi
    # lea file_buffer(%rip), %rsi
    # call file_open


    # 1. SAVE REGISTERS
    push %rbp
    mov %rsp, %rbp
    
    push %rbx
    push %r12
    push %r13
    push %r14

    # 2. SAVE PARAMETERS
    mov %rsi, %rbx      # response buffer
    mov %rcx, %r12     # save null termination flag
    mov %rdi, %r13     # save file path
    mov %rdx, %r14     # save buffer size

    # file path is already in %rdi
    call validate_file_path
    cmp $0, %rax
    je .handle_directory_traversal

    # 3. CLEAR THE BUFFERS
    lea stat_buffer(%rip), %rdi
    mov $stat_buffer_size, %rsi
    call clear_buffer

    mov %rbx, %rdi     # buffer address
    mov %r14, %rsi     # buffer size
    call clear_buffer
    
    # 4. OPEN THE FILE
    mov $0, %r9                        # Initialize return file size
    mov %r13, %rdi                     # file path
    mov $SYS_open, %rax                # sys_open
    mov $0, %rsi                       # flags = O_RDONLY
    syscall                            # path is already in %rdi

    mov %rax, %r10                     # file descriptor

    # If negative, it's an error
    cmp $0, %rax
    jl .handle_file_open_error        # jump to error handling if failed to open


    # 5. GET FILE SIZE USING FSTAT BEFORE READING
    mov $SYS_fstat, %rax             # sys_fstat
    mov %r10, %rdi                    # file descriptor
    lea stat_buffer(%rip), %rsi      # address of struct stat
    syscall

    # 5.1. CHECK IF FSTAT WAS SUCCESSFUL
    cmp $0, %rax
    jl .handle_fstat_error

    # 5.2. GET THE FILE SIZE AND CHECK BUFFER CAPACITY
    mov 48(%rsi), %rsi               # get st_size
    mov %rsi, %r9                    # save file size for later

    # Check if buffer can hold file contents + potential null terminator
    mov %r12, %rax                   # get null termination flag
    add %r9, %rax                    # add file size + 1 if null termination requested
    cmp %r14, %rax                   # compare with buffer size
    jg .handle_buffer_overflow       # if greater, buffer would overflow

    # 6. READ FILE CONTENTS INTO BUFFER
    mov $SYS_read, %rax              # sys_read
    mov %rbx, %rsi                   # Use the buffer pointer
    mov %r10, %rdi                   # file descriptor
    mov %r14, %rdx                   # max bytes to read
    syscall

    cmp $0, %rax
    jl .handle_read_error   

    # 7. SAVE BYTES READ TEMPORARILY
    mov %rax, %r9

    # 8. CHECK IF NULL TERMINATION WAS REQUESTED
    cmp $1, %r12
    jne .skip_termination
    
    # 8.1. ADD NULL TERMINATOR AFTER THE LAST BYTE READ
    mov %rbx, %rdi
    add %r9, %rdi      # Point to byte after last read byte
    movb $0, (%rdi)    # Add null terminator
    
.skip_termination:
    # 9. CLOSE THE FILE DESCRIPTOR
    mov $SYS_close, %rax            # sys_close
    mov %r10, %rdi                   # file descriptor
    syscall

    cmp $0, %rax
    jl .handle_close_error
    
    mov %r9, %rax # return file size
    # 9.1. CHECK IF WE NEED TO INCLUDE NULL TERMINATOR IN RETURNED SIZE & RETURN
    cmp $1, %r12
    jne .exit_file_open
    inc %rax                        # Include null terminator in size if requested
    .exit_file_open:
        pop %r14
        pop %r13
        pop %r12
        pop %rbx
        leave                # restore stack frame (mov %rbp, %rsp; pop %rbp)
        ret
        
    # HANDLE ERRORS
    .handle_file_open_error:
    # no need to log error here, because there are 2 scenarios:
    # 1. config file failed to open, then it's not gonna have any file to log the error to
    # 2. 404 has a fallback and will log event with log_access

    mov $-1, %rax
    jmp .exit_file_open

    .handle_read_error:
        mov %rax, %r8 # save error code
        # Close file
        mov $SYS_close, %rax
        mov %r10, %rdi
        syscall
        
        lea read_err_msg(%rip), %rdi
        mov $read_err_msg_length, %rsi
        mov %r8, %rdx
        call log_err

        mov $-1, %rax
        jmp .exit_file_open

    .handle_fstat_error:
            # Close file
        mov $SYS_close, %rax
        mov %r10, %rdi
        syscall

        lea fstat_err_msg(%rip), %rdi
        mov $fstat_err_msg_length, %rsi
        mov %rax, %rdx
        call log_err

        mov $-1, %rax
        jmp .exit_file_open

    .handle_close_error:
            # Close file
        mov $SYS_close, %rax
        mov %r10, %rdi
        syscall

        lea close_err_msg(%rip), %rdi
        mov $close_err_msg_length, %rsi
        mov %rax, %rdx
        call log_err


        mov $-1, %rax
        jmp .exit_file_open
        .handle_buffer_overflow:
        mov $SYS_close, %rax
        mov %r10, %rdi
        syscall

        lea buffer_overflow_err_msg(%rip), %rdi
        mov $buffer_overflow_err_msg_length, %rsi
        mov %rax, %rdx
        call log_err

        mov $-1, %rax
        jmp .exit_file_open 

        .handle_directory_traversal:
        # Check if IP is set
        mov %r14, %rdi
        call str_len
        mov %r14, %rdi
        xor %rsi, %rsi
        call print_info

        test %r14, %r14
        jz .skip_logging_ip
        
        # add error message to buffer
        lea traversal_error_B(%rip), %rdi
        lea directory_traversal_err_msg(%rip), %rsi
        mov $directory_traversal_err_msg_length, %rdx
        mov $traversal_error_B_size, %rcx
        call str_cat
        # find length of IP
        mov %r14, %rdi
        call str_len
        # add IP to error message
        lea traversal_error_B(%rip), %rdi
        mov %r14, %rsi
        mov %rax, %rdx
        mov $traversal_error_B_size, %rcx
        call str_cat

        # Find length of error message
        lea traversal_error_B(%rip), %rdi
        call str_len
        # log error
        lea traversal_error_B(%rip), %rdi
        mov %rax, %rsi
        xor %rdx, %rdx
        call log_err


        .skip_logging_ip:
        lea directory_traversal_err_msg(%rip), %rdi
        mov $directory_traversal_err_msg_length, %rsi
        mov $-2, %rdx
        call log_err

        mov $-1, %rax
        jmp .exit_file_open  
