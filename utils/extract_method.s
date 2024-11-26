
.section .bss
.lcomm req_method_B, req_method_B_size  

.section .text

# Function: extract_method
# Input: 
#   %rsi - pointer to the request buffer (source)
# Output: 
#   %rax - pointer to the extracted method string
extract_method:
    push %rbp
    mov %rsp, %rbp
    push %r12

    mov %rsi, %r12                   # Save the source pointer

    # Find the first space character
    mov %r12, %rdi
    mov $' ', %rsi
    call str_find_char

    # Copy the method to the internal buffer
    lea req_method_B(%rip), %rdi   # Get address of internal buffer
    mov %r12, %rsi
    mov %rax, %rdx
    sub %r12, %rdx
    
    cmp $req_method_B_size, %rdx
    jle .copy_method
    mov $req_method_B_size, %rdx
.copy_method:
    call str_concat

    # Return pointer to the method buffer
    lea req_method_B(%rip), %rax

    pop %r12
    pop %rbp
    ret
