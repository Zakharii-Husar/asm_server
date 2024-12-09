.section .data

equal_sign: .asciz "="
n_line: .asciz "\n"

.section .bss
.lcomm config_key, 20
.lcomm config_value, 20

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

    # Clear config_key and config_value buffers
    lea config_key(%rip), %rdi
    mov $20, %rsi
    call clear_buffer

    lea config_value(%rip), %rdi
    mov $20, %rsi
    call clear_buffer
    
    # STEP 1: Skip spaces
    .skip_spaces:
    mov (%r12), %rdi
    mov $' ', %rsi
    call char_cmp
    cmp $0, %rax
    je .skip_empty_line
    inc %r12
    jmp .skip_spaces


    # STEP 2: Skip empty lines
    .skip_empty_line:
    mov (%r12), %rdi
    mov $'\n', %rsi
    call char_cmp
    cmp $1, %rax
    je .skip_current_line

    # STEP 3: Skip tabs
    mov (%r12), %rdi
    mov $'\t', %rsi
    call char_cmp
    cmp $1, %rax
    je .skip_current_line

    # STEP 4: Skip comments
    mov (%r12), %rdi
    mov $'#', %rsi
    call char_cmp
    cmp $1, %rax
    je .skip_current_line


.search_for_equal_sign:
    
    # STEP 3: Look for '=' or '\n'
    # %r12 holds the beginning of the line
    # 3.1. Save beginning of key

    # 3.2. Look for '='
    mov %r12, %rdi
    mov $'=', %rsi # search for '='
    mov $' ', %rdx # boundary check is the end of the line
    call str_find_char # returns 1 if '=' was found, 0 if not
    cmp $0, %rdx # check if '=' was not found
    je .skip_current_line # if not found, skip line

    # 3.3. Save the address of '='
    mov %r12, %rdi # address of beginning of line
    mov %r12, %rdi # address of beginning of line
    mov %rax, %r13 # the address of '='

    # 3.4. Save key
    lea config_key(%rip), %rdi    # destination for key
    mov %r12, %rsi               # source (beginning of key)
    mov %r13, %rdx               # address of '='
    sub %r12, %rdx               # calculate length (end - start)
    call str_concat

    # 3.5. Find the end of the value
    mov %r13, %rdi
    mov $' ', %rsi
    mov $'\n', %rdx
    call str_find_char

    # 3.6. Save value
    lea config_value(%rip), %rdi # destination for value
    mov %r13, %rsi               # source (beginning of value)
    inc %rsi                     # move to the next character after '='
    mov %rax, %rdx               # address of ' ' or '\n'
    sub %r13, %rdx               # calculate length (end - start)
    call str_concat

    lea config_key(%rip), %rdi
    lea config_value(%rip), %rsi
    call parse_key_value


.skip_current_line:
    mov %r12, %rdi           # address of current position
    mov $'\n', %rsi          # search for '\n'
    mov $0, %rdx             # boundary check
    call str_find_char       # returns in %rdx 1 if '\n' was found, 0 if not
    cmp $0, %rdx 
    je .exit_parse_srvr_config  # if '\n' was not found, exit
    mov %rax, %r12           # move address of '\n' to r12
    inc %r12                 # move to the next character after '\n'
    jmp .process_new_line    # start fresh with the new line


.exit_parse_srvr_config:
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    pop %rbp
    ret
