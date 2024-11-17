# Function: str_cmp
# Input:
#   %rdi - pointer to the first string
#   %rsi - pointer to the second string
# Output: 
#   %rax - 1 if strings are equal, 0 if not

.section .text

.type str_cmp, @function
str_cmp:
    push %rbp                        # Save the caller's base pointer
    mov %rsp, %rbp                   # Set the new base pointer (stack frame)


   cmp_loop:
    movb (%rsi), %al           # Load byte from string1
    movb (%rdi), %bl           # Load byte from string2
    cmpb %bl, %al              # Compare the characters
    jne strings_not_equal       # Jump if not equal

    testb %al, %al             # Check if we've reached the null terminator
    je strings_equal            # If null terminator, strings are equal

    inc %rsi                    # Move to the next character in string1
    inc %rdi                    # Move to the next character in string2
    jmp cmp_loop            # Repeat the loop

    strings_equal:
    # Code for handling equal strings (e.g., setting a flag)
    mov $1, %rax                # Just an example to indicate success (you can change it)
    jmp end_comparison

    strings_not_equal:
    # Code for handling unequal strings (e.g., setting a different flag)
    mov $0, %rax                # Just an example to indicate failure

    end_comparison:
    pop %rbp                         # Restore the caller's base pointer
    ret                              # Return to the caller with %rdx holding the method length
