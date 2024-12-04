# Input: rdi = timestamp (seconds since Unix epoch)
# Output: rax = pointer to formatted string "YYYY-MM-DD HH:MM:SS"

.section .data
.include "time_constants.s"
date_buffer: .space 20      # Buffer for final "YYYY-MM-DD HH:MM:SS"
dash: .ascii "-"            # Separators
colon: .ascii ":"
space: .ascii " "

.section .text
# Include helper functions
.include "get_timestamp.s"
.include "is_leap_year.s"
.include "get_days_in_month.s"

.global get_time_now
.type get_time_now, @function
get_time_now:
    push %rbp
    mov %rsp, %rbp
    # Save non-volatile registers
    push %r12
    push %r13
    push %r14
    push %r15

    # STEP 1: CONVERT SECONDS TO DAYS AND REMAINING SECONDS
    mov %rdi, %rax
    xor %rdx, %rdx
    mov $86400, %rcx          # Seconds per day
    div %rcx                  # rax = days, rdx = seconds remaining
    mov %rdx, %r12            # Save seconds in r12

    # STEP 2: CALCULATE YEAR
    mov epoch_year(%rip), %rdi
.year_loop:
    mov %rax, %rsi            # Save days remaining in rsi
    call is_leap_year         # Returns number of days directly in rax
    mov %rax, %rdx            # Move days in year to rdx
    cmp %rsi, %rdx
    jg .found_year
    sub %rdx, %rsi
    inc %rcx                  # Increment year
    jmp .year_loop
.found_year:
    mov %rcx, %rax            # Year in rax
    mov %rcx, %r13            # Save year in r13

    # STEP 3: CALCULATE MONTH
    mov %rsi, %rdi            # Remaining days in rdi
    mov %rcx, %rdi            # Move year to rdi before calling
    call get_days_in_month    # Now correctly passing year in rdi
    mov %rax, %rbx            # Pointer to days_per_month array
    xor %rcx, %rcx            # Month index
.month_loop:
    movzb (%rbx, %rcx), %rdx  # Correctly zero-extend the byte to 64-bit
    cmp %rdi, %rdx
    jl .found_month
    sub %rdx, %rdi
    inc %rcx
    jmp .month_loop
.found_month:
    inc %rcx                  # Adjust month to 1-based index
    mov %rcx, %r14            # Save month in r14
    mov %rdi, %r15            # Save remaining days in r15

    # STEP 4: CALCULATE HOURS, MINUTES, SECONDS
    mov %r15, %rdi            # Day
    mov %r14, %rcx            # Month
    mov %r13, %rax            # Year
    mov %r12, %rdx            # Remaining seconds

    mov $3600, %rbx           # Seconds per hour
    div %rbx                  # rax = hours, rdx = remaining seconds
    mov %rax, %r12            # Save hours in r12 (reusing r12 since seconds no longer needed)

    mov $60, %rbx             # Seconds per minute
    div %rbx                  # rax = minutes, rdx = seconds
    mov %rax, %r13            # Save minutes in r13 (reusing r13)
    mov %rdx, %r14            # Save seconds in r14 (reusing r14)

    # STEP 5: FORMAT THE DATE AND TIME
    # Values in registers:
    # Year in %rax
    # Month in %rcx
    # Day in %rdi
    # Hours in %r12
    # Minutes in %r13
    # Seconds in %r14

    # Initialize date_buffer
    lea date_buffer(%rip), %r15    # r15 will hold our buffer address
    mov %r15, %rdi
    xor %rsi, %rsi
    mov $20, %rdx
    
    # Convert and concatenate year
    push %rax
    push %rcx
    push %rdi
    mov %rax, %rdi
    call int_to_str              # Convert year to string
    mov %r15, %rdi              # destination buffer
    # rsi already has the string pointer from int_to_str
    call str_concat
    pop %rdi
    pop %rcx
    pop %rax

    # Add dash
    mov %r15, %rdi
    lea dash(%rip), %rsi
    mov $1, %rdx
    call str_concat

    # Convert and concatenate month
    push %rax
    push %rdi
    mov %rcx, %rdi
    call int_to_str
    mov %r15, %rdi
    call str_concat
    pop %rdi
    pop %rax

    # Add dash
    mov %r15, %rdi
    lea dash(%rip), %rsi
    mov $1, %rdx
    call str_concat

    # Convert and concatenate day
    push %rax
    push %rcx
    mov %rdi, %rdi              # Day already in rdi
    call int_to_str
    mov %r15, %rdi
    call str_concat
    pop %rcx
    pop %rax

    # Add space
    mov %r15, %rdi
    lea space(%rip), %rsi
    mov $1, %rdx
    call str_concat

    # Convert and concatenate hours
    push %rax
    mov %r12, %rdi
    call int_to_str
    mov %r15, %rdi
    call str_concat
    pop %rax

    # Add colon
    mov %r15, %rdi
    lea colon(%rip), %rsi
    mov $1, %rdx
    call str_concat

    # Convert and concatenate minutes
    push %rax
    mov %r13, %rdi
    call int_to_str
    mov %r15, %rdi
    call str_concat
    pop %rax

    # Add colon
    mov %r15, %rdi
    lea colon(%rip), %rsi
    mov $1, %rdx
    call str_concat

    # Convert and concatenate seconds
    push %rax
    mov %r14, %rdi
    call int_to_str
    mov %r15, %rdi
    call str_concat
    pop %rax

    # Return pointer to formatted string
    mov %r15, %rax

    # Restore non-volatile registers
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    
    pop %rbp
    ret