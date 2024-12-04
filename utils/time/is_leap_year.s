.section .text
# Input: rdi = year to check
# Output: rax = number of days in year (365 or 366)

# A year is a leap year if:
# It is divisible by 4, and
# If divisible by 100, 
# must also be divisible by 400

.global is_leap_year
.type is_leap_year, @function
is_leap_year:
    push %rbp
    mov %rsp, %rbp

    mov %rdi, %rax
    xor %rdx, %rdx
    mov $4, %rbx
    div %rbx
    test %rdx, %rdx
    jnz .not_leap

    mov %rdi, %rax
    xor %rdx, %rdx
    mov $100, %rbx
    div %rbx
    test %rdx, %rdx
    jnz .leap
    mov %rdi, %rax
    xor %rdx, %rdx
    
    mov $400, %rbx
    div %rbx
    test %rdx, %rdx
    jz .leap

.not_leap:
    mov $365, %rax
    jmp .is_leap_year_end
.leap:
    mov $366, %rax

.is_leap_year_end:
    pop %rbp
    ret
