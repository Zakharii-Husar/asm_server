.section .text  

.global adjust_timezone
.type adjust_timezone, @function
adjust_timezone:
    push %rbp
    mov %rsp, %rbp
    push %r12
    push %r13

    mov %rdi, %r12              # Store UTC timestamp
    
    # Get timezone offset
    mov CONF_TIMEZONE_OFFSET(%r15), %rax
    
    # Split into hours and minutes
    mov %rax, %r13              # Save original offset
    mov $100, %rcx
    cqo                         # Sign-extend RAX into RDX
    idiv %rcx                   # Divide by 100
                               # Now: RAX = hours, RDX = minutes
    
    # Convert hours to seconds (multiply by 3600)
    imul $3600, %rax, %rax
    
    # Convert minutes to seconds (multiply by 60)
    imul $60, %rdx, %rdx
    
    # Add hours and minutes
    add %rdx, %rax
    
    # Add the total offset to timestamp
    add %rax, %r12
    mov %r12, %rax              # Put result in return register

    pop %r13
    pop %r12
    pop %rbp
    ret
    