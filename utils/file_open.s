.section .bss
.lcomm file_buffer, 8192  # Allocate 8 KB for the file buffer

.section .data
file_open_err_msg:    .asciz "\033[31mFile not found! ❌\033[0m\n"
file_open_err_msg_length = . - file_open_err_msg

file_path: .asciz "./asm_server/public/index.html"
file_path_len = . - file_path

.section .text

# Function to open and read the HTML file
.type file_open, @function
file_open:
    push %rbp
    mov %rsp, %rbp

    # Open the file
    mov $SYS_open, %rax              # sys_open
    lea file_path(%rip), %rdi        # path to the HTML file
    mov $0, %rsi                     # flags = O_RDONLY
    syscall

    # Save file descriptor in %rbx (assumes no register clobbering)
    mov %rax, %rbx                   # save file descriptor in %rbx
    cmp $0, %rbx
    jl handle_file_error             # jump to error handling if failed to open

    # Read file contents into file_buffer
    mov $SYS_read, %rax              # sys_read
    mov %rbx, %rdi                   # file descriptor
    lea file_buffer(%rip), %rsi      # address of file_buffer
    mov $8192, %rdx                  # max bytes to read
    syscall

    # Save the number of bytes read (in %rax) in a variable
    mov %rax, %rcx                   # store number of bytes read in %rcx for later

    # Close the file descriptor
    mov $SYS_close, %rax             # sys_close
    mov %rbx, %rdi                   # file descriptor
    syscall

    pop %rbp
    ret

    handle_file_error:
     lea file_open_err_msg(%rip), %rsi      # pointer to the message (from constants.s)
     mov $file_open_err_msg_length, %rdx    # length of the message (from constants.s)
     call print_info
     call exit_program
