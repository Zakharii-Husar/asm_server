.section .rodata
days_per_month:
    .byte 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
days_per_month_leap:
    .byte 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
epoch_year:
    .quad 1970

.section .text

.global get_time_now
.type get_time_now, @function
# Function: get_time_now
# Parameters:
#   - None
# Global Registers:
#   - -16(%rbp): server configuration pointer (for timezone)
# Return Values:
#   - %rax: pointer to formatted timestamp string
#   - %rdx: length of formatted timestamp string
# Error Handling:
#   - None (assumes system time is valid)
# Side Effects:
#   - Calls format_time which modifies date_buffer
get_time_now:
    push %rbp
    mov %rsp, %rbp
    # Allocate space for local variables
    sub $16, %rsp
    # Save non-volatile registers
    push %rbx
    push %r12
    push %r13
    push %r14
    

    call get_timestamp
    mov %rax, %rdi
    call adjust_timezone
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
    mov %rdi, -16(%rbp)           # Save original days for calculations
.month_loop:
    cmp $11, %rcx            # Check if we've gone through all months (0-11)
    jg .found_month          # If we've checked all months, exit
    movzb (%rbx, %rcx), %rdx # Get days in current month
    cmp -16(%rbp), %rdx           # Compare with remaining days
    jg .found_month          # If days in month > remaining days, we found our month
    sub %rdx, -16(%rbp)           # Subtract days of this month
    inc %rcx                 # Move to next month
    jmp .month_loop
.found_month:
    inc %ecx                 # Adjust month to 1-based index (explicitly using 32-bit register)
    mov %rcx, %r14           # Save month in r14
    incl -16(%rbp)           # Adjust day to 1-based index (explicitly using 32-bit memory operation)

    # STEP 5: CALCULATE HOURS, MINUTES, SECONDS
    mov %r12, %rax           # Load remaining seconds into rax
    xor %rdx, %rdx          
    mov $3600, %rbx         
    div %rbx                 # rax = hours, rdx = remaining seconds
    mov %rax, %r10          
    
    mov %rdx, %rax          
    xor %rdx, %rdx          
    mov $60, %rbx           
    div %rbx                # rax = minutes, rdx = seconds
    mov %rax, %r11          
    mov %rdx, %r12          

    # Call format_time with all parameters
    mov %r13, %rdi          # year
    mov %r14, %rsi          # month
    mov -16(%rbp), %rdx          # day
    mov %r10, %rcx          # hours
    mov %r11, %r8           # minutes
    mov %r12, %r9           # seconds
    
    
    call format_time
    
    
    # format_time returns pointer to formatted string in rax
    # Restore non-volatile registers
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    add $16, %rsp       # Deallocate local vars
    leave
    ret
