# Function: extract_route
# Input: 
#   %rdi - pointer to the request_content_buffer
#   %rsi - pointer to the request_route_buffer
# Output:  none

.section .data
.equ SPACE, 32                    # ASCII code for space character
index_str: .asciz "index"
html_ext: .asciz ".html"          # HTML extension definition moved here

slash_string: .asciz "/" 

.section .text

.globl extract_route
.type extract_route, @function
extract_route:
    push %rbp
    mov %rsp, %rbp
    
    # Find first space using str_find_char
    mov %rdi, %rsi                   # Move request buffer to %rsi for str_find_char
    mov $SPACE, %rdi                 # Move space character to %rdi
    call str_find_char               # Find first space
    mov %rax, %rdi                   # Move result pointer back to %rdi
    inc %rdi                         # Skip the space

    # Find end of route (next space)
    mov %rdi, %r9                    # Save start of route in r9
    mov %rdi, %rsi                   # Current position to %rsi for str_find_char
    mov $SPACE, %rdi                 # Space character to %rdi
    call str_find_char               # Find next space
    mov %rax, %r8                    # Save end position in r8

    # Calculate length and copy route
    mov %rsi, %rdi                    # Destination is now from parameter (rsi)
    mov %r9, %rsi                    # Start of route to source
    mov %r8, %rdx
    sub %r9, %rdx                    # Calculate length (end - start)
    call str_concat                  # Copy route to buffer

    # Check if route is just "/"
    mov %rsi, %rsi                   # Route buffer already in rsi
    lea slash_string(%rip), %rdi
    call str_cmp
    cmp $0, %rax
    je search_for_extension          

    # Append "index" to the route
    mov %rsi, %rsi                   # Route buffer already in rsi
    lea index_str(%rip), %rdi        
    xor %rdx, %rdx                   
    call str_concat

search_for_extension:                
    mov %rsi, %rsi                   # Route buffer already in rsi
    mov $'.', %rdi
    call str_find_char
    mov %rax, %r10                   
    cmp $1, %rdx
    je exit_extract_route 

no_extension:
    # Append .html extension
    mov %rsi, %rsi                   # Route buffer already in rsi
    lea html_ext(%rip), %rdi         
    xor %rdx, %rdx                   
    call str_concat

exit_extract_route:
pop %rbp
ret
