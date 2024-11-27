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
    
    # Move string pointer to %rdi for str_len
    mov %rsi, %rdi
    # preserve string pointer
    push %rsi
    call str_len               # str_len will return length in %rax
    
    # Set up parameters for write syscall
    mov %rax, %rdx             # length returned by str_len
    pop %rsi                   # restore string pointer
    mov $SYS_stdout, %rdi      # file descriptor (stdout)
    mov $SYS_write, %rax       # syscall number for write
    syscall
    
    pop %rbp
    ret
