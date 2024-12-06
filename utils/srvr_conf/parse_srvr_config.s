.section .data
timezone_key: .asciz "TIMEZONE"

segfault_msg: .asciz "Test fault"

.section .text
.type parse_srvr_config, @function
parse_srvr_config:
    push %rbp
    mov %rsp, %rbp
    push %rbx                    # Save preserved registers
    push %r12
    push %r13
    push %r14

    
    # Save buffer pointer to r12
    mov %rdi, %r12

.parse_next_line:
    # Check for end of buffer
    movb (%r12), %al
    test %al, %al
    jz .exit_parse_srvr_config         
    
    # Find '=' in current line, stop at newline
    mov %r12, %rdi              # Current line start
    mov $'=', %rsi              # Character to find
    mov $'\n', %rdx             # Stop at newline
    call str_find_char
    
    # If '=' not found, skip to next line
    cmp $0, %rdx
    je .find_next_line
    
    
    # Save position of '='
    mov %rax, %r13              # Save position of '='
    
    # Temporarily null-terminate the key
    movb (%r13), %r14b         # Save '=' character
    movb $0, (%r13)            # Null-terminate key

    
    # Compare with TIMEZONE key
    mov %r12, %rdi             # First string (key)
    lea timezone_key(%rip), %rsi
    call str_cmp
    cmp $1, %rax
    je .handle_timezone

    
    # Restore '=' character if no match
    movb %r14b, (%r13)
    jmp .find_next_line

.handle_timezone:
    # Restore '=' and point to value
    movb %r14b, (%r13)
    lea 1(%r13), %rdi          # Value after '='
    call str_to_int            # Convert string to integer
    
    # Store timezone value using constant offset
    mov %rax, CONF_TIMEZONE_OFFSET(%r15)
    jmp .find_next_line

.find_next_line:
    # Find next newline or null
    mov %r12, %rdi
    mov $'\n', %rsi            
    xor %rdx, %rdx             # 0 means search until null terminator
    call str_find_char
    
    # If no newline found, we're done
    cmp $0, %rdx
    je .exit_parse_srvr_config
    
    # Move to start of next line
    lea 1(%rax), %r12
    jmp .parse_next_line

.exit_parse_srvr_config:
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret 
