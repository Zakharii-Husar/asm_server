.section .rodata
content_length:  .ascii "Content-Length: "
content_length_length = . - content_length    

.section .text
.type create_length_header, @function
# Function: create_length_header
# Parameters:
#   - %rdi: content length value
#   - %rsi: pointer to response buffer
# Return Values:
#   - %rax: length of concatenated string
# Error Handling:
#   - Truncates if buffer size exceeded
# Side Effects:
#   - Modifies response buffer
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
    mov $response_header_B_size, %rcx
    call str_cat
    
    # 2. Convert content length to string
    mov %r13, %rdi
    call int_to_str
    
    # 3. Add the length value
    mov %r12, %rdi
    # %rax already contains string pointer from int_to_str
    mov %rax, %rsi
    # %rdx already contains length from int_to_str
    mov $response_header_B_size, %rcx
    call str_cat
    
    # 4. Add CRLF
    mov %r12, %rdi
    lea CRLF(%rip), %rsi
    mov $CRLF_length, %rdx
    mov $response_header_B_size, %rcx
    call str_cat
    
    pop %r13
    pop %r12
    pop %rbp
    ret
    