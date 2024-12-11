.section .data

.base_path: .asciz "./public"
.index_str: .asciz "index"
.html_ext: .asciz ".html"
.slash: .asciz "/"

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


    # 1. Write base_path to destination
    mov %r12, %rdi           # dest buffer
    lea CONF_PUBLIC_DIR_OFFSET(%r15), %rsi  
    xor %rdx, %rdx          
    call str_concat

    # 2. Concat route to destination
    mov %r12, %rdi
    mov %r13, %rsi
    xor %rdx, %rdx
    call str_concat

    # 3. Check if route is just "/"
    mov %r13, %rdi
    lea .slash(%rip), %rsi
    call str_cmp
    cmp $0, %rax
    je .check_extension

    # If route is "/", append "index"
    mov %r12, %rdi
    lea .index_str(%rip), %rsi
    xor %rdx, %rdx
    call str_concat
    jmp .append_extension

.check_extension:
    # 4. Search for dot in route
    mov %r13, %rdi
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
    call str_concat

.exit_build_path:

    pop %r13
    pop %r12
    pop %rbp
    ret
