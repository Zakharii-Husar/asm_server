.section .rodata
overflow_msg: .asciz "MODERATE: buffer overflow detected in str_concat.s"
overflow_msg_length = . - overflow_msg

# Function: str_concat
# Input:
#   %rdi - destination buffer
#   %rsi - source string (buffer or asciz)
#   %rdx - string length (optional, if 0, length will be calculated)
#   %rcx - max size of destination buffer
# Output: none (modifies destination buffer in place)

.section .text

.type str_concat, @function
str_concat:
    push %rbp                  
    mov %rsp, %rbp             
    push %r12
    push %r13
    push %r14

    # Save input parameters
    mov %rdi, %r12            # Destination buffer
    mov %rsi, %r14            # Source string
    mov %rcx, %r13            # Max buffer size

    # Get source length if not provided
    test %rdx, %rdx
    jnz .use_provided_length
    
    mov %r14, %rdi
    call str_len
    mov %rax, %rdx

.use_provided_length:
    # Simple bounds check:
    # 1. Get current dest length
    mov %r12, %rdi
    call str_len              
    
    # 2. Check if source + dest + 1 <= max size
    add %rdx, %rax            # Add source length
    inc %rax                  # Add 1 for null terminator
    cmp %r13, %rax           # Compare with max size
    jg .handle_string_b_overflow

    # Find end of destination string
    mov %r12, %rdi
    call str_len
    add %rax, %r12           # Point to end of string

    # Do the concatenation
    mov %r12, %rdi           # Destination = end of current content
    mov %r14, %rsi           # Source
    mov %rdx, %rcx           # Length to copy
    cld
    rep movsb

    # Add null terminator
    movb $0, (%rdi)

    .exit_str_concat:
    pop %r14
    pop %r13
    pop %r12
    pop %rbp
    ret

   .handle_string_b_overflow:

    lea overflow_msg(%rip), %rdi
    mov $overflow_msg_length, %rsi
    mov %rax, %rdx
    call log_error
    jmp .exit_str_concat
