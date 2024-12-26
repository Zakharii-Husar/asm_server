.section .data
sigaction:
    .quad handle_sigint     # sa_handler
    .quad 0                 # sa_flags
    .quad 0                 # sa_restorer
    .fill 128,1,0           # sa_mask

.section .rodata
shutdown_msg: .asciz "Server shutting down gracefully...\n"
shutdown_msg_len = . - shutdown_msg

# Constants
.equ SYS_rt_sigaction, 13
.equ SIGINT, 2
.equ SYS_close, 3
.equ SYS_exit, 60

.section .text
.global signal_handler
.type signal_handler, @function
signal_handler:
    push %rbp
    mov %rsp, %rbp

    mov $SYS_rt_sigaction, %rax   # sigaction syscall
    mov $SIGINT, %rdi             # SIGINT signal
    lea sigaction(%rip), %rsi     # new handler
    xor %rdx, %rdx                # old handler (NULL)
    mov $8, %r10                  # sigsetsize
    syscall

    pop %rbp
    ret

handle_sigint:
    # Close the socket using sock_close_conn
    xor %rdi, %rdi       # 0 for parent process
    call sock_close_conn

    # Exit program using exit_program
    xor %rdi, %rdi       # 0 for parent process
    call exit_program
    