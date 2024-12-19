# char_cmp - Compares two characters
# Parameters:
#   %rdi - First character (using lowest byte %dil)
#   %rsi - Second character (using lowest byte %sil)
# Returns:
#   %rax - 1 if characters are equal, 0 if different
.type char_cmp, @function
char_cmp:
    push %rbp
    mov %rsp, %rbp

    # Extract lower bytes from the registers to compare characters
    mov %dil, %al    # First char into al (lower byte of rax)
    cmp %sil, %al    # Compare with second char
    
    # Set return value based on comparison
    je .chars_equal
    mov $0, %rax     # Characters not equal, return 0
    jmp .exit_char_cmp

.chars_equal:
    mov $1, %rax     # Characters equal, return 1

.exit_char_cmp:
    pop %rbp
    ret
    