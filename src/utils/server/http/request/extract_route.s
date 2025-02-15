.section .text
.globl extract_route
.type extract_route, @function
# Function: extract_route
# Parameters:
#   - %rdi: pointer to HTTP request buffer
# Global Registers:
#   - %r15: server configuration pointer
# Return Values:
#   - %rax: pointer to extracted route string
# Error Handling:
#   - Returns pointer to "/" if no valid route found
# Side Effects:
#   - Modifies route_buffer
extract_route:
    push %rbp
    mov %rsp, %rbp
    # Preserve non-volatile registers
    push %r12
    push %r13
    # Save arguments
    mov %rdi, %r12                   # Save request_route_buffer
    
    # Find first space using str_find_char
    mov %rsi, %rdi                   # Move request_content_buffer to rdi
    mov $space_ascii, %rsi                 # Move space character to rsi
    xor %rdx, %rdx                   # no boundary check
    call str_find_char               # Find first space
    inc %rax                         # Skip the space
    mov %rax, %r13                   # Save start of route in callee-saved register

    # Find end of route (next space)
    mov %r13, %rdi                   # Move start position to rdi
    mov $space_ascii, %rsi                 # Move space character to rsi
    xor %rdx, %rdx                   # no boundary check
    call str_find_char               # Find next space

    # Copy route to buffer
    mov %r12, %rdi                   # Destination buffer
    mov %r13, %rsi                   # Start of route
    mov %rax, %rdx                   # End position
    sub %r13, %rdx                   # Calculate length (end - start)
    mov $req_route_B_size, %rcx
    call str_cat

    pop %r13
    pop %r12
    leave
    ret
