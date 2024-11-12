.section .bss
.lcomm response_content_buffer, 8192  # Allocate 8 KB for the file buffer
.lcomm stat_buffer, 100
.lcomm full_path_buffer, 2048                # New buffer for combined path

.section .data
base_path: .asciz "./asm_server/public"    # Base path constant

file_open_err_msg:    .asciz "\033[31mFile not found! ❌\033[0m\n"
file_open_err_msg_length = . - file_open_err_msg

.section .text

# Function to open and read the HTML file

.type file_open, @function
file_open:
    push %rbp
    mov %rsp, %rbp

    # Combine base path with request route
    lea full_path_buffer(%rip), %rdi    # Destination buffer
    lea base_path(%rip), %rsi           # Source (base path)
    xor %rdx, %rdx                      # Let str_concat calculate length
    call str_concat

    # Append request route
    lea full_path_buffer(%rip), %rdi    # Destination buffer
    lea request_route(%rip), %rsi       # Source (request route)
    xor %rdx, %rdx                      # Let str_concat calculate length
    call str_concat

    # Now open the file using the combined path
    mov $SYS_open, %rax                # sys_open
    lea full_path_buffer(%rip), %rdi   # Load combined path
    mov $0, %rsi                       # flags = O_RDONLY
    syscall

    # Save file descriptor in %r8
    cmp $0, %rax
    jl handle_file_open_error             # jump to error handling if failed to open
    mov %rax, %r8                    # save file descriptor in %r8

    # Read file contents into response_content_buffer
    mov $SYS_read, %rax              # sys_read
    mov %r8, %rdi                    # file descriptor
    lea response_content_buffer(%rip), %rsi      # address of response_content_buffer
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
     lea file_open_err_msg(%rip), %rsi      # pointer to the message (from constants.s)
     mov $file_open_err_msg_length, %rdx    # length of the message (from constants.s)
     call print_info
     call exit_program
