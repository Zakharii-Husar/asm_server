.section .rodata
aligned_msg: .asciz " - Stack is aligned\n"
aligned_msg_len = . - aligned_msg

misaligned_msg: .asciz " - STACK IS MISALIGNED\n"
misaligned_msg_len = . - misaligned_msg

.section .text
.globl check_stack
.type check_stack, @function
check_stack:
    # Save the original rsp value before we modify it
    mov %rsp, %rax
    
    push %rbp
    mov %rsp, %rbp
    push %r12
    # Check stack alignment using saved rsp
    xor %rdx, %rdx          # Clear rdx for division
    mov $16, %rcx           # Divisor
    div %rcx                # Divide rax by 16, remainder in rdx
    test %rdx, %rdx         # Check if remainder is 0
    jz .stack_aligned
    
.stack_misaligned:
    lea misaligned_msg(%rip), %rdi
    mov $misaligned_msg_len, %rsi
    call print_info
    jmp .check_stack_done
    
.stack_aligned:

    lea aligned_msg(%rip), %rdi
    mov $aligned_msg_len, %rsi
    call print_info
    
.check_stack_done:
    mov %r12, %rdi
    call int_to_str
    mov %rax, %rdi
    xor %rsi, %rsi
    call print_info
    
    pop %r12
    pop %rbp
    ret
