# Function: extract_route
# Input: 
#   %rsi - pointer to the request buffer (global)
# Output: 
#   %rax - pointer to request_route
#   %rdx - pointer to request_file_ext

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

    # Initialize the route register
    lea request_route(%rip), %rsi     # Destination buffer for route
    
    # Skip first word (HTTP method) by finding first space
find_first_space:
    movb (%rdi), %al
    cmp $SPACE, %al
    je found_first_space
    inc %rdi
    jmp find_first_space

found_first_space:
    inc %rdi                          # Skip the space

    # Save start of route
    mov %rdi, %r9                     # Save route start position
    
    # Find end of route (next space)
find_route_end:
    movb (%rdi), %al
    cmp $SPACE, %al                   # Check for space
    je copy_full_route
    cmp $0, %al                       # Check for null
    je copy_full_route
    inc %rdi
    jmp find_route_end

copy_full_route:
    # Calculate route length
    mov %rdi, %rdx
    sub %r9, %rdx                     # Length = end - start
    mov %r9, %rsi                     # Source is route start
    call str_concat                   # Copy route to request_route

    # Check if route is just "/"
    lea request_route(%rip), %rsi     # Start of route
    movb (%rsi), %al                  # Load first character
    cmpb $'/', %al                    # Is it a slash?
    jne search_for_extension           # If not, continue normal flow
    movb 1(%rsi), %al                 # Load second character
    cmpb $0, %al                      # Is it end of string?
    jne search_for_extension           # If not, continue normal flow
    
    # Append "index" to the route
    lea request_route(%rip), %rsi     # Destination buffer
    lea index_str(%rip), %rdi         # Source (.html extension)
    xor %rdx, %rdx                    # Let str_concat calculate length
    call str_concat

search_for_extension:                 # New label for existing extension search
    lea request_route(%rip), %rsi     # Start of route
    
search_dot:
    movb (%rsi), %al                  # Load current character into al
    cmpb $0, %al                      # Check for null terminator first
    je no_extension
    cmpb $'.', %al                    # Is it a dot?
    je found_extension
    inc %rsi
    jmp search_dot

found_extension:
    mov %rsi, %r10                    # Save beginning of extension
    jmp finish                        # Skip the no_extension code

no_extension:
    # Append .html extension since none was found
    mov %rsi, %r10                    # %r10 holds beginning of extension
    lea request_route(%rip), %rsi     # Destination buffer
    lea html_ext(%rip), %rdi          # Source (.html extension)
    xor %rdx, %rdx                    # Let str_concat calculate length
    call str_concat

finish:
    # Copy extension (including dot) to extension buffer
    mov %r10, %rsi                    # %r10 holds beginning of extension
    lea request_file_ext(%rip), %rdi  # Destination is extension buffer
    xor %rdx, %rdx                    # Let str_concat calculate length
    call str_concat

    # Convert route to lowercase
    lea request_route(%rip), %rsi
    call str_to_lower

    # Convert extension to lowercase
    lea request_file_ext(%rip), %rsi
    call str_to_lower

    # Return pointers to request_route and request_file_ext
    lea request_route(%rip), %rax      # Return pointer to request_route
    lea request_file_ext(%rip), %rdx   # Return pointer to request_file_ext

    pop %rbp
    ret
