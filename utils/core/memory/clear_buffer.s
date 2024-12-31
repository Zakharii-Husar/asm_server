.section .text

.type clear_buffer, @function
clear_buffer:
    push %rbp
    mov %rsp, %rbp
    sub $8, %rsp              # align stack to 16-byte boundary

    # Parameters:
    # %rdi - buffer address
    # %rsi - buffer size

    cld                       # Clear Direction Flag (DF = 0) to move forward

    # Clear the buffer
    xor %rax, %rax           # Set %rax to 0 (value to store in buffer)
    mov %rsi, %rcx           # Load buffer size into %rcx (count)
    rep stosb                # Zero out the buffer (incrementing %RDI)

    leave                    # restore stack frame
    ret
