.section .text

.type str_concat, @function
str_concat:
    push %rbp                    # Save the caller's base pointer
    mov %rsp, %rbp              # Set up new stack frame
    push %rbx                    # preserve rbx
    mov %rbx, %rdi              # save dest pointer
    
    # Find end of destination string
    call str_len                 # get length of dest string
    add %rdi, %rax             # move to end of dest string
    
    # Check if we need to calculate source length
    test %rdx, %rdx
    jnz copy_string            # if length provided, skip str_len
    mov %rdi, %rsi
    call str_len                # get source length
    mov %rdx, %rax             # store length
    mov %rdi, %rbx             # restore dest pointer
    add %rdi, %rax             # move to end position again
    
copy_string:
    mov %rcx, %rdx             # set counter to length
    rep movsb                  # copy bytes
    movb $0, (%rdi)            # null terminate
    
    mov %rax, %rdi             # return pointer to end
    pop %rbx                   # restore rbx
    pop %rbp                   # restore caller's base pointer
    ret 