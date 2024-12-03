.section .text
# Input: rcx = year to check
# Output: rax = 1 if leap year, 0 if not
.global is_leap_year
.type is_leap_year, @function
is_leap_year:
    push %rbp
    mov %rsp, %rbp
    mov %rcx, %rax
    xor %rdx, %rdx
    mov $4, %rbx
    div %rbx
    test %rdx, %rdx
    jnz .not_leap
    mov %rcx, %rax
    xor %rdx, %rdx
    mov $100, %rbx
    div %rbx
    test %rdx, %rdx
    jnz .leap
    mov %rcx, %rax
    xor %rdx, %rdx
    mov $400, %rbx
    div %rbx
    test %rdx, %rdx
    jz .leap
.not_leap:
    xor %rax, %rax
    jmp .is_leap_year_end
.leap:
    mov $1, %rax

.is_leap_year_end:
    pop %rbp
    ret
