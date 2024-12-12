.section .data

file_open_err_msg:    .asciz "\033[31mFailed to open file! ❌\033[0m\n"
file_open_err_msg_length = . - file_open_err_msg

fstat_err_msg:    .asciz "\033[31mFailed to get file size! ❌\033[0m\n"
fstat_err_msg_length = . - fstat_err_msg

close_err_msg:    .asciz "\033[31mFailed to close file! ❌\033[0m\n"
close_err_msg_length = . - close_err_msg

read_err_msg:    .asciz "\033[31mFailed to read file! ❌\033[0m\n"
read_err_msg_length = . - read_err_msg

line_break: .asciz "\n"

stat_buffer_size = 100

.section .bss
.lcomm stat_buffer, stat_buffer_size

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
    mov $0, %r9        # Initialize return file size
    mov %rcx, %r12     # save null termination flag
    mov %rdi, %r13     # save file path
    mov %rdx, %r14     # save buffer size

    # 3. CLEAR THE BUFFERS
    lea stat_buffer(%rip), %rdi
    mov $stat_buffer_size, %rsi
    call clear_buffer

    mov %rbx, %rdi     # buffer address
    mov %r14, %rsi     # buffer size
    call clear_buffer
    
    # 4. OPEN THE FILE
    mov %r13, %rdi                     # file path
    mov $SYS_open, %rax                # sys_open
    mov $0, %rsi                       # flags = O_RDONLY
    syscall                            # path is already in %rdi

    mov %rax, %r10                     # file descriptor

    # If negative, it's an error
    cmp $0, %rax
    jl .handle_file_open_error        # jump to error handling if failed to open


    # 5. READ FILE CONTENTS INTO THE BUFFER
    mov $SYS_read, %rax               # sys_read
    mov %rbx, %rsi                    # Use the buffer pointer passed in %rsi > %rbx
    mov %r10, %rdi                    # file descriptor
    mov %r14, %rdx                    # max bytes to read
    syscall

    cmp $0, %rax
    jl .handle_read_error   

    # 6. SAVE BYTES READ TEMPORARILY
    mov %rax, %r9

    # 7. CHECK IF NULL TERMINATION WAS REQUESTED
    cmp $1, %r12
    jne .skip_termination
    
    # 7.1. ENSURE WE HAVE SPACE FOR NULL TERMINATOR
    cmp %r14, %r9              # Compare bytes_read with buffer_size
    jge .handle_buffer_overflow  # If bytes_read >= buffer_size, we can't add null terminator

    # 7.2. ADD NULL TERMINATOR AFTER THE LAST BYTE READ
    mov %rbx, %rdi
    add %r9, %rdi      # Point to byte after last read byte
    movb $0, (%rdi)    # Add null terminator
    
.skip_termination:
    # 8. GET FILE SIZE USING FSTAT
    mov $SYS_fstat, %rax             # sys_fstat
    mov %r10, %rdi                    # file descriptor
    lea stat_buffer(%rip), %rsi      # address of struct stat
    syscall

    # 8.1. CHECK IF FSTAT WAS SUCCESSFUL
    cmp $0, %rax
    jl .handle_fstat_error

    # 8.2. GET THE FILE SIZE FROM STAT_BUFFER
    # The reason I need to dereference pointer and store the file size
    # here: even tho subsequent syscall doesn't use rsi,
    # content switches from user mode to kernel mode and overwrites rsi
    # when rsi is pointer, but when system sees that rsi holds some 
    # raw bits it ignores them
    mov 48(%rsi), %rsi  # st_size is usually at offset 40 for 64-bit
    mov %rsi, %r9 # return file size

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
    jmp .exit_file_open             # jump to error handling if failed to open


   # 10. HANDLE ERRORS
    .handle_file_open_error:
        
        lea file_open_err_msg(%rip), %rdi   
        mov $file_open_err_msg_length, %rsi
        call print_info

        mov $-1, %rax
        jmp .exit_file_open

    .handle_read_error:
        # Close file
        mov $SYS_close, %rax
        mov %r10, %rdi
        syscall
        # Continue with error handling
        lea read_err_msg(%rip), %rdi
        mov $read_err_msg_length, %rsi
        call print_info

        mov $-1, %rax
        jmp .exit_file_open

    .handle_fstat_error:
        lea fstat_err_msg(%rip), %rdi
        mov $fstat_err_msg_length, %rsi
        call print_info 

        mov $-1, %rax
        jmp .exit_file_open

    .handle_close_error:
        lea close_err_msg(%rip), %rdi
        mov $close_err_msg_length, %rsi
        call print_info

        mov $-1, %rax
            

    .handle_buffer_overflow:
        # Handle like other errors
        mov $-1, %rax
        jmp .exit_file_open

    .exit_file_open:
        # Restore registers
        pop %r14
        pop %r13
        pop %r12
        pop %rbx
        pop %rbp
        ret