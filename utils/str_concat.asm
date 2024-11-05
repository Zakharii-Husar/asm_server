# Function: str_concat
# Concatenates a source string to a destination buffer
# Inputs:
#   rdi - pointer to destination buffer (null-terminated)
#   rsi - pointer to source string
#   rdx - length of source string (0 to use strlen)
# Clobbers: rax, rcx
# Returns: rax - pointer to the end of concatenated string
str_concat:
    push    rbx                    # preserve rbx
    mov     rbx, rdi              # save dest pointer
    
    # Find end of destination string
    call    strlen                # get length of dest string
    add     rdi, rax             # move to end of dest string
    
    # Check if we need to calculate source length
    test    rdx, rdx
    jnz     .copy_string         # if length provided, skip strlen
    mov     rdi, rsi
    call    strlen               # get source length
    mov     rdx, rax             # store length
    mov     rdi, rbx             # restore dest pointer
    add     rdi, rax             # move to end position again
    
.copy_string:
    mov     rcx, rdx             # set counter to length
    rep     movsb                # copy bytes
    mov     byte [rdi], 0        # null terminate
    
    mov     rax, rdi             # return pointer to end
    pop     rbx
    ret 