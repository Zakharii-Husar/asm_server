# Function: str_cmp
# Input:
#   %rdi - pointer to the first string
#   %rsi - pointer to the second string
# Output: 
#   %rax - 1 if strings are equal, 0 if not

.section .rodata
null_ptr_msg: .asciz "MODERATE: Null pointer passed to str_cmp in str_cmp.s"
null_ptr_msg_len = . - null_ptr_msg

.section .text
.type str_cmp, @function
str_cmp:
    push %rbp                   # Save the caller's base pointer
    mov %rsp, %rbp              # Set the new base pointer (stack frame)

    # Add null pointer checks
    test %rdi, %rdi
    jz .null_error
    test %rsi, %rsi
    jz .null_error

   .cmp_loop:
    movb (%rsi), %al            # Load byte from string1
    movb (%rdi), %bl            # Load byte from string2
    cmpb %bl, %al               # Compare the characters
    jne .strings_not_equal      # Jump if not equal

    testb %al, %al               # Check if we've reached the null terminator
    je .strings_equal            # If null terminator, strings are equal

    inc %rsi                     # Move to the next character in string1
    inc %rdi                     # Move to the next character in string2
    jmp .cmp_loop                # Repeat the loop

    .strings_equal:
    mov $1, %rax
    jmp .end_comparison

    .strings_not_equal:
    mov $0, %rax
    jmp .end_comparison

    .null_error:
    lea null_ptr_msg(%rip), %rdi
    mov $null_ptr_msg_len, %rsi
    call log_err
    mov $0, %rax               # Return 0 on error

    .end_comparison:
    pop %rbp                         # Restore the caller's base pointer
    ret                              # Return to the caller with %rdx holding the method length
