.section .rodata
    .equ CONFIG_KEY_SIZE, 20
    .equ CONFIG_VALUE_SIZE, 20

.section .bss
.lcomm config_key, CONFIG_KEY_SIZE
.lcomm config_value, CONFIG_VALUE_SIZE

.section .text
.type parse_srvr_config, @function
# Function: parse_srvr_config
# Parameters:
#   - %rdi: pointer to configuration file buffer
# Global Registers:
#   - %r15: server configuration pointer
# Return Values:
#   - None
# Error Handling:
#   - Skips invalid lines
#   - Skips comments and empty lines
# Side Effects:
#   - Modifies config_key and config_value buffers
#   - Calls write_config_struct to update server configuration
parse_srvr_config:
    push %rbp
    mov %rsp, %rbp
    push %r12
    push %r13
    

    mov %rdi, %r12              # Buffer pointer
.process_new_line:
    # Clear config_key and config_value buffers
    lea config_key(%rip), %rdi
    mov $CONFIG_KEY_SIZE, %rsi
    call clear_buffer

    lea config_value(%rip), %rdi
    mov $CONFIG_VALUE_SIZE, %rsi
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
    mov $CONFIG_KEY_SIZE, %rcx
    call str_cat

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
    dec %rdx                     # subtract 1 to exclude the space
    mov $CONFIG_VALUE_SIZE, %rcx
    call str_cat
    

    lea config_key(%rip), %rdi
    lea config_value(%rip), %rsi
    call write_config_struct


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

    pop %r13
    pop %r12
    leave                     # restore stack frame
    ret
