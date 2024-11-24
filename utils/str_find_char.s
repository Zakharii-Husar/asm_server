# Function: str_find_char
# Input: 
#   %rdi - pointer to the string (buffer)
#   %rsi - character to find
# Output: 
#   %rax - address of the character if found or the end of  the string
#   %rdx - search result (1 if char found, 0 if not)

str_find_char:
    push %rbp
    mov %rsp, %rbp

search_char:
    movb (%rdi), %al                  # Load current character from rdi
    cmpb $0, %al                      # Check for null terminator first
    je not_found                      # If null, character not found
    cmpb %sil, %al                    # Compare with sil (8-bit part of rsi) 
    je found_char                     # If equal, character found
    inc %rdi                          # Move to next character using rdi
    jmp search_char                   # Repeat the search

found_char:
    mov $1, %rdx                      # Return 1 if found
    jmp finish_str_find_char

not_found:
    mov $0, %rdx                      # Return 0 if not found

finish_str_find_char:
    mov %rdi, %rax                    # Return address using rdi instead of rsi
    pop %rbp
    ret
    