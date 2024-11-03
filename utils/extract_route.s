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
    je check_for_extension
    cmp $0, %al                       # Check for null terminator
    je check_for_extension
    
    movb %al, (%rdi)                  # Copy character to route buffer
    inc %rsi
    inc %rdi
    inc %rcx                          # Increment counter
    jmp copy_route

check_for_extension:
    # Save current position and counter
    push %rdi
    push %rcx
    
    # Start from end, look for dot
    dec %rdi
search_dot:
    cmpb $'.', (%rdi)                 # Is it a dot?
    je found_extension
    cmpb $'/', (%rdi)                 # Hit a slash? No extension
    je no_extension
    dec %rdi
    dec %rcx
    cmp $0, %rcx                      # Start of string? No extension
    je no_extension
    jmp search_dot

found_extension:
    pop %rcx
    pop %rdi
    mov $1, %r8                       # Flag: has extension
    jmp finish

no_extension:
    pop %rcx
    pop %rdi
    mov $0, %r8                       # Flag: no extension

finish:
    movb $0, (%rdi)                   # Null terminate
    mov %rcx, %rdx                    # Store length in rdx
    pop %rbp
    ret
