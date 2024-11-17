# Function: int_to_string
# Input:
#   %rdi - integer to convert
# Output:
#   %rax - pointer to the resulting string
#   %rdx - length of the string
# Note: The string is stored in a static buffer and is not null-terminated.

.section .bss
    .lcomm string_buffer, 21     # 21 bytes for safety

.section .text
.type int_to_string, @function
int_to_string:
    pushq %rbp
    mov %rsp, %rbp
    push %rcx

    lea string_buffer(%rip), %rsi
    addq $21, %rsi             # Move to end of buffer
    movq $10, %rbx             # Divisor (base 10)
    xor %rcx, %rcx             # Reset length counter

    # Remove the null terminator initialization
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

    movq %rsi, %rax           
    movq %rcx, %rdx           
    
    pop %rcx
    pop %rbp                  

    ret                       
