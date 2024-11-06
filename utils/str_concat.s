# %rdi >>> %r8 = destination buffer
# %rsi = string (buffer or asciz)
# %rdx = string length

.section .text

.type str_concat, @function
str_concat:
    push %rbp                  # Save the caller's base pointer
    mov %rsp, %rbp             # Set up new stack frame
    mov %rdi, %r8             # Save destination buffer
    
    # Check if string length is provided
    test %rdx, %rdx
    jz offset_buffer

    # If not find string length
    mov %rsi, %rdi         # Move source string to first parameter for str_len
    call str_len           # Call str_len, result will be in %rax
    mov %rax, %rdx         # Move length to rdx
    
    offset_buffer:
    
    # Check if destination buffer is empty
    test %r8, %r8
    jz start_concat         # if empty, jump to start_concat

    # Find offset of the first null byte
    mov %r8, %rdi
    call str_len
    mov %r8, %rdi          # Restore destination address to rdi
    add %rax, %rdi         # Add offset to destination address
    jmp concat_bytes       # Skip the rdi setup in start_concat

    start_concat:
    mov %r8, %rdi          # destination

    concat_bytes:
    # Copy bytes from source (%rsi) to destination (%rdi)
    mov %rdx, %rcx        # move length to rcx for rep movsb
    cld                   # clear direction flag (move forward)
    rep movsb            # copy bytes until rcx = 0

    movb $0, (%rdi)         # Null terminate the resulting string

    mov %r8, %rdi           # Move destination buffer pointer for str_len
    call str_len           # Get length of concatenated string into %rax

    pop %rbp                # restore caller's base pointer
    ret
