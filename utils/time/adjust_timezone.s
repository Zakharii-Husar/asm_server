.section .data
    winnipeg_timezone: .asciz "-6"

.section .text  

.global adjust_timezone
.type adjust_timezone, @function
adjust_timezone:
    push %rbp
    mov %rsp, %rbp
    push %r12

    mov %rdi, %r12              # Store UTC timestamp
    
    # Prepare to call str_to_int
    lea winnipeg_timezone(%rip), %rdi
    call str_to_int             # Result in %rax
    
    # Convert hours to seconds (multiply by 3600)
    imul $3600, %rax, %rax
    
    # Simply add the offset (will subtract if negative)
    add %rax, %r12
    mov %r12, %rax              # Put result in return register

    pop %r12
    pop %rbp
    ret
    