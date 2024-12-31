.section .text
.globl str_len
.type str_len, @function
str_len:
# Function: str_len
# Input: string pointer in %rdi
# Output: length in %rax
    push %rbp
    mov %rsp, %rbp
    sub $8, %rsp              # align stack to 16-byte boundary
    xor %rax, %rax           # Initialize counter to 0
    
.str_len_loop:
    cmpb $0, (%rdi)          # Compare byte at address in %rdi with 0 (null terminator)
    je .done                 # If equal (found null), we're done
    inc %rax                 # Increment counter
    inc %rdi                 # Move to next character
    jmp .str_len_loop                # Repeat

.done:
    leave                     # restore stack frame
    ret 
    