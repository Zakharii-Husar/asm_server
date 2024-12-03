.section .data
    UTC_stamp: .quad 0       # 8-byte buffer to store time value

.section .text
.global get_timestamp

# Function: get_timestamp
# Returns: %rax - current time in seconds since epoch
.type get_timestamp, @function
get_timestamp:
    push %rbp
    mov %rsp, %rbp

    # Make time syscall
    mov $SYS_time, %rax          # time syscall number
    lea UTC_stamp(%rip), %rdi  # pointer to buffer where time will be stored
    syscall                  # stores result in buffer and returns 0 in %rax on success

    # Load the actual time value into %rax to return it
    mov UTC_stamp(%rip), %rax

    mov %rbp, %rsp
    pop %rbp
    ret
