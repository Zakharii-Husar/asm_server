.section .text
.globl print_info
.type print_info, @function

# Function: print_info
# Input: string pointer in %rsi
# Output: none (prints the string to stdout)
# Note: Internally calculates string length using str_len
print_info:
    push %rbp
    mov %rsp, %rbp
    push %rdi
    push %rsi
    push %rdx
    push %rax   
    
    # Move string pointer to %rdi for str_len
    mov %rsi, %rdi
    call str_len           # str_len will return length in %rax
    
    # Set up parameters for write syscall
    mov %rax, %rdx       # length returned by str_len
    # %rsi already contains string pointer
    mov $SYS_stdout, %rdi          # file descriptor (stdout)
    mov $SYS_write, %rax         # syscall number for write
    syscall
    
    # Restore registers in reverse order
    pop %rax
    pop %rdx
    pop %rsi
    pop %rdi
    pop %rbp

    ret
