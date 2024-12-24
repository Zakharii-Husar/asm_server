.section .data
.equ client_ip_B_size, 16

.dot: .asciz "."

.section .bss
.lcomm client_ip, client_ip_B_size          # Buffer for IPv4 address string

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

    # Clear the client_ip buffer before use
    lea client_ip(%rip), %rdi
    mov $client_ip_B_size, %rsi
    call clear_buffer

    lea client_ip(%rip), %r14      # Get fresh buffer pointer
    
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
    xor %rdx, %rdx
    mov $client_ip_B_size, %rcx
    call str_cat

    mov %r14, %rdi
    lea .dot(%rip), %rsi
    mov $1, %rdx
    mov $client_ip_B_size, %rcx
    call str_cat

    # SECOND BYTE
    mov %r12d, %eax               # Use preserved value
    shr $16, %eax
    and $0xFF, %eax
    movzx %al, %rdi
    call int_to_str

    mov %r14, %rdi
    mov %rax, %rsi
    xor %rdx, %rdx
    mov $client_ip_B_size, %rcx
    call str_cat

    mov %r14, %rdi
    lea .dot(%rip), %rsi
    mov $1, %rdx
    mov $client_ip_B_size, %rcx
    call str_cat

    # THIRD BYTE
    mov %r12d, %eax               # Use preserved value
    shr $8, %eax
    and $0xFF, %eax
    movzx %al, %rdi
    call int_to_str

    mov %r14, %rdi
    mov %rax, %rsi
    xor %rdx, %rdx
    mov $client_ip_B_size, %rcx
    call str_cat

    mov %r14, %rdi
    lea .dot(%rip), %rsi
    mov $1, %rdx
    mov $client_ip_B_size, %rcx
    call str_cat

    # FOURTH BYTE
    mov %r12d, %eax               # Use preserved value
    and $0xFF, %eax
    movzx %al, %rdi
    call int_to_str

    mov %r14, %rdi
    mov %rax, %rsi
    xor %rdx, %rdx
    mov $client_ip_B_size, %rcx
    call str_cat

    pop %r12                      # Restore %r12
    pop %rbp
    ret
