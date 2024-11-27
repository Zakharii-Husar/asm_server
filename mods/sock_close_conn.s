# sock_close_conn.s
.section .rodata

.sock_close_parent_msg:    .asciz "\033[33mParent process was closed 🧔🔒\033[0m\n"
.sock_close_parent_msg_length = . - .sock_close_parent_msg

.sock_close_parent_err_msg:    .asciz "\033[31mFailed to close parent process! ❌\033[0m\n"
.sock_close_parent_err_msg_length = . - .sock_close_parent_err_msg

.sock_close_child_msg:    .asciz "\033[33mChild process was closed 👶🔒\033[0m\n"
.sock_close_child_msg_length = . - .sock_close_child_msg

.sock_close_child_err_msg:    .asciz "\033[31mFailed to close child process! ❌\033[0m\n"
.sock_close_child_err_msg_length = . - .sock_close_child_err_msg


.section .text

# Function: sock_close_conn
# Parameters:
#   - %rdi: Connection file descriptor (0 for parent, 1 for child)
# Return Values:
#   - Returns 0 on successful closure of the connection
#   - Calls exit_program on failure

.type sock_close_conn, @function
sock_close_conn:

push %rbp                                           # save the caller's base pointer
mov %rsp, %rbp                                      # set the new base pointer (stack frame)


mov    %r13, %rdi                                   # connection file descriptor
mov    $SYS_close, %rax                             # sys_close (system call number for closing a file descriptor: 3)
syscall                                             # close the connection

 cmp $0, %rdi                                       # 0 for parent process, 1 for child
 
 je .handle_sock_close_parent
 #  handle_sock_close_child:
  cmp $0, %rax                                      # Compare the return value with 0
 jl  handle_sock_close_child_err                    # Jump to error handling if %rax < 0

 lea .sock_close_child_msg(%rip), %rsi               # pointer to the message (from constants.s)
 mov $.sock_close_child_msg_length, %rdx             # length of the message (from constants.s)
 call print_info

 .handle_sock_close_parent:
 cmp $0, %rax                                       # Compare the return value with 0
 jl  .handle_sock_close_parent_err                   # Jump to error handling if %rax < 0
    
 lea .sock_close_parent_msg(%rip), %rsi              # pointer to the message (from constants.s)
 mov $.sock_close_parent_msg_length, %rdx            # length of the message (from constants.s)
 call print_info


pop %rbp                                             # restore the caller's base pointer
ret                                                  # return to the caller

.handle_sock_close_parent_err:
 lea .sock_close_parent_err_msg(%rip), %rsi           # pointer to the message (from constants.s)
 mov $.sock_close_parent_err_msg_length, %rdx         # length of the message (from constants.s)
 call print_info
 call exit_program

 handle_sock_close_child_err:
 lea .sock_close_child_err_msg(%rip), %rsi            # pointer to the message (from constants.s)
 mov $.sock_close_child_err_msg_length, %rdx          # length of the message (from constants.s)
 call print_info
 call exit_program
