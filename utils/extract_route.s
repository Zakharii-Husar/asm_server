# Function: extract_route
# Input: 
#   %rdi - pointer to the request buffer (global)
# Output: none (modifies request_route and request_file_ext buffers)

.section .data
.equ SPACE, 32                    # ASCII code for space character
index_str: .asciz "index"
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

    # Check if route is just "/"
    lea request_route(%rip), %rdi    # Start of route
    movb (%rdi), %al                 # Load first character
    cmpb $'/', %al                   # Is it a slash?
    jne search_for_extension         # If not, continue normal flow
    movb 1(%rdi), %al               # Load second character
    cmpb $0, %al                    # Is it end of string?
    jne search_for_extension        # If not, continue normal flow
    
    # Append "index" to the route
    lea request_route(%rip), %rdi    # Destination buffer
    lea index_str(%rip), %rsi        # Source (.html extension)
    xor %rdx, %rdx                    # Let str_concat calculate length
    call str_concat

search_for_extension:               # New label for existing extension search
    lea request_route(%rip), %rdi   # Start of route
    
search_dot:
    movb (%rdi), %al                 # Load current character into al
    cmpb $0, %al                     # Check for null terminator first
    je no_extension
    cmpb $'.', %al                   # Is it a dot?
    je found_extension
    inc %rdi
    jmp search_dot

found_extension:
    mov %rdi, %r10                    # Save beginning of extension
    jmp finish                        # Skip the no_extension code

no_extension:
    # Append .html extension since none was found
    mov %rdi, %r10                    # %r10 holds beginning of extension
    lea request_route(%rip), %rdi     # Destination buffer
    lea html_ext(%rip), %rsi          # Source (.html extension)
    xor %rdx, %rdx                    # Let str_concat calculate length
    call str_concat


finish:
    # Copy extension (including dot) to extension buffer
    mov %r10, %rsi                    # %r10 holds beginning of extension
    lea request_file_ext(%rip), %rdi  # Destination is extension buffer
    xor %rdx, %rdx                    # Let str_concat calculate length
    call str_concat

    # Convert route to lowercase
    lea request_route(%rip), %rdi
    call str_to_lower

    # Convert extension to lowercase
    lea request_file_ext(%rip), %rdi
    call str_to_lower

    pop %rbp
    ret
