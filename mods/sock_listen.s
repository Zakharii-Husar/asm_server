.section .rodata

sock_listen_msg:    .asciz "\033[32mTCP Sock is listening 🎧\033[0m\n"
sock_listen_msg_length = . - sock_listen_msg

sock_listen_err_msg:    .asciz "\033[31mSocket failed to listen ❌\033[0m\n"
sock_listen_err_msg_length = . - sock_listen_err_msg

.section .text

# Function: sock_listen
# Parameters:
#   - %rdi: socket file descriptor (fd) to listen on
#   - %rsi: backlog size for the listen queue
# Return Values:
#   - Returns 0 on success (socket is now listening)
#   - Calls exit_program on failure (if listen fails)

.type sock_listen, @function
sock_listen:
 push %rbp                    # save the caller's base pointer
 mov %rsp, %rbp               # set the new base pointer (stack frame)

 mov %rbx, %rdi                         # move socket fd into %rdi (1st arg for bind)
 mov    $SYS_sock_listen, %rax
 mov    $connection_backlog, %rsi
 syscall

 cmp $0, %rax                   # Compare the return value with 0
 jl  handle_sock_listen_err                 # Jump to error handling if %rax < 0
    
 lea sock_listen_msg(%rip), %rsi           # pointer to the message (from constants.s)
 mov $sock_listen_msg_length, %rdx        # length of the message (from constants.s)
 call print_info

 pop %rbp                     # restore the caller's base pointer
 ret                           # return to the caller

handle_sock_listen_err:
 lea sock_listen_err_msg(%rip), %rsi           # pointer to the message (from constants.s)
 mov $sock_listen_err_msg_length, %rdx        # length of the message (from constants.s)
 call print_info
 call exit_program
 