.section .data
    dotdot_slash: .asciz "../"
    dotdot_backslash: .asciz "..\\"
    dotdot_end: .asciz ".."
    forward_slash: .asciz "/"
    percent: .asciz "%"

.section .text
.globl validate_file_path
.type validate_file_path, @function

validate_file_path:
    # Parameter:
    # %rdi - file path to validate
    
    # Return:
    # %rax - 1 if path is valid, 0 if invalid
    
    push %rbp
    mov %rsp, %rbp
    push %r12
    
    mov %rdi, %r12      # Save path pointer
    
    # 1. Check if path starts with '/'
    movb (%r12), %al
    cmp $'/', %al
    je .invalid_path
    
    # 2. Check for "../" sequence
    mov %r12, %rdi              # Main string is already in %r12
    lea dotdot_slash(%rip), %rsi    # Load effective address of "../"
    call str_contains
    cmp $1, %rax
    je .invalid_path
    
    # 3. Check for "..\" sequence
    mov %r12, %rdi              # Main string is already in %r12
    lea dotdot_backslash(%rip), %rsi    # Load effective address of "..\"
    call str_contains
    cmp $1, %rax
    je .invalid_path
    
    # 4. Check for ".." at end of path
    mov %r12, %rdi              # Main string is already in %r12
    lea dotdot_end(%rip), %rsi      # Load effective address of ".."
    call str_contains
    cmp $1, %rax
    je .invalid_path
    
    # 5. Check for percent encoding (URL encoding)
    mov %r12, %rdi              # Main string is already in %r12
    lea percent(%rip), %rsi         # Load effective address of "%"
    call str_contains
    cmp $1, %rax
    je .invalid_path
    
    # Path is valid
    mov $1, %rax
    jmp .validation_done
    
.invalid_path:
    mov $0, %rax
    
.validation_done:
    pop %r12
    pop %rbp
    ret