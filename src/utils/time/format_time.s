.section .rodata
 .equ DATE_BUFFER_SIZE, 30

.section .bss
.comm date_buffer, DATE_BUFFER_SIZE

.section .text
.global format_time
.type format_time, @function

# Function: format_time
# Parameters:
#   - %rdi: year
#   - %rsi: month
#   - %rdx: day
#   - %rcx: hours
#   - %r8:  minutes
#   - %r9:  seconds
# Return Values:
#   - %rax: pointer to formatted date string "[YYYY-MM-DD HH:MM:SS]"
#   - %rdx: length of formatted date string
# Error Handling:
#   - None (assumes valid input)
# Side Effects:
#   - Writes to date_buffer
format_time:
    push %rbp
    mov %rsp, %rbp
    # Allocate space for local variables
    sub $40, %rsp
    # Save non-volatile registers
    push %r12
    push %r13
    push %r14
    
    # Save parameters
    mov %r9, %r12           # Save seconds
    mov %r8, %r13           # Save minutes
    mov %rcx, %r14          # Save hours

    mov %rdx, -8(%rbp) # save day
    mov %rsi, -16(%rbp) # save month
    mov %rdi, -24(%rbp) # save year



    # clear buffer
    lea date_buffer(%rip), %rdi
    mov $DATE_BUFFER_SIZE, %rsi
    call clear_buffer
    

    # Start with opening bracket
    lea date_buffer(%rip), %rdi
    lea open_square_bracket_char(%rip), %rsi
    xor %rdx, %rdx
    mov $DATE_BUFFER_SIZE, %rcx
    call str_cat
    
    
    # Convert year to string
    mov -24(%rbp), %rdi # year
    call int_to_str
    mov %rax, %rsi
    lea date_buffer(%rip), %rdi
    xor %rdx, %rdx
    mov $DATE_BUFFER_SIZE, %rcx
    call str_cat
    
    # Add dash after year
    lea date_buffer(%rip), %rdi
    lea dash_char(%rip), %rsi
    xor %rdx, %rdx
    mov $DATE_BUFFER_SIZE, %rcx
    call str_cat
    
    # Format month
    mov -16(%rbp), %rdi # month
    cmp $10, %rdi
    jge .skip_month_pad
    # Add leading zero
    lea date_buffer(%rip), %rdi
    lea zero_char(%rip), %rsi
    xor %rdx, %rdx
    mov $DATE_BUFFER_SIZE, %rcx
    call str_cat
.skip_month_pad:
    mov -16(%rbp), %rdi # month
    call int_to_str
    lea date_buffer(%rip), %rdi
    mov %rax, %rsi
    xor %rdx, %rdx
    mov $DATE_BUFFER_SIZE, %rcx
    call str_cat
    
    
    # Add dash after month
    lea date_buffer(%rip), %rdi
    lea dash_char(%rip), %rsi
    xor %rdx, %rdx
    mov $DATE_BUFFER_SIZE, %rcx
    call str_cat
    
    # Format day
    mov -8(%rbp), %rdi          # day
    cmp $10, %rdi
    jge .skip_day_pad
    lea date_buffer(%rip), %rdi
    lea zero_char(%rip), %rsi
    xor %rdx, %rdx
    mov $DATE_BUFFER_SIZE, %rcx
    call str_cat
    mov -8(%rbp), %rdi
.skip_day_pad:
    call int_to_str
    
    lea date_buffer(%rip), %rdi
    mov %rax, %rsi
    xor %rdx, %rdx
    mov $DATE_BUFFER_SIZE, %rcx
    call str_cat
    
    # Add T separator
    lea date_buffer(%rip), %rdi
    lea time_separator_char(%rip), %rsi
    xor %rdx, %rdx
    mov $DATE_BUFFER_SIZE, %rcx
    call str_cat
    
    # Format hours
    mov %r14, %rdi          # hours
    cmp $10, %rdi
    jge .skip_hour_pad
    lea date_buffer(%rip), %rdi
    lea zero_char(%rip), %rsi
    xor %rdx, %rdx
    mov $DATE_BUFFER_SIZE, %rcx
    call str_cat
    mov %r14, %rdi
.skip_hour_pad:
    call int_to_str
    
    lea date_buffer(%rip), %rdi
    mov %rax, %rsi
    xor %rdx, %rdx
    mov $DATE_BUFFER_SIZE, %rcx
    call str_cat
    
    
    # Add colon after hours
    lea date_buffer(%rip), %rdi
    lea semicolon_char(%rip), %rsi
    xor %rdx, %rdx
    mov $DATE_BUFFER_SIZE, %rcx
    call str_cat
    
    # Format minutes
    mov %r13, %rdi          # minutes
    cmp $10, %rdi
    jge .skip_minute_pad
    lea date_buffer(%rip), %rdi
    lea zero_char(%rip), %rsi
    xor %rdx, %rdx
    mov $DATE_BUFFER_SIZE, %rcx
    call str_cat
    mov %r13, %rdi
.skip_minute_pad:
    call int_to_str
    
    lea date_buffer(%rip), %rdi
    mov %rax, %rsi
    xor %rdx, %rdx
    mov $DATE_BUFFER_SIZE, %rcx
    call str_cat
    
    
    # Add colon after minutes
    lea date_buffer(%rip), %rdi
    lea semicolon_char(%rip), %rsi
    xor %rdx, %rdx
    mov $DATE_BUFFER_SIZE, %rcx
    call str_cat
    
    # Format seconds
    mov %r12, %rdi          # seconds
    cmp $10, %rdi
    jge .skip_second_pad
    lea date_buffer(%rip), %rdi
    lea zero_char(%rip), %rsi
    xor %rdx, %rdx
    mov $DATE_BUFFER_SIZE, %rcx
    call str_cat
    mov %r12, %rdi
.skip_second_pad:
    call int_to_str
    
    lea date_buffer(%rip), %rdi
    mov %rax, %rsi
    xor %rdx, %rdx
    mov $DATE_BUFFER_SIZE, %rcx
    call str_cat


    mov CONF_TIMEZONE_OFFSET(%r15), %rax      # Move the value to check into a register
    cmp $0, %rax        # Compare with 0 (will set SF if %rax is negative)
    js .skip_appending_plus  
    
    lea date_buffer(%rip), %rdi
    lea plus_char(%rip), %rsi
    xor %rdx, %rdx
    mov $DATE_BUFFER_SIZE, %rcx
    call str_cat

    .skip_appending_plus:
    mov CONF_TIMEZONE_OFFSET(%r15), %rdi
    call int_to_str

    mov %rax, %rsi
    lea date_buffer(%rip), %rdi
    mov $DATE_BUFFER_SIZE, %rcx
    xor %rdx, %rdx
    call str_cat

    # Add closing bracket at the end
    lea date_buffer(%rip), %rdi
    lea close_square_bracket_char(%rip), %rsi
    xor %rdx, %rdx
    mov $DATE_BUFFER_SIZE, %rcx
    call str_cat

    # Return pointer to formatted string
    
    lea date_buffer(%rip), %rdi
    call str_len
    mov %rax, %rdx
    lea date_buffer(%rip), %rax
    

    # Restore registers
    pop %r14
    pop %r13
    pop %r12
    add $40, %rsp
    leave
    ret
    