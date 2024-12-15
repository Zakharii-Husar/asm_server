.section .data
hex_chars: .ascii "0123456789ABCDEF"
space:     .ascii " "

.section .text
# Function to print a buffer in hex format
# Parameters:
#   %rdi - buffer pointer
#   %rsi - length
.globl hex_dump
.type hex_dump, @function
hex_dump:
    push %rbp
    mov %rsp, %rbp
    push %rbx
    push %r12
    push %r13
    push %r14
    
    mov %rdi, %r12      # Save buffer pointer
    mov %rsi, %r13      # Save length
    xor %r14, %r14      # Counter

.print_loop:
    cmp %r13, %r14      # Check if we've printed all bytes
    jge .done_dump
    
    # Get current byte
    movzbl (%r12, %r14), %ebx
    
    # Print first hex digit
    mov %ebx, %eax
    shr $4, %al         # Get high 4 bits
    lea hex_chars(%rip), %rdi
    movzbl (%rdi, %rax), %edi  # Get corresponding hex char
    push %rax
    call write_char
    pop %rax
    
    # Print second hex digit
    mov %ebx, %eax
    and $0xF, %al       # Get low 4 bits
    lea hex_chars(%rip), %rdi
    movzbl (%rdi, %rax), %edi  # Get corresponding hex char
    push %rax
    call write_char
    pop %rax
    
    # Print space
    mov $' ', %dil
    push %rax
    call write_char
    pop %rax
    
    inc %r14
    jmp .print_loop

.done_dump:
    # Print newline at end
    mov $'\n', %dil
    call write_char
    
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret

# Helper function to write a single character
# Parameter: %dil - character to write
write_char:
    push %rbp
    mov %rsp, %rbp
    
    # Save char on stack
    sub $1, %rsp
    mov %dil, (%rsp)
    
    # Write syscall
    mov $1, %rax        # sys_write
    mov $1, %rdi        # stdout
    mov %rsp, %rsi      # pointer to char
    mov $1, %rdx        # length
    syscall
    
    add $1, %rsp
    pop %rbp
    ret
