.section .text
.globl htons
.type htons, @function
htons:
# Function: htons (host to network short)
# Parameters:
#   - %rdi: 16-bit port number in host byte order
# Return Values:
#   - %ax: 16-bit port number in network byte order
# Error Handling:
#   - None
# Side Effects:
#   - None
    push %rbp
    mov %rsp, %rbp

    # Convert to network byte order (swap bytes)
    mov %di, %ax              # Move port number to ax (16-bit)
    rol $8, %ax               # Rotate left by 8 bits (instead of xchg)
    
    # Zero-extend ax to rax for return value
    movzx %ax, %rax
    
    pop %rbp
    ret
    