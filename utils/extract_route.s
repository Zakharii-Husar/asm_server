.section .data
.equ SPACE, 32                    # ASCII code for space character
html_ext: .asciz ".html"          # HTML extension definition moved here

.section .bss
.lcomm request_route, 1024        # Buffer to store the extracted route
.lcomm request_file_ext, 32       # Buffer to store file extension (including dot)

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

    # Save start of route
    mov %rsi, %r9                     # Save route start position
    
    # Find end of route (next space)
find_route_end:
    movb (%rsi), %al
    cmp $SPACE, %al                   # Check for space
    je copy_full_route
    cmp $0, %al                       # Check for null
    je copy_full_route
    inc %rsi
    jmp find_route_end

copy_full_route:
    # Calculate route length
    mov %rsi, %rdx
    sub %r9, %rdx                     # Length = end - start
    mov %r9, %rsi                     # Source is route start
    call str_concat                   # Copy route to request_route

    # Now search for extension
    lea request_route(%rip), %rdi    # Start of route
    
search_dot:
    movb (%rdi), %al                 # Load current character into al
    cmpb $0, %al                     # Check for null terminator first
    je no_extension
    cmpb $'.', %al                   # Is it a dot?
    je found_extension
    inc %rdi
    jmp search_dot

found_extension:
    # Copy extension (including dot) to extension buffer
    mov %rdi, %rsi                    # String source is dot position
    lea request_file_ext(%rip), %rdi  # Destination is extension buffer
    xor %rdx, %rdx                    # Let str_concat calculate length
    call str_concat

    mov $1, %rax                      # Flag: has extension
    jmp finish                        # Skip the no_extension code

no_extension:
    # Append .html extension since none was found
    lea request_route(%rip), %rdi     # Destination buffer
    lea html_ext(%rip), %rsi          # Source (.html extension)
    xor %rdx, %rdx                    # Let str_concat calculate length
    call str_concat

    lea request_route(%rip), %rsi
    call print_info

finish:
    pop %rbp
    ret
