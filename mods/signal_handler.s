# Add syscall definitions at the top
.equ SYS_rt_sigaction, 13
.equ SYS_rt_sigreturn, 15
.equ SA_RESTORER, 0x04000000

.section .data
.align 8
.global server_shutdown_flag    
server_shutdown_flag:
    .quad 0                    

# Signal handler setup structure with proper flags and restorer
sigaction:
    .quad handle_sigint        # sa_handler
    .quad SA_RESTORER         # sa_flags
    .quad sigreturn           # sa_restorer
    .quad 0                   # sa_mask[0]
    .fill 15,8,0             # rest of sa_mask

debug_msg: .asciz "Signal caught!\n"
debug_msg_len = . - debug_msg

.section .text
.global signal_handler
signal_handler:
    # Register SIGINT handler with proper restorer
    mov $SYS_rt_sigaction, %rax
    mov $2, %rdi               # SIGINT
    lea sigaction(%rip), %rsi  # new action
    xor %rdx, %rdx            # old action (NULL)
    mov $8, %r10              # sigsetsize
    syscall
    ret

handle_sigint:
    # Write debug message first
    mov $1, %rax              # sys_write
    mov $2, %rdi              # stderr
    lea debug_msg(%rip), %rsi
    mov $debug_msg_len, %rdx
    syscall

    # Set shutdown flag
    movq $1, server_shutdown_flag(%rip)
    ret

sigreturn:
    mov $SYS_rt_sigreturn, %rax
    syscall
    