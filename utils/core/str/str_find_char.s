# str_find_char
# Parameters:
#   %rdi - Address of the string to search
#   %rsi - Character to search for
#   %rdx - Boundary character (0 for unbounded search)
# Returns:
#   %rdx - 1 if character found, 0 if not found
#   %rax - Address of found character or boundary/null character if not found
.section .rodata
str_find_char_null_ptr_msg: .asciz "ERROR: Null pointer passed to str_find_char\n"
str_find_char_null_ptr_msg_len = . - str_find_char_null_ptr_msg

.section .text
.type str_find_char, @function
str_find_char:
    push %rbp
    mov %rsp, %rbp
    sub $8, %rsp               # align stack to 16-byte boundary
    # Add null pointer check
    test %rdi, %rdi
    jz .str_find_char_err

.search_char:
    movb (%rdi), %al           # Load current character
    cmpb $0, %al               # Check for null terminator
    je .not_found
    test %rdx, %rdx            # Check if boundary char is specified
    jz .skip_boundary_check    # If rdx is 0, skip boundary check
    cmpb %dl, %al              # Check for boundary character
    je .not_found
.skip_boundary_check:
    cmpb %sil, %al             # Compare with search character
    je .found_char
    inc %rdi                   # Move to next character
    jmp .search_char

.found_char:
    mov $1, %rdx               # Return 1 if found
    mov %rdi, %rax             # Return address of character
    jmp .finish

.not_found:
    mov $0, %rdx               # Return 0 if not found
    mov %rdi, %rax            # Return address of boundary/null character
    jmp .finish

.str_find_char_err:
    lea str_find_char_null_ptr_msg(%rip), %rdi
    mov $str_find_char_null_ptr_msg_len, %rsi
    call log_err
    xor %rdx, %rdx           # Return 0 (not found)
    xor %rax, %rax           # Return null pointer

.finish:
    leave                     # restore stack frame
    ret
    