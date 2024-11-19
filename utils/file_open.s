# Function: file_open
# Input:
#   %rdi - Null-terminated string containing the requested route/file path
# Output:
#   %rax - Size of the file that was read, or -1 if an error occurred
#   Side effect: Fills response_content_buffer with the file contents
#
# Parameters:
#   - request_route: (global) Null-terminated string containing the requested route/file path
#
# Returns:
#   - %rax: Size of the file that was read, or -1 if an error occurred
#   - Side effect: Fills response_content_buffer with the file contents
#
# Error handling:
#   - Returns -1 in %rax if file cannot be opened or read
#

.section .bss
.lcomm response_content_buffer, 8192  # Allocate 8 KB for the file buffer
.lcomm stat_buffer, 100

.section .data

file_open_err_msg:    .asciz "\033[31mFile not found! ❌\033[0m\n"
file_open_err_msg_length = . - file_open_err_msg

.section .text

.type file_open, @function
file_open:
    push %rbp
    mov %rsp, %rbp
    # %rdi should now contain the file path to open
    # %rsi now contains the buffer to write into

    mov %rsi, %r9 # preserve buffer address

    # Open the file using the path in %rdi
    mov $SYS_open, %rax                # sys_open
    mov $0, %rsi                       # flags = O_RDONLY
    syscall                            # path is already in %rdi

    # Save file descriptor in %r8
    cmp $0, %rax
    jl handle_file_open_error             # jump to error handling if failed to open
    mov %rax, %r8                    # save file descriptor in %r8

    # Read file contents into the buffer passed in %rdi
    mov $SYS_read, %rax              # sys_read
    mov %r9, %rsi                    # Use the buffer pointer passed in %rsi > %r9
    mov %r8, %rdi                    # file descriptor
    mov $8192, %rdx                  # max bytes to read
    syscall

    # Get file size using fstat
    mov $SYS_fstat, %rax             # sys_fstat
    mov %r8, %rdi                    # file descriptor
    lea stat_buffer(%rip), %rsi      # address of struct stat
    syscall

    # Check if fstat was successful
    cmp $0, %rax
    jl handle_file_open_error

    # Get the file size from stat_buffer
    mov 48(%rsi), %r9  # st_size is usually at offset 40 for 64-bit

    # Close the file descriptor
    mov $SYS_close, %rax             # sys_close
    mov %r8, %rdi                   # file descriptor
    syscall

    cmp $0, %rax
    jl handle_file_open_error             # jump to error handling if failed to open

    mov %r9, %rax      # Restore file size to return it
    pop %rbp
    ret



    handle_file_open_error:
        mov %rdi, %rsi                     # Load path for printing (already in %rdi)
        call print_info
        
        lea file_open_err_msg(%rip), %rsi
        mov $file_open_err_msg_length, %rdx
        call print_info
        
        mov $-1, %rax
        pop %rbp
        ret
