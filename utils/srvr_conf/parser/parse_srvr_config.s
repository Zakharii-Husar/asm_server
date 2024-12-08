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

.process_new_line:
    # STEP 1: Skip spaces
    mov %r12, %rdi
    call skip_spaces
    mov %rax, %r12

    # skip newlines
    mov %r12, %rdi
    mov $'\n', %rsi
    call char_cmp
    cmp $1, %rax
    je .skip_line

    # skip tabs
    mov %r12, %rdi
    mov $'\t', %rsi
    call char_cmp
    cmp $1, %rax
    je .skip_line

    # skip spaces
    mov %r12, %rdi
    mov $' ', %rsi
    call char_cmp
    cmp $0, %rax
    je .skipped_spaces
    inc %r12
    jmp .process_new_line
    .skipped_spaces:
    mov %r12, %rdi
    mov $'#', %rsi
    call char_cmp
    cmp $1, %rax
    je .skip_line

.search_for_equal_sign:
    # STEP 3: Look for '=' or '\n'
    # %r12 holds the beginning of the line

    mov %r12, %rdi 
    mov $'=', %rsi # search for '='
    call str_find_char # returns 1 if '=' was found, 0 if not
    cmp $0, %rdx # check if '=' was found
    je .skip_line # if not found, skip line

    mov %r12, %rdi # address of beginning of line
    mov %rax, %rsi # address of '='
    call parse_key_value # parse key-value pair


.skip_line:
    mov %r12, %rdi # address of beginning of line
    mov $'\n', %rsi # search for '\n'
    mov $0, %rdx # boundary check is the end of the buffer
    call str_find_char # returns in %rdx 1 if '\n' was found, 0 if not
    cmp $0, %rdx 
    je .exit_parse_srvr_config # if '\n' was not found and we've reached the end of the buffer, exit
    mov %rax, %r12 # move address of '\n' to r12
    inc %r12 # move to the next character after '\n'
    jmp .process_new_line


.exit_parse_srvr_config:
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret
