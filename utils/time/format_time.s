.section .data
.dash: .string "-"
.colon: .string ":"
.time_separator: .string "T"
.zero_pad: .string "0"

.section .bss
.comm date_buffer, 20

.section .text
.global format_time
.type format_time, @function

format_time:
    # Input registers:
    # rdi = year
    # rsi = month
    # rdx = day
    # rcx = hours
    # r8 = minutes
    # r9 = seconds
    
    push %rbp
    mov %rsp, %rbp
    # Save non-volatile registers
    push %r12
    push %r13
    push %r14
    push %r15
    
    # Save parameters as specified
    mov %r9, %r12           # Save seconds
    mov %r8, %r13           # Save minutes
    mov %rcx, %r14          # Save hours
    mov %rdx, %r15          # Save day
    push %rsi               # Save month
    
    # Year is already in rdi (no padding needed for year)
    call int_to_str
    
    lea date_buffer(%rip), %rdi
    mov %rax, %rsi
    xor %rdx, %rdx
    call str_concat
    
    # Add dash after year
    lea date_buffer(%rip), %rdi
    lea .dash(%rip), %rsi
    xor %rdx, %rdx
    call str_concat
    
    # Format month
    pop %rsi               # Restore month
    mov %rsi, %rdi
    push %rdi             # Save it again
    cmp $10, %rdi
    jge .skip_month_pad
    # Add leading zero
    lea date_buffer(%rip), %rdi
    lea .zero_pad(%rip), %rsi
    xor %rdx, %rdx
    call str_concat
    pop %rdi
.skip_month_pad:
    call int_to_str
    
    lea date_buffer(%rip), %rdi
    mov %rax, %rsi
    xor %rdx, %rdx
    call str_concat
    
    # Add dash after month
    lea date_buffer(%rip), %rdi
    lea .dash(%rip), %rsi
    xor %rdx, %rdx
    call str_concat
    
    # Format day
    mov %r15, %rdi          # day
    cmp $10, %rdi
    jge .skip_day_pad
    lea date_buffer(%rip), %rdi
    lea .zero_pad(%rip), %rsi
    xor %rdx, %rdx
    call str_concat
    mov %r15, %rdi
.skip_day_pad:
    call int_to_str
    
    lea date_buffer(%rip), %rdi
    mov %rax, %rsi
    xor %rdx, %rdx
    call str_concat
    
    # Add T separator
    lea date_buffer(%rip), %rdi
    lea .time_separator(%rip), %rsi
    xor %rdx, %rdx
    call str_concat
    
    # Format hours
    mov %r14, %rdi          # hours
    cmp $10, %rdi
    jge .skip_hour_pad
    lea date_buffer(%rip), %rdi
    lea .zero_pad(%rip), %rsi
    xor %rdx, %rdx
    call str_concat
    mov %r14, %rdi
.skip_hour_pad:
    call int_to_str
    
    lea date_buffer(%rip), %rdi
    mov %rax, %rsi
    xor %rdx, %rdx
    call str_concat
    
    # Add colon after hours
    lea date_buffer(%rip), %rdi
    lea .colon(%rip), %rsi
    xor %rdx, %rdx
    call str_concat
    
    # Format minutes
    mov %r13, %rdi          # minutes
    cmp $10, %rdi
    jge .skip_minute_pad
    lea date_buffer(%rip), %rdi
    lea .zero_pad(%rip), %rsi
    xor %rdx, %rdx
    call str_concat
    mov %r13, %rdi
.skip_minute_pad:
    call int_to_str
    
    lea date_buffer(%rip), %rdi
    mov %rax, %rsi
    xor %rdx, %rdx
    call str_concat
    
    # Add colon after minutes
    lea date_buffer(%rip), %rdi
    lea .colon(%rip), %rsi
    xor %rdx, %rdx
    call str_concat
    
    # Format seconds
    mov %r12, %rdi          # seconds
    cmp $10, %rdi
    jge .skip_second_pad
    lea date_buffer(%rip), %rdi
    lea .zero_pad(%rip), %rsi
    xor %rdx, %rdx
    call str_concat
    mov %r12, %rdi
.skip_second_pad:
    call int_to_str
    
    lea date_buffer(%rip), %rdi
    mov %rax, %rsi
    xor %rdx, %rdx
    call str_concat
    
    # Return pointer to formatted string
    lea date_buffer(%rip), %rax
    
    # Clean up the stack (month value)
    add $8, %rsp
    
    # Restore registers
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbp
    ret 