.section .data
content_length:  .ascii "Content-Length: "
content_length_length = . - content_length

newline:        .ascii "\r\n"
newline_length = . - newline    

.section .text

# Creates a Content-Length header with the specified length value
#
# Parameters:
#   %rdi - pointer to response header buffer (destination)
#   %rsi - content length value (integer)
#
# Returns:
#   None - modifies buffer in place
#
.type create_length_header, @function
create_length_header:
    push %rbp
    mov %rsp, %rbp
    
    # Save parameters
    push %r12
    push %r13
    mov %rdi, %r12   # response_header_buffer
    mov %rsi, %r13   # content length
    
    # 1. Add "Content-Length: " prefix
    mov %r12, %rdi
    lea content_length(%rip), %rsi
    mov $content_length_length, %rdx
    call str_concat
    
    # 2. Convert content length to string
    mov %r13, %rdi
    call int_to_string
    
    # 3. Add the length value
    mov %r12, %rdi
    # %rax already contains string pointer from int_to_string
    mov %rax, %rsi
    # %rdx already contains length from int_to_string
    call str_concat
    
    # 4. Add newline
    mov %r12, %rdi
    lea newline(%rip), %rsi
    mov $newline_length, %rdx
    call str_concat
    
    pop %r13
    pop %r12
    pop %rbp
    ret