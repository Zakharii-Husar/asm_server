.section .rodata
invalid_digit_msg: .asciz "ERROR: Invalid character in number string in str_to_int.s"
invalid_digit_msg_len = . - invalid_digit_msg

.section .text
.globl str_to_int
.type str_to_int, @function
str_to_int:
# Function: str_to_int
# Input: %rdi - pointer to the string
# Output: %rax - integer value

    push %rbp
    mov %rsp, %rbp
    push %rbx
    xor %rax, %rax          # Clear rax for result
    xor %rcx, %rcx          # Clear rcx for sign (0 = positive, 1 = negative)

    # Check for empty string
    movb (%rdi), %al
    cmpb $0, %al
    je .invalid_input

    # Check for signs
    cmpb $'-', %al
    je .handle_negative
    cmpb $'+', %al
    je .handle_positive
    
    # If no sign, validate first char is digit
    cmpb $'0', %al
    jb .invalid_input
    cmpb $'9', %al
    ja .invalid_input
    jmp .parse_digits       # No sign, start parsing immediately

.handle_negative:
    inc %rdi                # Move past the negative sign
    inc %rcx                # Set sign to negative
    # Validate next char after sign
    movb (%rdi), %al
    cmpb $0, %al           # Check if string ends after sign
    je .invalid_input
    jmp .validate_digit

.handle_positive:
    inc %rdi                # Move past the positive sign
    # Validate next char after sign
    movb (%rdi), %al
    cmpb $0, %al           # Check if string ends after sign
    je .invalid_input
    
.validate_digit:
    cmpb $'0', %al
    jb .invalid_input
    cmpb $'9', %al
    ja .invalid_input
    
.parse_digits:
    xor %rax, %rax          # Clear rax for result
    mov $10, %rbx           # Base 10 for conversion

.convert_loop:
    movb (%rdi), %dl        # Load next character
    cmpb $0, %dl            # Check for null terminator
    je .apply_sign
    
    # Validate current digit
    cmpb $'0', %dl
    jb .invalid_input
    cmpb $'9', %dl
    ja .invalid_input
    
    subb $'0', %dl          # Convert ASCII to integer
    imul $10, %rax          # Multiply accumulated result by 10
    movzx %dl, %rdx         # Convert the single digit to 64-bit
    add %rdx, %rax          # Add the new digit
    inc %rdi                # Move to next character
    jmp .convert_loop

.invalid_input:
    # Print error message
    lea invalid_digit_msg(%rip), %rdi
    mov $invalid_digit_msg_len, %rsi
    call log_err
    xor %rax, %rax          # Return 0 on error
    jmp .exit_str_to_int

.apply_sign:
    test %rcx, %rcx         # Check if negative
    jz .exit_str_to_int
    neg %rax                # Negate result if negative

.exit_str_to_int:
    pop %rbx
    pop %rbp
    ret
    