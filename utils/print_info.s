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

    mov %rsi, %rdx           # prepare rdx for string length  during  syscall
    mov %rdi, %rsi           # prepare rsi for string pointer during syscall
    test %rdx, %rdx
    jnz .write_to_stdout

    # Calculate string length if unknown
    push %rsi                  # preserve string pointer
    call str_len               # %rdi already contains the string pointer, so str_len will return length in %rax
    mov %rax, %rdx             # length returned by str_len
    pop %rsi                   # restore string pointer

    .write_to_stdout:
    # Set up parameters for write syscall
    # rdx already contains the string length
    # rsi already contains the string pointer
    mov $SYS_stdout, %rdi      # file descriptor (stdout)
    mov $SYS_write, %rax       # syscall number for write
    syscall
    
    pop %rbp
    ret
