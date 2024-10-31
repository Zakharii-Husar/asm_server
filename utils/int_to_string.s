.section .data
string_buffer:    .space 21            # Buffer to hold the converted number (up to 20 digits + null terminator)

.section .text
.type int_to_string, @function
int_to_string:

 pushq %rbp                          # save the caller's base pointer
 mov %rsp, %rbp                      # set the new base pointer (stack frame)
 push %rcx

    lea string_buffer(%rip), %rsi     # Load the address of 'string_buffer' into %rsi
    addq $21, %rsi             # Move %rsi to the end of the string_buffer
    movq $10, %rbx             # Divisor (base 10)
    xor %rcx, %rcx             # Reset rcx to 0 to use it as a length counter for string
    movb $0, (%rsi)            # Null-terminate the string

    # rax / rbx = rax (quotient), rdx (remainder)
    movq %rdi, %rax
.loop:
    decq %rsi                   # Move to the next string_buffer position (backwards)
    incq %rcx                   # Increment the length counter
    xor %rdx, %rdx              # Clear RDX for the remainder
    divq %rbx                   # Divide RAX by 10; quotient in RAX, remainder in RDX
    
    # Convert remainder to ASCII and move it to the string_buffer
    addb $'0', %dl              # Use RDX to hold the ASCII character
    movb %dl, (%rsi)            # Store the converted ASCII digit in string_buffer
    testq %rax, %rax            # Check if quotient is zero
    jnz .loop                   # If not zero, continue dividing

    # Prepare to return values
    movq %rsi, %rax             # Adjust %rax to point to the start of the string
    movq %rcx, %rdx             # Move length of the string to RDX
    
    pop %rcx
    pop %rbp                     # restore the caller's base pointer

    ret                         # Return, RAX has the pointer, RDX has the length
