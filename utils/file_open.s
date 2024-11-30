
.section .bss
.lcomm stat_buffer, 100

.section .data

file_open_err_msg:    .asciz "\033[31mFile not found! ❌\033[0m\n"
file_open_err_msg_length = . - file_open_err_msg

.section .text

.type file_open, @function
file_open:

    # Parameters:
    # %rdi contains the file path to open
    # %rsi contains the buffer to write into

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

    push %rbp
    mov %rsp, %rbp

    mov %rsi, %r8 # preserve buffer address

    # Open the file using the path in %rdi
    # mov %rdi, %rdi
    mov $SYS_open, %rax                # sys_open
    mov $0, %rsi                       # flags = O_RDONLY
    syscall                            # path is already in %rdi

    # Save file descriptor in %r8
    cmp $0, %rax
    jl .handle_file_open_error        # jump to error handling if failed to open
    mov %rax, %r9                    # save file descriptor in %r8

    # Read file contents into the buffer passed in %rdi
    mov $SYS_read, %rax              # sys_read
    mov %r8, %rsi                    # Use the buffer pointer passed in %rsi > %r9
    mov %r9, %rdi                    # file descriptor
    mov $8192, %rdx                  # max bytes to read
    syscall

    # Get file size using fstat
    mov $SYS_fstat, %rax             # sys_fstat
    mov %r9, %rdi                    # file descriptor
    lea stat_buffer(%rip), %rsi      # address of struct stat
    syscall

    # Check if fstat was successful
    cmp $0, %rax
    jl .handle_file_open_error

    # Get the file size from stat_buffer
    # The reason I need to dereference pointer and store the file size
    # here: even tho subsequent syscall doesn't use rsi,
    # content switchesfrom user mode to kernel mode and overwrites rsi
    # when rsi is pointer, but when system sees that rsi holds some 
    # raw bits it ignores them
    mov 48(%rsi), %rsi  # st_size is usually at offset 40 for 64-bit

    # Close the file descriptor
    mov $SYS_close, %rax            # sys_close
    mov %r9, %rdi                   # file descriptor
    syscall

    cmp $0, %rax
    jl .handle_file_open_error             # jump to error handling if failed to open

    mov %rsi, %rax      # Restore file size to return it
    pop %rbp
    ret



    .handle_file_open_error:
        
        lea file_open_err_msg(%rip), %rdi   
        mov $file_open_err_msg_length, %rsi
        call print_info
        
        mov $-1, %rax
        pop %rbp
        ret
