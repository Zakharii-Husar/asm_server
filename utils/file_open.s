.section .bss
.lcomm stat_buffer, 100

.section .data

file_open_err_msg:    .asciz "\033[31mFailed to open file! ❌\033[0m\n"
file_open_err_msg_length = . - file_open_err_msg

fstat_err_msg:    .asciz "\033[31mFailed to get file size! ❌\033[0m\n"
fstat_err_msg_length = . - fstat_err_msg

close_err_msg:    .asciz "\033[31mFailed to close file! ❌\033[0m\n"
close_err_msg_length = . - close_err_msg

read_err_msg:    .asciz "\033[31mFailed to read file! ❌\033[0m\n"
read_err_msg_length = . - read_err_msg

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

    push %r12
    push %r13
    push %r14
    push %r15
    mov %rdi, %r12 # file path buffer
    mov %rsi, %r13 # response buffer
    mov $0, %r15 # Initialize return file size
    
    # Open the file using the path in %rdi
    mov %r12, %rdi
    mov $SYS_open, %rax                # sys_open
    mov $0, %rsi                       # flags = O_RDONLY
    syscall                            # path is already in %rdi

    mov %rax, %r14 # file descriptor

    # If negative, it's an error
    cmp $0, %rax
    jl .handle_file_open_error        # jump to error handling if failed to open


    # Read file contents into the buffer passed in %rdi
    mov $SYS_read, %rax              # sys_read
    mov %r13, %rsi                    # Use the buffer pointer passed in %rsi > %r9
    mov %r14, %rdi                    # file descriptor
    mov $response_content_B_size, %rdx                  # max bytes to read
    syscall

    cmp $0, %rax
    jl .handle_read_error   

    # Get file size using fstat
    mov $SYS_fstat, %rax             # sys_fstat
    mov %r14, %rdi                    # file descriptor
    lea stat_buffer(%rip), %rsi      # address of struct stat
    syscall

    # Check if fstat was successful
    cmp $0, %rax
    jl .handle_fstat_error

    # Get the file size from stat_buffer
    # The reason I need to dereference pointer and store the file size
    # here: even tho subsequent syscall doesn't use rsi,
    # content switches from user mode to kernel mode and overwrites rsi
    # when rsi is pointer, but when system sees that rsi holds some 
    # raw bits it ignores them
    mov 48(%rsi), %rsi  # st_size is usually at offset 40 for 64-bit
    mov %rsi, %r15 # return file size

    # Close the file descriptor
    mov $SYS_close, %rax            # sys_close
    mov %r14, %rdi                   # file descriptor
    syscall

    cmp $0, %rax
    jl .handle_close_error
    mov %r15, %rax
    jge .exit_file_open             # jump to error handling if failed to open



    .handle_file_open_error:
        
        lea file_open_err_msg(%rip), %rdi   
        mov $file_open_err_msg_length, %rsi
        call print_info

        mov $-1, %rax
        jmp .exit_file_open

    .handle_read_error:
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
            

    .exit_file_open:
        pop %r15
        pop %r14
        pop %r13
        pop %r12
        pop %rbp
        ret
