.section .text
.globl ip_to_network
.type ip_to_network, @function

ip_to_network:
    push %rbp
    mov %rsp, %rbp
    # Preserve registers we'll use
    push %rbx
    push %r12
    
    xor %rax, %rax        # Initialize result to 0
    mov %rdi, %r12        # Store IP string pointer in r12
    xor %rbx, %rbx        # Current octet value
    xor %ecx, %ecx        # Byte position counter (0-3)

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
    # Shift existing result left by 8 and add new octet
    shl $8, %rax
    or %rbx, %rax        # Add current octet to result
    xor %rbx, %rbx       # Reset current octet
    inc %r12             # Skip the dot
    inc %ecx             # Increment byte position
    jmp parse_loop

done_parsing:
    # Add the last octet
    shl $8, %rax
    or %rbx, %rax

    # Restore registers and return
    pop %r12
    pop %rbx
    pop %rbp
    ret
