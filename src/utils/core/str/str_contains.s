.section .text
.globl str_contains
.type str_contains, @function
str_contains:
    # Parameters:
    # %rdi - pointer to the main string
    # %rsi - pointer to the substring to find
    
    # Return:
    # %rax - 1 if substring is found, 0 if not
    
    push %rbp
    mov %rsp, %rbp
    sub $8, %rsp

    push %rbx
    push %r12
    push %r13
    
    mov %rdi, %r12          # Save main string pointer
    mov %rsi, %r13          # Save substring pointer
    
.outer_loop:
    movb (%r12), %al        # Load current char from main string
    test %al, %al          # Check if we reached end of main string
    jz .substring_not_found
    
    mov %r12, %rbx         # Current position in main string
    mov %r13, %rsi         # Reset substring pointer
    
.inner_loop:
    movb (%rsi), %al       # Load char from substring
    test %al, %al          # Check if we reached end of substring
    jz .found              # If we reached end of substring, we found a match
    
    movb (%rbx), %dl       # Load char from current main string position
    test %dl, %dl          # Check if we reached end of main string
    jz .substring_not_found
    
    cmp %al, %dl           # Compare characters
    jne .next_outer        # If not equal, break inner loop
    
    inc %rbx              # Move to next char in main string
    inc %rsi              # Move to next char in substring
    jmp .inner_loop
        
.next_outer:
    inc %r12              # Move to next position in main string
    jmp .outer_loop
    
.found:
    mov $1, %rax
    jmp .exit_str_contains
    
.substring_not_found:
    mov $0, %rax
    
.exit_str_contains:
    pop %r13
    pop %r12
    pop %rbx
    add $8, %rsp
    pop %rbp
    ret
