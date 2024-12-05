# str_find_char
# Parameters:
#   %rdi - Address of the string to search
#   %rsi - Character to search for
#   %rdx - Boundary character (0 for unbounded search)
# Returns:
#   %rdx - 1 if character found, 0 if not found
#   %rax - Address of found character or boundary/null

str_find_char:
    push %rbp
    mov %rsp, %rbp

.search_char:
    movb (%rdi), %al           # Load current character
    cmpb $0, %al               # Check for null terminator
    je .not_found
    test %rdx, %rdx            # Check if boundary char is specified
    jz .skip_boundary_check    # If rdx is 0, skip boundary check
    cmpb %dl, %al              # Check for boundary character (using dl for byte comparison)
    je .not_found
.skip_boundary_check:
    cmpb %sil, %al             # Compare with search character (using sil for byte comparison)
    je .found_char
    inc %rdi                   # Move to next character
    jmp .search_char

.found_char:
    mov $1, %rdx               # Return 1 if found
    jmp .finish_str_find_char

.not_found:
    mov $0, %rdx               # Return 0 if not found

.finish_str_find_char:
    mov %rdi, %rax            # Return address of character or terminator
    pop %rbp
    ret
