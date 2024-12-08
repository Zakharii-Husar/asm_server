.section .text
.type skip_spaces, @function
# Skip whitespace characters at the start of the line
# Input:
#   %rdi: Address of the current position in the buffer
# Output:
#   %rax: Address of the first non-whitespace character
skip_spaces:
    push %rbp
    mov %rsp, %rbp
    push %r12
    mov %rdi, %r12
    .compare_spaces:
    mov %r12, %rdi
    mov $' ', %rsi
    call char_cmp
    cmp $0, %rax
    je .exit_skip_spaces
    inc %r12
    jmp .compare_spaces

    .exit_skip_spaces:
    mov %r12, %rax
    pop %r12
    pop %rbp
    ret
