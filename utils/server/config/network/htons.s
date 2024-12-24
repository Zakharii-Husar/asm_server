.section .text
.globl htons
.type htons, @function
htons:
# Function: htons (host to network short)
# Input:
#   %rdi - port number in host byte order (e.g., 8080)
# Output:
#   %rax - port number in network byte order (e.g., 0x901F)
    push %rbp
    mov %rsp, %rbp

    # Convert to network byte order (swap bytes)
    mov %di, %ax              # Move port number to ax (16-bit)
    rol $8, %ax               # Rotate left by 8 bits (instead of xchg)
    
    # Zero-extend ax to rax for return value
    movzx %ax, %rax
    
    pop %rbp
    ret
    