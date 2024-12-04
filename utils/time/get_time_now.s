# Input: rdi = timestamp (seconds since Unix epoch)
# Output: rax = pointer to formatted string "YYYY-MM-DD HH:MM:SS"

.section .data
.include "./utils/time/time_constants.s"

.dash: .string "-"
.colon: .string ":"
.time_separator: .string "T"

.section .bss
.comm date_buffer, 20

.section .text
# Include helper functions
.include "./utils/time/get_timestamp.s"
.include "./utils/time/is_leap_year.s"
.include "./utils/time/get_days_in_month.s"

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

    call get_timestamp
    # STEP 1: CONVERT SECONDS TO DAYS AND REMAINING SECONDS
    # mov %rax, %rdi
    # mov %rdi, %rax
    xor %rdx, %rdx
    mov $86400, %rcx          # Seconds per day
    div %rcx                  # rax = days, rdx = seconds remaining
    mov %rdx, %r12            # Save seconds in r12


    # STEP 2: CALCULATE YEAR
    mov epoch_year(%rip), %rdi
    mov %rdi, %rcx           # Initialize year counter with epoch_year
.year_loop:
    mov %rax, %rsi           # Save days remaining in rsi
    mov %rcx, %rdi          # Put current year in rdi for is_leap_year
    call is_leap_year        # Returns number of days directly in rax
    mov %rax, %rdx          # Move days in year to rdx
    cmp %rsi, %rdx
    jg .found_year
    sub %rdx, %rsi
    mov %rsi, %rax          # Put remaining days back in rax for next iteration
    inc %rcx                # Increment year
    jmp .year_loop
.found_year:
    mov %rcx, %rax          # Year in rax
    mov %rcx, %r13          # Save year in r13

    # STEP 3: CALCULATE MONTH
    mov %rsi, %rdi            # Remaining days in rdi (days within the year)
    mov %r13, %rsi           # Current year for get_days_in_month
    call get_days_in_month    # Get array of days per month for this year
    mov %rax, %rbx           # Pointer to days_per_month array
    xor %rcx, %rcx           # Month index (0-based)
    mov %rdi, %r15           # Save original days for calculations
.month_loop:
    cmp $11, %rcx            # Check if we've gone through all months (0-11)
    jg .found_month          # If we've checked all months, exit
    movzb (%rbx, %rcx), %rdx # Get days in current month
    cmp %r15, %rdx           # Compare with remaining days
    jg .found_month          # If days in month > remaining days, we found our month
    sub %rdx, %r15           # Subtract days of this month
    inc %rcx                 # Move to next month
    jmp .month_loop
.found_month:
    inc %rcx                 # Adjust month to 1-based index
    mov %rcx, %r14           # Save month in r14
    inc %r15                 # Adjust day to 1-based index

    # STEP 4: FORMAT DATE
    # %r12 = remaining seconds
    # %r13 = year
    # %r14 = month
    # %r15 = day

    mov %r13, %rdi
    call int_to_str

    lea date_buffer(%rip), %rdi
    mov %rax, %rsi
    xor %rdx, %rdx
    call str_concat

    lea date_buffer(%rip), %rdi
    lea .dash(%rip), %rsi
    xor %rdx, %rdx
    call str_concat


    mov %r14, %rdi
    call int_to_str

    lea date_buffer(%rip), %rdi
    mov %rax, %rsi
    xor %rdx, %rdx
    call str_concat

    lea date_buffer(%rip), %rdi
    lea .dash(%rip), %rsi
    xor %rdx, %rdx
    call str_concat

    mov %r15, %rdi
    call int_to_str

    lea date_buffer(%rip), %rdi
    mov %rax, %rsi
    xor %rdx, %rdx
    call str_concat

    lea date_buffer(%rip), %rdi
    lea .time_separator(%rip), %rsi
    xor %rdx, %rdx
    call str_concat


    # STEP 5: CALCULATE HOURS, MINUTES, SECONDS
    mov %r12, %rax           # Load remaining seconds into rax
    xor %rdx, %rdx           # Clear rdx for division
    
    mov $3600, %rbx          # Seconds per hour
    div %rbx                 # rax = hours, rdx = remaining seconds
    mov %rax, %r12           # Save hours in r12
    
    mov %rdx, %rax          # Move remaining seconds to rax for next division
    xor %rdx, %rdx          # Clear rdx again
    mov $60, %rbx           # Seconds per minute
    div %rbx                # rax = minutes, rdx = seconds
    mov %rax, %r13          # Save minutes in r13
    mov %rdx, %r14          # Save seconds in r14

   # append hours
    mov %r12, %rdi
    call int_to_str

    lea date_buffer(%rip), %rdi
    mov %rax, %rsi
    xor %rdx, %rdx
    call str_concat

    lea date_buffer(%rip), %rdi
    lea .colon(%rip), %rsi
    xor %rdx, %rdx
    call str_concat

    # append minutes
    mov %r13, %rdi
    call int_to_str

    lea date_buffer(%rip), %rdi
    mov %rax, %rsi
    xor %rdx, %rdx
    call str_concat

    lea date_buffer(%rip), %rdi
    lea .colon(%rip), %rsi
    xor %rdx, %rdx
    call str_concat

    # append seconds
    mov %r14, %rdi
    call int_to_str

    lea date_buffer(%rip), %rdi
    mov %rax, %rsi
    xor %rdx, %rdx
    call str_concat

    lea date_buffer(%rip), %rdi
    lea .colon(%rip), %rsi
    xor %rdx, %rdx
    call str_concat

    lea date_buffer(%rip), %rdi
    xor %rsi, %rsi
    call print_info 

    # Restore non-volatile registers
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    
    pop %rbp
    ret
