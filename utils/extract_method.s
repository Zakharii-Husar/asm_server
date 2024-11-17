.section .data

buffer_size = 8  

.section .bss
.lcomm request_method, buffer_size  

.section .text

# Function: extract_method
# Input: 
#   %rdi - pointer to the request buffer (global)
# Output: none (modifies request_method buffer)
extract_method:
    push %rbp                        # Save the caller's base pointer
    mov %rsp, %rbp                   # Set the new base pointer (stack frame)

    lea request_buffer(%rip), %rsi   # Load address of request string
    lea request_method(%rip), %rdi   # Load address of method buffer
    mov $buffer_size, %rcx           # Max bytes to copy (for safety)
    xor %rdx, %rdx                   # Clear %rdx to use as length counter

copy_method:
    mov (%rsi), %al                  # Load byte from request_string
    cmp $' ', %al                    # Check if it's a space
    je end                           # If space, we've reached the end of the method
    stosb                            # Store byte into method buffer
    inc %rsi                         # Move to next character in source
    inc %rdx                         # Increment the length counter
    dec %rcx                         # Decrease buffer size counter
    jnz copy_method                  # Continue until counter reaches 0 or space is found

end:
    pop %rbp                         # Restore the caller's base pointer
    ret                              # Return to the caller with %rdx holding the method length
