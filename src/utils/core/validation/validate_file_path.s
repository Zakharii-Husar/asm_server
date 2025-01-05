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
    sub $8, %rsp
    push %r12
    
    mov %rdi, %r12      # Save path pointer
    
    # 1. Check if path starts with '/'
    movb (%r12), %al
    cmp $'/', %al
    je .invalid_path
    
    # 2. Check for "../" sequence
    mov %r12, %rdi              
    lea dotdot_slash(%rip), %rsi    
    call str_contains
    cmp $1, %rax
    je .invalid_path
    
    # 3. Check for "..\" sequence
    mov %r12, %rdi              
    lea dotdot_backslash(%rip), %rsi    
    call str_contains
    cmp $1, %rax
    je .invalid_path
    
    # 4. Check for ".." at end of path
    mov %r12, %rdi              
    lea dotdot_end(%rip), %rsi      
    call str_contains
    cmp $1, %rax
    je .invalid_path
    
    # 5. Check for percent encoding (URL encoding)
    mov %r12, %rdi              
    lea percent(%rip), %rsi         
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
    add $8, %rsp
    leave                     # restore stack frame
    ret
    