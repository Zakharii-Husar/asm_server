# Function: str_find_char
# Input: 
#   %rsi - pointer to the string (buffer)
#   %rdi - character to find
# Output: 
#   %rax - address of the character or -1 if not found

str_find_char:
    push %rbp
    mov %rsp, %rbp

search_char:
    movb (%rsi), %al                  # Load current character into al
    cmpb $0, %al                      # Check for null terminator first
    je not_found                      # If null, character not found
    cmpb %dil, %al                    # Compare with the character to find
    je found_char                     # If equal, character found
    inc %rsi                          # Move to the next character
    jmp search_char                   # Repeat the search

found_char:
    mov %rsi, %rax                    # Return the address of the found character
    pop %rbp
    ret

not_found:
    mov $-1, %rax                     # Return -1 if not found
    pop %rbp
    ret