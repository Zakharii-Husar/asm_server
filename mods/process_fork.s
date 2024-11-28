# Function: process_fork
# Parameters: None
# Return Values: 
#   - Returns 0 on successful fork
#   - Calls exit_program on failure

.section .rodata

PROCESS_FORK_TEST: .asciz "PROCESS_FORK_TEST"

.process_fork_msg:    .asciz "\033[35mProcess was forked ✌️\033[0m\n"
.process_fork_err_msg:    .asciz "\033[31mFailed to fork process! ❌\033[0m\n"

.section .text

.type process_fork, @function
process_fork:
push %rbp                    # save the caller's base pointer
mov %rsp, %rbp               # set the new base pointer (stack frame)


mov $SYS_fork, %rax          # Fork the process
syscall
push %rax
cmp $0, %rax                 # Check if forking was successful
jl .handle_sock_fork_err

 # lea .process_fork_msg(%rip), %rsi
 # call print_info

pop %rax
pop %rbp                     # restore the caller's base pointer
ret                          # return to the caller
 
.handle_sock_fork_err:
 lea .process_fork_err_msg(%rip), %rsi
 call print_info
 call exit_program
 