.section .text
.globl print_info
.type print_info, @function

# Function: print_info
# Input: string pointer in %rsi
# Output: none
# Note: Internally calculates string length using str_len
print_info:
    push %rbp
    mov %rsp, %rbp
    
    # Save registers we'll modify
    push %rdi
    push %rsi
    push %rdx
    
    # Move string pointer to %rdi for str_len
    mov %rsi, %rdi
    call str_len           # str_len will return length in %rax
    
    # Set up parameters for write syscall
    mov $1, %rdi          # file descriptor (stdout)
    # %rsi already contains string pointer
    mov %rax, %rdx       # length returned by str_len
    mov $1, %rax         # syscall number for write
    syscall
    
    # Restore registers
    pop %rdx
    pop %rsi
    pop %rdi
    
    pop %rbp
    ret
