.section .data
buffer:
    .space 21            # Buffer to hold the converted number (up to 20 digits + null terminator)

.section .text

.type int_to_string, @function
int_to_string:
    # FUNCTION ARGS
    movq $1234567890, %rdi   # Number to convert
    movq $buffer, %rsi       # Point to the buffer for storing string
    xor %rcx, %rcx            # Reset rcx to 0 to use it as a length counter for string 

    movq %rdi, %rax          # Copy the input number into RAX
    movq $10, %rbx           # Divisor (base 10)

.loop:
    # rax / rbx = rax (quotient), rdx (remainder)
    xor %rdx, %rdx           # Clear RDX (since it will hold the remainder)
    divq %rbx                # Divide RAX by 10; quotient in RAX, remainder in RDX
    addb $'0', %dl           # dl is RDX; Convert remainder to ASCII ('0' + digit)
    movb %dl, (%rsi)         # dl is RDX and rsi pointing to current buffer position; Store the converted ASCII digit in buffer

    incq %rsi                # Move to the next buffer position
    incq %rcx                # Increment the length counter
    testq %rax, %rax         # Check if quotient is zero
    jnz .loop                # If not zero, continue dividing

    # Null-terminate the string
    movb $0, (%rsi)          # Null-terminate the string

    # Prepare to print the result
    lea buffer(%rip), %rsi     # Load the address of 'buffer' into %rsi using lea
    movq %rcx, %rdx            # Load the length of the string into %rdx
    call print_info            # Call the function to print


    ret                       # Return from the function
