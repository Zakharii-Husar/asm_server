# Function: extract_route
# Input: 
#   %rsi - pointer to the request buffer (global)
#   %rdi - pointer to the request_route
# Output: 
#   %rax - pointer to request_route
#   %rdx - pointer to request_file_ext

.section .data
.equ SPACE, 32                    # ASCII code for space character
index_str: .asciz "index"
html_ext: .asciz ".html"          # HTML extension definition moved here

slash_string: .asciz "/" 

.section .bss
.lcomm request_route, 1024        # Buffer to store the extracted route

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
    lea slash_string(%rip), %rdi
    call str_cmp
    cmp $0, %rax
    je search_for_extension           # If not, continue normal flow
    
    # Append "index" to the route
    lea request_route(%rip), %rsi     # Destination buffer
    lea index_str(%rip), %rdi         # Source (.html extension)
    xor %rdx, %rdx                    # Let str_concat calculate length
    call str_concat

search_for_extension:                 # New label for existing extension search
    lea request_route(%rip), %rsi     # Start of route
    mov $'.', %rdi
    call str_find_char
    mov %rax, %r10                    # Save beginning of extension
    cmp $1, %rdx
    je exit_extract_route 

no_extension:
    # Append .html extension since none was found
    lea request_route(%rip), %rsi     # Destination buffer
    lea html_ext(%rip), %rdi          # Source (.html extension)
    xor %rdx, %rdx                    # Let str_concat calculate length
    call str_concat

exit_extract_route:
pop %rbp
ret
