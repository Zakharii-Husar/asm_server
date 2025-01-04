.section .text
.globl str_to_int
.type str_to_int, @function

# Function: str_to_int
# Input: %rdi - pointer to the string
# Output: %rax - integer value
str_to_int:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    xor %rax, %rax          # Clear rax for result
    xor %rcx, %rcx          # Clear rcx for sign (0 = positive, 1 = negative)

    # Check for signs
    movb (%rdi), %al
    cmpb $'-', %al
    je .handle_negative
    cmpb $'+', %al
    je .handle_positive
    jmp .parse_digits       # No sign, start parsing immediately

.handle_negative:
    inc %rdi                # Move past the negative sign
    inc %rcx                # Set sign to negative
    jmp .parse_digits

.handle_positive:
    inc %rdi                # Move past the positive sign
    # rcx remains 0 (positive)
    
.parse_digits:
    xor %rax, %rax          # Clear rax for result
    mov $10, %rbx           # Base 10 for conversion

.convert_loop:
    movb (%rdi), %dl        # Load next character
    cmpb $0, %dl            # Check for null terminator
    je .apply_sign          # If null, we're done
    subb $'0', %dl          # Convert ASCII to integer
    imul $10, %rax          # Multiply accumulated result by 10
    movzx %dl, %rdx         # Convert the single digit to 64-bit
    add %rdx, %rax          # Add the new digit
    inc %rdi                # Move to next character
    jmp .convert_loop

.apply_sign:
    test %rcx, %rcx         # Check if negative
    jz .exit_str_to_int
    neg %rax                # Negate result if negative

.exit_str_to_int:
    pop %rbx
    pop %rbp
    ret
    