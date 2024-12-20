# Function: int_to_str
# Input:
#   %rdi - integer to convert
# Output:
#   %rax - pointer to the resulting string
#   %rdx - length of the string
# Note: The string is stored in a static buffer and is not null-terminated.
.section .data
    .equ string_buffer_size, 21

.section .bss
    .lcomm string_buffer, string_buffer_size

.section .text
.type int_to_str, @function
int_to_str:
    # Proper stack frame setup
    push %rbp
    mov %rsp, %rbp
    
    # Save important registers we'll need later
    pushq %rbx
    pushq %rdi        # Save original input number
    
    # Clear buffer
    lea string_buffer(%rip), %rdi
    mov $string_buffer_size, %rsi
    call clear_buffer
    
    # Restore original number
    popq %rdi
    
    # Rest of your conversion logic
    lea string_buffer(%rip), %rsi
    addq $21, %rsi             # Move to end of buffer
    movq $10, %rbx             # Divisor (base 10)
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
    divq %rbx                  
    
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
    divq %rbx                  
    
    addb $'0', %dl            
    movb %dl, (%rsi)          
    testq %rax, %rax          
    jnz .loop                 

.exit_int_to_str:
    movq %rsi, %rax           
    movq %rcx, %rdx           
    
    # Add null termination
    # will uncomment later
    # movb $0, (%rsi, %rcx, 1)  # Add null byte at end of string
    
    # Proper stack frame cleanup
    pop %rbx
    pop %rbp
    ret
