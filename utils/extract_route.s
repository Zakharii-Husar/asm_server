# Function: extract_route
# Input: 
#   %rdi - pointer to the request_route_buffer
#   %rsi - pointer to the request_content_buffer
# Output:  none

.section .data
.equ SPACE, 32                    # ASCII code for space character
index_str: .asciz "index"
index_str_len = . - index_str
html_ext: .asciz ".html"          # HTML extension definition moved here
html_ext_len = . - html_ext
slash_string: .asciz "/" 

.section .text

.globl extract_route
.type extract_route, @function
extract_route:
    push %rbp
    mov %rsp, %rbp
    push %r12
    push %r13
    
    mov %rdi, %r12                   # Save request_route_buffer
    
    # Find first space using str_find_char
    mov %rsi, %rdi                   # Move request_content_buffer to rdi
    mov $SPACE, %rsi                 # Move space character to rsi
    call str_find_char               # Find first space
    inc %rax                         # Skip the space
    mov %rax, %r13                   # Save start of route in callee-saved register

    # Find end of route (next space)
    mov %r13, %rdi                   # Move request_content_buffer to rdi
    mov $SPACE, %rsi                 # Move space character to rsi
    call str_find_char               # Find next space



    # Prepare arguments for str_concat
    mov %r12, %rdi                   # Restore the destination buffer
    mov %r13, %rsi                   # Restore start of route from stack
    mov %rax, %rdx                  # End position returned by str_find_char to rdx
    sub %r13, %rdx                  # Calculate length (end - start)
    # Copy route to buffer
    call str_concat


    # Check if route is just "/"
    mov %r12, %rdi                   # Move request_route_buffer to rdi
    lea slash_string(%rip), %rsi
    call str_cmp
    cmp $0, %rax
    jne .search_for_extension         # Skip index append if not "/"

    # Append "index" to the route
    mov %r12, %rdi                   # Move request_route_buffer to rdi
    lea index_str(%rip), %rsi        # Load "index" as source string into %rsi
    mov $index_str_len, %rdx         # Length of "index"
    call str_concat

.search_for_extension:          
    mov %r12, %rdi                   # Move request_route_buffer to rdi
    mov $'.', %rsi
    call str_find_char      
    cmp $1, %rdx
    je .exit_extract_route 

.no_extension:
    # Append .html extension
    mov %r12, %rdi                   # Move request_route_buffer to rdi
    lea html_ext(%rip), %rsi         
    mov $html_ext_len, %rdx          # Length of ".html"
    call str_concat

.exit_extract_route:
    pop %r13
    pop %r12
    pop %rbp    
    ret
