str_find_char:
    push %rbp
    mov %rsp, %rbp

.search_char:
    movb (%rdi), %al                  # Load current character from rdi
    movb %sil, %dl                    # Load search character into dl
    cmpb $0, %al                      # Check for null terminator
    je .not_found                     # If null, character not found
    cmpb %dl, %al                     # Compare the characters
    je .found_char                    # If equal, character found
    inc %rdi                          # Move to next character
    jmp .search_char                  # Repeat the search

.found_char:
    mov $1, %rdx                      # Return 1 if found
    jmp .finish_str_find_char

.not_found:
    mov $0, %rdx                      # Return 0 if not found

.finish_str_find_char:
    mov %rdi, %rax                    # Return address of the character or null terminator
    pop %rbp
    ret
