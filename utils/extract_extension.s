.section .bss
.lcomm request_file_ext, 32       # Buffer to store file extension (including dot)

.globl extract_extension
.type extract_extension, @function

# Function: extract_extension
# Parameters:
#   %rdi - Pointer to the destination buffer where the file extension will be stored
#   %rsi - Pointer to the route buffer (string) from which the file extension is to be extracted

extract_extension:
    push %rbp
    mov %rsp, %rbp

    push %r12
    mov %rdi, %r12

    # Save %rdi (destination buffer) on the stack

    # Find the dot in the route buffer
    mov $'.', %rdx                  # Character to find (dot)
    call str_find_char              # Call str_find_char with %rsi (route buffer) and %rdx (dot)
    test %rax, %rax                 # Check if dot was found
    jz .no_dot_found                # If not found, jump to no dot found

    # Copy extension (including dot) to destination buffer
    mov %r12, %rdi                  # Restore %rdi (destination buffer)
    mov %rax, %rsi                  # %rax now holds the address of the dot
    xor %rdx, %rdx                  # Let str_concat calculate length
    call str_concat                 # Copy from %rsi (dot position) to %rdi (destination buffer)

    # Convert the destination buffer to lowercase
    mov %r12, %rdi                  # Destination buffer is already in %rdi
    call str_to_lower               # Convert to lowercase

.no_dot_found:

    # Set default extension ".html"
    mov %r12, %rdi                  # Destination buffer is already in %rdi
    mov $".html", %rsi              # Address of default extension string
    call str_concat                 # Copy default extension to %rdi (destination buffer)

.convert_to_lower:

    pop %r12
    pop %rbp
    ret