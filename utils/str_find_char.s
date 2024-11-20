# Function: str_find_char
# Input: 
#   %rsi - pointer to the string (buffer)
#   %rdi - character to find
# Output: 
#   %rax - address of the character if found or the end of  the string
#   %rdx - search result (1 if char found, 0 if not)

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
    mov $1, rdx                       # Return 1 if found
    jmp finish_str_find_char

not_found:
    mov $0, rdx                       # Return 0 if not found

finish_str_find_char:
    mov %rsi, %rax                    # Return the address of the end of the string
    pop %rbp
    ret