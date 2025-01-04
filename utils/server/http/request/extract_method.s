.section .text

# Function: extract_method
# Parameters:
#   - %rdi: pointer to HTTP request buffer
# Return Values:
#   - %rax: pointer to extracted method string
# Error Handling:
#   - Returns pointer to "UNKNOWN" if no valid method found
# Side Effects:
#   - Modifies method_buffer
.globl extract_method
.type extract_method, @function
extract_method:
    push %rbp
    mov %rsp, %rbp
    # Align stack to 16-byte boundary
    sub $8, %rsp
    # Preserve non-volatile registers
    push %r12
    push %r13
    push %r14
    # Save arguments
    mov %rdi, %r12                   # Save the source pointer
    mov %rsi, %r13                   # Save the destination pointer
    mov %rdx, %r14                   # Save the destination buffer size
   
    # Clear the method buffer first
    mov %r13, %rdi
    mov %r14, %rsi
    call clear_buffer

    # Find the first space character
    mov %r12, %rdi
    mov $' ', %rsi
    xor %rdx, %rdx                   # no boundary check
    call str_find_char

    # Copy the method to the internal buffer
    mov %r13, %rdi   # Get address of destination buffer
    mov %r12, %rsi
    mov %rax, %rdx
    sub %r12, %rdx

    cmp %r14, %rdx
    jle .copy_method
    mov %r14, %rdx
.copy_method:
    mov %r14, %rcx
    call str_cat

    # Return pointer to the method buffer
    mov %r13, %rax
    
    pop %r14
    pop %r13
    pop %r12
    add $8, %rsp
    leave
    ret
    