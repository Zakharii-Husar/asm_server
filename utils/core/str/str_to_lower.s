.section .text
.globl str_to_lower
.type str_to_lower, @function
str_to_lower:
# Function: str_to_lower
# Input: string pointer in %rdi
# Output: none (modifies string in place)
    push %rbp
    mov %rsp, %rbp
    push %rdi              # Save original string pointer
    
.to_lower_loop:
    movb (%rdi), %al       # Load current character into %al
    cmpb $0, %al           # Check for null terminator
    je .to_lower_done      # If null terminator, we're done
    
    cmpb $'A', %al         # Compare with 'A'
    jb .next_char          # If below 'A', skip
    cmpb $'Z', %al         # Compare with 'Z'
    ja .next_char          # If above 'Z', skip
    
    addb $32, %al          # Convert to lowercase by adding 32
    movb %al, (%rdi)       # Store converted character back
    
.next_char:
    inc %rdi               # Move to next character
    jmp .to_lower_loop     # Repeat for next character

.to_lower_done:
    pop %rdi               # Restore original string pointer
    leave                  # restore stack frame
    ret 
    