# Input: rdi = timestamp (seconds since Unix epoch)
# Output: rax = pointer to formatted string "YYYY-MM-DD HH:MM:SS"

.section .data
.include "time_constants.s"

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
    # STEP 1: CONVERT SECONDS TO DAYS AND REMAINING SECONDS
    mov %rdi, %rax
    xor %rdx, %rdx
    mov $86400, %rcx          # Seconds per day
    div %rcx                  # rax = days, rdx = seconds remaining
    sub $8, %rsp              # Align stack to 16 bytes
    push %rdx                 # Save seconds for later use

    # STEP 2: CALCULATE YEAR
    mov epoch_year(%rip), %rcx # Load starting year 1970
.year_loop:
    mov %rax, %rsi            # Save days remaining in rsi
    call is_leap_year          # Check if current year is leap year (result in rax)
    testq %rax, %rax
    jz .normal_year
    mov $366, %rdx
    jmp .check_year
.normal_year:
    mov $365, %rdx
.check_year:
    cmp %rsi, %rdx
    jl .found_year
    sub %rdx, %rsi
    inc %rcx                  # Increment year
    jmp .year_loop
.found_year:
    mov %rcx, %rax            # Year in rax
    push %rax                 # Save year for later

    # STEP 3: CALCULATE MONTH
    mov %rsi, %rdi            # Remaining days in rdi
    call get_days_in_month     # Select days_per_month or days_per_month_leap
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
    push %rcx                 # Save month
    push %rdi                 # Save remaining days

    # STEP 4: CALCULATE HOURS, MINUTES, SECONDS
    pop %rdi                  # Day
    pop %rcx                  # Month
    pop %rax                  # Year
    pop %rdx                  # Remaining seconds

    mov $3600, %rbx           # Seconds per hour
    div %rbx                  # rax = hours, rdx = remaining seconds
    push %rax                 # Save hours

    mov $60, %rbx             # Seconds per minute
    div %rbx                  # rax = minutes, rdx = seconds
    push %rax                 # Save minutes
    push %rdx                 # Save seconds

    # STEP 5: FORMAT THE DATE AND TIME
    pop %rsi                  # Seconds
    pop %rdx                  # Minutes
    pop %rbx                  # Hours
    # rdi = Day, rcx = Month, rax = Year, rbx = Hours, rdx = Minutes, rsi = Seconds

    # Here you would format the date and time into a string
    # This part is omitted for brevity

    add $8, %rsp              # Restore stack alignment
    
    pop %rbp
    ret