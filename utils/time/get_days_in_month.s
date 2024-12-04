.section .text
.global get_days_in_month
.type get_days_in_month, @function

# Input: rdi = Current year
# Output: rax = pointer to appropriate days_per_month array
.global get_days_in_month
.type get_days_in_month, @function
get_days_in_month:
    push %rbp
    mov %rsp, %rbp
    mov %rdi, %rdi
    call is_leap_year
    test %rax, %rax
    jz .normal_month
    lea days_per_month_leap(%rip), %rax
    jmp .get_days_in_month_end
    
.normal_month:
    lea days_per_month(%rip), %rax

.get_days_in_month_end:
    pop %rbp
    ret
