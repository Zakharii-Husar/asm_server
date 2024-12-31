.section .rodata

.print_info_error_msg: .asciz "MODERATE: failed to print info in print_info.s"
.print_info_error_msg_length = . - .print_info_error_msg

.section .text
.globl print_info
.type print_info, @function

# Function: print_info
# Input: 
# - %rdi string pointer
# - %rsi string length (if known or 0 if unknown)
# Output: none (prints the string to stdout)
# Note: Internally calculates string length using str_len
print_info:
    push %rbp
    mov %rsp, %rbp 
    push %r12

    mov %rdi, %r12 # save string pointer
    mov %rsi, %rdx # save string length
    test %rdx, %rdx
    jnz .write_to_stdout

    # Calculate string length if unknown
    call str_len               # %rdi already contains the string pointer, so str_len will return length in %rax
    mov %rax, %rdx             # length returned by str_len

    .write_to_stdout:
    # Set up parameters for write syscall
    # rdx already contains the string length
    mov %r12, %rsi           # prepare rsi for string pointer during syscall
    mov $SYS_stdout, %rdi      # file descriptor (stdout)
    mov $SYS_write, %rax       # syscall number for write
    syscall

    pop %r12
    pop %rbp
    ret
