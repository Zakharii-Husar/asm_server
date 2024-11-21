.section .bss
.lcomm request_file_ext, 32       # Buffer to store file extension (including dot)

.globl extract_route
.type extract_route, @function
extract_route:
    push %rbp
    mov %rsp, %rbp

    # Initialize the route register
    lea request_route(%rip), %rsi     # Destination buffer for route

copy_extension:
    # Copy extension (including dot) to extension buffer
    mov %r10, %rsi                    # %r10 holds beginning of extension
    lea request_file_ext(%rip), %rdi  # Destination is extension buffer
    xor %rdx, %rdx                    # Let str_concat calculate length
    call str_concat

    # Convert route to lowercase
    lea request_route(%rip), %rsi
    call str_to_lower

    # Convert extension to lowercase
    lea request_file_ext(%rip), %rsi
    call str_to_lower

    # Return pointers to request_route and request_file_ext
    lea request_route(%rip), %rax      # Return pointer to request_route
    lea request_file_ext(%rip), %rdx   # Return pointer to request_file_ext

    pop %rbp
    ret