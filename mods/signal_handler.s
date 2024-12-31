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

.section .text
.type signal_handler, @function
signal_handler:
    push %rbp
    mov %rsp, %rbp
    sub $8, %rsp              # align stack to 16-byte boundary

    # Register SIGINT handler with proper restorer
    mov $SYS_rt_sigaction, %rax
    mov $2, %rdi               # SIGINT
    lea sigaction(%rip), %rsi  # new action
    xor %rdx, %rdx            # old action (NULL)
    mov $8, %r10              # sigsetsize
    syscall

    leave                     # restore stack frame
    ret

handle_sigint:
    # Set shutdown flag
    movq $1, server_shutdown_flag(%rip)
    ret

sigreturn:
    mov $SYS_rt_sigreturn, %rax
    syscall
    