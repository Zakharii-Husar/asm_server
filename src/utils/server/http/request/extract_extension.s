.section .rodata

default_extension: .asciz ".html"

.section .text

.globl extract_extension
.type extract_extension, @function
# Function: extract_extension
# Parameters:
#   - %rdi: pointer to file path
# Return Values:
#   - %rax: pointer to extracted extension string
# Error Handling:
#   - Returns pointer to empty string if no extension found
# Side Effects:
#   - Modifies extension_buffer
extract_extension:
    push %rbp
    mov %rsp, %rbp
    # Preserve non-volatile registers
    push %r12
    push %r13
    # Save arguments
    mov %rdi, %r12 # Destination buffer
    mov %rsi, %r13 # Route buffer

    # Skip the first character in a file path (./public/...)
    cmpb $'.', (%r13)              # Check if first char is a dot
    jne .find_extension            # If not a dot, proceed normally
    inc %r13                       # If it is a dot, skip it

.find_extension:
    # Find the dot in the route buffer (starting after first char)
    mov %r13, %rdi
    mov $'.', %rsi                  # Character to find (dot)
    xor %rdx, %rdx                  # no boundary check
    call str_find_char              # Call str_find_char with %rsi (route buffer) and %rdx (dot)
    test %rdx, %rdx                 # Check if dot was found
    jz .no_dot_found                # If not found, jump to no dot found

    # Copy extension (including dot) to destination buffer
    mov %r12, %rdi                  # Restore %rdi (destination buffer)
    mov %rax, %rsi                  # %rax now holds the address of the dot
    xor %rdx, %rdx                  # Let str_cat calculate length
    mov $extension_B_size, %rcx
    call str_cat                 # Copy from %rsi (dot position) to %rdi (destination buffer)

    # Convert the destination buffer to lowercase
    mov %r12, %rdi                  # Destination buffer is already in %rdi
    call str_to_lower               # Convert to lowercase
    jmp .exit_extract_extension                     # Skip the default extension part

.no_dot_found:
    # Set default extension ".html"
    mov %r12, %rdi                  # Destination buffer is already in %rdi
    lea default_extension(%rip), %rsi              # Address of default extension string
    xor %rdx, %rdx
    mov $extension_B_size, %rcx
    call str_cat                 # Copy default extension to %rdi (destination buffer)

.exit_extract_extension:
    pop %r13
    pop %r12
    leave
    ret
    