.section .data

.index_str: .asciz "index"
.html_ext: .asciz ".html"

.section .text
.globl extract_route
.type build_file_path, @function
build_file_path:
# Parameters:
#   - %rdi: Destination buffer for the complete file path
#   - %rsi: Request route buffer (already extracted route)
# Returns:
#   - void
    push %rbp
    mov %rsp, %rbp
    
    # Save registers we'll use
    push %r12
    push %r13
    
    # Preserve our parameters
    mov %rdi, %r12   # dest buffer
    mov %rsi, %r13   # route buffer

    # 1. Write base path to destination
    mov %r12, %rdi           # dest buffer
    lea CONF_PUBLIC_DIR_OFFSET(%r15), %rsi  
    xor %rdx, %rdx
    mov $file_path_B_size, %rcx
    call str_cat

    # 2. Concat route to destination
    mov %r12, %rdi
    mov %r13, %rsi
    xor %rdx, %rdx
    mov $file_path_B_size, %rcx
    call str_cat

    # 3. Check if route is just "/"
    mov %r13, %rdi
    lea slash_char(%rip), %rsi
    call str_cmp
    cmp $0, %rax
    je .check_extension

    # If route is "/", append default file name
    mov %r12, %rdi           # dest buffer
    lea CONF_DEFAULT_FILE_OFFSET(%r15), %rsi  
    xor %rdx, %rdx
    mov $file_path_B_size, %rcx
    call str_cat

.check_extension:
    # 4. Search for dot in the destination buffer
    
    mov %r12, %rdi
    inc %rdi # skip the first dot in the base path
    mov $'.', %rsi
    xor %rdx, %rdx       # no boundary check
    call str_find_char
    cmp $1, %rdx

    je  .exit_build_path


.append_extension:
    # 5. If no extension found (str_find_char  returned 0), append .html
    mov %r12, %rdi
    lea .html_ext(%rip), %rsi
    xor %rdx, %rdx
    mov $file_path_B_size, %rcx
    call str_cat

.exit_build_path:
    pop %r13
    pop %r12
    leave
    ret
    