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
    jmp copy_route

check_for_extension:
    # Save the end of the string pointer
    mov %rdi, %r8                     # Save current position
    
search_dot:
    cmpb $'.', (%rdi)                 # Is it a dot?
    je found_extension
    cmpb $'/', (%rdi)                 # Hit a slash? No extension
    je no_extension
    cmp %rdi, %rsi                    # Reached start of string?
    je no_extension
    dec %rdi
    jmp search_dot

found_extension:
    mov $1, %rax                      # Flag: has extension
    mov %r8, %rdi                     # Restore end position
    jmp finish

no_extension:
    mov $0, %rax                      # Flag: no extension
    mov %r8, %rdi                     # Restore end position

finish:
    movb $0, 1(%rdi)                  # Null terminate after current position
    pop %rbp
    ret
