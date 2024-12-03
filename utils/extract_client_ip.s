.section .bss
.lcomm client_ip, 16                        # Buffer for IPv4 address string

.section .data
.dot: .asciz "."
.section .text
# Function: extract_client_ip
# Arguments:
#   %rdi: pointer to sockaddr buffer
# Global Variables:
#   %r14: pointer to client_ip buffer (where output will be stored)
.type extract_client_ip, @function
extract_client_ip:
    push %rbp
    mov %rsp, %rbp
    push %r12                       # Save %r12 since we'll use it

    lea client_ip(%rip), %r14
    
    mov 4(%rdi), %ecx              # Load sin_addr (4 bytes) into ECX
    bswap %ecx                     # Convert from network byte order
    mov %ecx, %r12d                # Preserve the full IP in %r12d

    # FIRST BYTE
    mov %r12d, %eax               # Use preserved value
    shr $24, %eax
    movzx %al, %rdi
    call int_to_str

    mov %r14, %rdi
    mov %rax, %rsi
    call str_concat

    mov %r14, %rdi
    lea .dot(%rip), %rsi
    mov $1, %rdx
    call str_concat

    # SECOND BYTE
    mov %r12d, %eax               # Use preserved value
    shr $16, %eax
    and $0xFF, %eax
    movzx %al, %rdi
    call int_to_str

    mov %r14, %rdi
    mov %rax, %rsi
    call str_concat

    mov %r14, %rdi
    lea .dot(%rip), %rsi
    mov $1, %rdx
    call str_concat

    # THIRD BYTE
    mov %r12d, %eax               # Use preserved value
    shr $8, %eax
    and $0xFF, %eax
    movzx %al, %rdi
    call int_to_str

    mov %r14, %rdi
    mov %rax, %rsi
    call str_concat

    mov %r14, %rdi
    lea .dot(%rip), %rsi
    mov $1, %rdx
    call str_concat

    # FOURTH BYTE
    mov %r12d, %eax               # Use preserved value
    and $0xFF, %eax
    movzx %al, %rdi
    call int_to_str

    mov %r14, %rdi
    mov %rax, %rsi
    call str_concat

    pop %r12                      # Restore %r12
    pop %rbp
    ret
