.section .data
timezone_key: .asciz "TIMEZONE"

.section .text
.type parse_srvr_config, @function
parse_srvr_config:
    push %rbp
    mov %rsp, %rbp
    push %rbx                    # Save preserved registers
    push %r12
    push %r13
    push %r14

    mov %rdi, %r12              # Buffer pointer
    mov %rsi, %rbx              # File size
    
    # Calculate end of buffer address
    lea (%rdi, %rsi), %r14      # r14 = buffer_start + size (points to one past last valid byte)
    
.parse_next_line:
    # Check if we've reached or passed buffer end
    cmp %r14, %r12
    jge .exit_parse_srvr_config
    
    # Find '=' in current line, stop at newline
    mov %r12, %rdi              # Current line start
    mov $'=', %rsi              # Character to find
    mov $'\n', %rdx             # Stop at newline
    call str_find_char
    
    # If '=' not found and no newline found (rdx = 0), we're at end of buffer
    cmp $0, %rdx
    je .exit_parse_srvr_config
    
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

.find_next_line:
    # Find next newline or null
    mov %r12, %rdi
    mov $'\n', %rsi            
    xor %rdx, %rdx             # 0 means search until null terminator
    call str_find_char
    
    # If no newline found (rdx = 0), we're done after processing this line
    cmp $0, %rdx
    je .exit_parse_srvr_config
    
    # Move to start of next line
    lea 1(%rax), %r12
    
    # Check if new position is past buffer end
    cmp %r14, %r12
    jge .exit_parse_srvr_config
    
    jmp .parse_next_line

.handle_timezone:
    # Restore '=' and point to value
    movb %r14b, (%r13)
    lea 1(%r13), %rdi          # Value after '='
    call str_to_int            # Convert string to integer
    mov %rax, CONF_TIMEZONE_OFFSET(%r15)
    jmp .find_next_line

.exit_parse_srvr_config:
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret 
