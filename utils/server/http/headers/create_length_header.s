.section .rodata
content_length:  .asciz "Content-Length: "
content_length_length = . - content_length    


.section .text
.type create_length_header, @function
# Function: create_length_header
# Parameters:
#   - %rdi: content length value
#   - %rsi: pointer to response buffer
#   - %rdx: max buffer size
# Return Values:
#   - %rax: length of concatenated string
# Error Handling:
#   - Truncates if buffer size exceeded
# Side Effects:
#   - Modifies response buffer
create_length_header:
    push %rbp
    mov %rsp, %rbp
    sub $8, %rsp
    # Save parameters
    push %r12
    push %r13
    push %r14

    mov %rdi, %r12   # response_header_buffer
    mov %rsi, %r13   # content length
    mov %rdx, %r14   # max buffer size
    
    # 1. Add "Content-Length: " prefix
    mov %r12, %rdi
    lea content_length(%rip), %rsi
    mov $content_length_length, %rdx
    mov %r14, %rcx
    call str_cat
    
    # 2. Convert content length to string
    mov %r13, %rdi
    call int_to_str
    
    # 3. Add the length value
    mov %r12, %rdi
    # %rax already contains string pointer from int_to_str
    mov %rax, %rsi
    # %rdx already contains length from int_to_str
    mov %r14, %rcx
    call str_cat
    
    # 4. Add CRLF
    mov %r12, %rdi
    lea CRLF(%rip), %rsi
    mov $CRLF_length, %rdx
    mov %r14, %rcx
    call str_cat
    
    pop %r14
    pop %r13
    pop %r12
    add $8, %rsp
    leave
    ret
