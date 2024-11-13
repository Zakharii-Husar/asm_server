.section .text
.globl str_len
.type str_len, @function

# Function: str_len
# Input: string pointer in %rdi
# Output: length in %rax
str_len:
    push %rbp
    mov %rsp, %rbp
    
    xor %rax, %rax           # Initialize counter to 0
    
strlen_loop:
    cmpb $0, (%rdi)          # Compare byte at address in %rdi with 0 (null terminator)
    je strlen_done           # If equal (found null), we're done
    inc %rax                 # Increment counter
    inc %rdi                 # Move to next character
    jmp strlen_loop          # Repeat

strlen_done:
    pop %rbp
    ret 
    