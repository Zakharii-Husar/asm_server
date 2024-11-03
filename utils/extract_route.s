# ... existing code ...

.section .data
.equ SPACE, 32                    # ASCII code for space character

.section .bss
.lcomm request_route, 1024        # Buffer to store the extracted route

.section .text
# ... existing code ...

.globl extract_route
.type extract_route, @function
extract_route:
    push %rbp
    mov %rsp, %rbp

    # Initialize registers
    lea request_buffer(%rip), %rsi    # Source buffer (HTTP request)
    lea request_route(%rip), %rdi     # Destination buffer for route
    xor %rcx, %rcx                    # Clear counter
    
    # Skip first word (HTTP method) by finding first space
find_first_space:
    movb (%rsi), %al
    cmp $SPACE, %al
    je found_first_space
    inc %rsi
    jmp find_first_space

found_first_space:
    inc %rsi                          # Skip the space

copy_route:
    movb (%rsi), %al                  # Load character
    cmp $SPACE, %al                   # Check for space (end of route)
    je copy_done
    cmp $0, %al                       # Check for null terminator
    je copy_done
    
    movb %al, (%rdi)                  # Copy character to route buffer
    inc %rsi
    inc %rdi
    inc %rcx                          # Increment counter
    jmp copy_route

copy_done:
    movb $0, (%rdi)                   # Null terminate the route string
    mov %rcx, %rdx                    # Store length in rdx for later use
    
    pop %rbp
    ret 
    