.section .bss
.lcomm request_method, request_method_buffer_size  

.section .text

# Function: extract_method
# Input: 
#   %rdi - pointer to the method buffer (destination)
#   %rsi - pointer to the request buffer (source)
# Output: none (modifies method buffer)
extract_method:
    push %rbp                        # Save the caller's base pointer
    mov %rsp, %rbp                   # Set the new base pointer (stack frame)
    push %r12                        # Save the destination pointer
    push %r13                        # Save the source pointer
    
    # Preserve the original pointers
    mov %rdi, %r12                   # Pointer to the destination buffer
    mov %rsi, %r13                   # Pointer to the source buffer

    # Find the first space character
    mov %r13, %rdi                   # Move request buffer to first param
    mov $' ', %rsi                   # Space character to find
    call str_find_char               # Find the space

    # Copy the method to the buffer
    mov %r12, %rdi                   # Move destination buffer to first param
    mov %r13, %rsi                   # Move source buffer to second param
    mov %rax, %rdx                   # Move length to third param
    sub %r13, %rdx                   # Calculate length (end - start)
    
    # Length check
    cmp $request_method_buffer_size, %rdx
    jle safe_to_copy                 # If length <= buffer size, proceed
    mov $request_method_buffer_size, %rdx  # Otherwise, truncate to buffer size
safe_to_copy:
    call str_concat                  # Copy the method to the buffer

    pop %r13                         # Restore the source pointer
    pop %r12                         # Restore the destination pointer
    pop %rbp                         # Restore the caller's base pointer
    ret                             # Return to the caller
