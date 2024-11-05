.section .bss
.lcomm response_content_buffer, 8192  # Allocate 8 KB for the file buffer
.lcomm stat_buffer, 100
.lcomm full_path_buffer, 2048                # New buffer for combined path

.section .data
base_path: .asciz "./asm_server/public"    # Base path constant
html_ext: .asciz ".html"    # Add this line to define the HTML extension

file_open_err_msg:    .asciz "\033[31mFile not found! ❌\033[0m\n"
file_open_err_msg_length = . - file_open_err_msg

.section .text

# Function to open and read the HTML file

.type file_open, @function
file_open:
    push %rbp
    mov %rsp, %rbp

    # Combine paths - using request_route instead of %r12
    lea full_path_buffer(%rip), %rdi    # Destination buffer
    lea base_path(%rip), %rsi    # Source (base path)

copy_base:                       # Copy base path first
    movb (%rsi), %al
    movb %al, (%rdi)
    inc %rsi
    inc %rdi
    cmpb $0, %al
    jne copy_base

    dec %rdi                     # Move back one to overwrite null terminator
    lea request_route(%rip), %rsi  # Source (request route) - CHANGED THIS LINE

copy_req_route:                      # Append request route
    movb (%rsi), %al
    movb %al, (%rdi)
    inc %rsi
    inc %rdi
    cmpb $0, %al
    jne copy_req_route

    # Check if route has extension (using %r8 from extract_route)
    cmp $1, %r8
    je count_route_length    # If has extension, skip appending .html

    # No extension, append .html
    dec %rdi                     # Add this line to move back one to overwrite null terminator
    lea html_ext(%rip), %rsi    # Source (.html extension)
append_ext:
    movb (%rsi), %al
    movb %al, (%rdi)
    inc %rsi
    inc %rdi
    cmpb $0, %al
    jne append_ext

    # Continue with length counting
count_route_length:
    # After copy_req_route, calculate string length using str_len
    lea full_path_buffer(%rip), %rdi    # Load address of string into first parameter
    call str_len                        # Call str_len function
    mov %rax, %rdx                      # Move returned length to %rdx for print_info
    
    # Debug print with actual length
    lea full_path_buffer(%rip), %rsi    # pointer to full path
    call print_info

    # Now open the file using the combined path
    mov $SYS_open, %rax         # sys_open
    lea full_path_buffer(%rip), %rdi   # Load combined path
    mov $0, %rsi                       # flags = O_RDONLY
    syscall

    # Save file descriptor in %r8
    cmp $0, %rax
    jl handle_file_error             # jump to error handling if failed to open
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
    jl handle_file_error

    # Get the file size from stat_buffer
     mov 48(%rsi), %r9  # st_size is usually at offset 40 for 64-bit


    # Close the file descriptor
    mov $SYS_close, %rax             # sys_close
    mov %r8, %rdi                   # file descriptor
    syscall

    cmp $0, %rax
    jl handle_file_error             # jump to error handling if failed to open

    pop %rbp
    ret



    handle_file_error:
     lea file_open_err_msg(%rip), %rsi      # pointer to the message (from constants.s)
     mov $file_open_err_msg_length, %rdx    # length of the message (from constants.s)
     call print_info
     call exit_program
