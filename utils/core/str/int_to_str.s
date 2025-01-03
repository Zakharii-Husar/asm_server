# Function: int_to_str
# Input:
#   %rdi - integer to convert
# Output:
#   %rax - pointer to the resulting string
#   %rdx - length of the string
# Note: The string is stored in a static buffer and is null-terminated.
.section .rodata
    .equ string_buffer_size, 21

.section .bss
    .lcomm string_buffer, string_buffer_size

.section .text
.type int_to_str, @function
int_to_str:
    push %rbp
    mov %rsp, %rbp
    
    push %r12              # will be used later
    push %r13              # preserve original number
    
    mov %rdi, %r13        # preserve original number

    # Clear buffer
    lea string_buffer(%rip), %rdi
    mov $string_buffer_size, %rsi
    call clear_buffer
    
    # Restore original number
    mov %r13, %rdi
    
    # Rest of conversion logic
    lea string_buffer(%rip), %rsi
    addq $21, %rsi             # Move to end of buffer
    movq $10, %r12             # Divisor (base 10)
    xor %rcx, %rcx             # Reset length counter
    
    # Check if number is negative
    cmpq $0, %rdi
    jge .positive
    
    # Handle negative number
    negq %rdi                  # Make number positive
    movq %rdi, %rax
    
    # Add minus sign at the beginning (not the end)
    movq %rsi, %r8            # Save current buffer position
    movq %rcx, %r9            # Save current length
    
    # Convert number first
.loop_neg:
    decq %rsi                  
    incq %rcx                  
    xor %rdx, %rdx             
    divq %r12                  
    
    addb $'0', %dl            
    movb %dl, (%rsi)          
    testq %rax, %rax          
    jnz .loop_neg

    # Add minus sign before the digits
    decq %rsi
    incq %rcx
    movb $'-', (%rsi)
    jmp .exit_int_to_str

.positive:
    movq %rdi, %rax

.loop:
    decq %rsi                  
    incq %rcx                  
    xor %rdx, %rdx             
    divq %r12                  
    
    addb $'0', %dl            
    movb %dl, (%rsi)          
    testq %rax, %rax          
    jnz .loop                 

.exit_int_to_str:
    movq %rsi, %rax           # Get pointer to start of string
    incq %rcx                 # Increment length to include null terminator
    movb $0, (%rax, %rcx)    # Add null terminator at position rax + rcx
    movq %rcx, %rdx           # Store length

    pop %r13
    pop %r12
    leave
    ret
