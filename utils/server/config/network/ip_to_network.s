.section .text
.globl ip_to_network
.type ip_to_network, @function
# Function: ip_to_network
# Parameters:
#   - %rdi: pointer to IP address string (e.g., "192.168.1.1")
# Return Values:
#   - %rax: network byte order integer representation of IP
# Error Handling:
#   - Returns -1 if invalid IP format
#   - Returns -1 if null pointer passed
# Side Effects:
#   - None
ip_to_network:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    
    # Add string length check at the start
    push %rdi           # Save input pointer
    test %rdi, %rdi
    jz invalid_input
    call str_len
    cmp $0, %rax
    jle invalid_input   # If length <= 0, return error
    pop %rdi           # Restore input pointer
    
    xor %rax, %rax        # Initialize result to 0
    mov %rdi, %r12        # Store IP string pointer in r12
    xor %rbx, %rbx        # Current octet value
    mov $24, %ecx         # Start with highest byte (shift position)

parse_loop:
    movzbl (%r12), %edx    # Load current character
    test %dl, %dl          # Check for null terminator
    je done_parsing

    cmp $'.', %dl         # Check if it's a dot
    je next_octet

    # Convert ASCII digit to number and add to current octet
    sub $'0', %dl         # Convert ASCII to number
    imul $10, %rbx        # Multiply current value by 10
    add %rdx, %rbx        # Add new digit

    inc %r12              # Move to next character
    jmp parse_loop

next_octet:
    # Place octet in correct position
    mov %rbx, %rdx
    shl %cl, %rdx        # Shift to correct position
    or %rdx, %rax        # Add to result
    xor %rbx, %rbx       # Reset current octet
    inc %r12             # Skip the dot
    sub $8, %cl          # Move to next byte position (24->16->8->0)
    jmp parse_loop

done_parsing:
    # Add the last octet
    mov %rbx, %rdx
    shl %cl, %rdx
    or %rdx, %rax

    # Convert from host to network byte order
    bswap %eax           # Swap bytes to get network order

    .exit_str_len:
    pop %r12
    pop %rbx
    pop %rbp
    ret

invalid_input:
    mov $-1, %eax      # Return -1 for invalid input
    jmp .exit_str_len
