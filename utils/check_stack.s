.section .rodata
aligned_msg: .asciz " - Stack is aligned\n"
aligned_msg_len = . - aligned_msg

misaligned_msg: .asciz " - STACK IS MISALIGNED\n"
misaligned_msg_len = . - misaligned_msg

.section .text
.globl check_stack
.type check_stack, @function
check_stack:
    push %rbp
    mov %rsp, %rbp

    # Divide by 16
    mov %rdi, %rax
    mov $16, %rcx
    cqo                 # Sign extend RAX into RDX:RAX
    idiv %rcx          # Divide RDX:RAX by RCX
    
    mov %rdx, %rdi

    test %rdi, %rdi
    jz .aligned

    call int_to_str
    mov %rax, %rdi
    xor %rsi, %rsi
    call print_info
    lea misaligned_msg(%rip), %rdi
    mov $misaligned_msg_len, %rsi
    call print_info
    jmp .exit

    .aligned:
    call int_to_str
    mov %rax, %rdi
    xor %rsi, %rsi
    call print_info
    lea aligned_msg(%rip), %rdi
    mov $aligned_msg_len, %rsi
    call print_info

    xor %rsi, %rsi
    call print_info


    .exit:
    leave
    ret
    