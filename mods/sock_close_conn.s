.section .rodata

sock_close_parent_err_msg:    .asciz "Faied to close parent connection!\n"
sock_close_parent_err_msg_length = . - sock_close_parent_err_msg

sock_close_parent_msg:    .asciz "Parent connection was closed\n"
sock_close_parent_msg_length = . - sock_close_parent_msg

sock_close_child_err_msg:    .asciz "Faied to close child connection!\n"
sock_close_child_err_msg_length = . - sock_close_child_err_msg

sock_close_child_msg:    .asciz "Child connection was closed\n"
sock_close_child_msg_length = . - sock_close_child_msg

.section .text

.type sock_close_conn, @function
sock_close_conn:

pushq %rbp                    # save the caller's base pointer
movq %rsp, %rbp               # set the new base pointer (stack frame)

movq    %rdi, %rdi           # socket file descriptor
movq    $SYS_close_fd, %rax             # sys_close (system call number for closing a file descriptor: 3)
syscall                      # close the connection

 cmpq $0, %rdi                   # 0 for parent process, 1 for child
 jg handle_sock_close_parent
 #  handle_sock_close_child:
  cmpq $0, %rax                                    # Compare the return value with 0
 jl  handle_sock_close_child_err                 # Jump to error handling if %rax < 0

 lea sock_close_child_msg(%rip), %rsi           # pointer to the message (from constants.s)
 movq $sock_close_child_msg_length, %rdx        # length of the message (from constants.s)
 call print_info

 handle_sock_close_parent:
 cmpq $0, %rax                                    # Compare the return value with 0
 jl  handle_sock_close_parent_err                 # Jump to error handling if %rax < 0
    
 lea sock_close_parent_msg(%rip), %rsi           # pointer to the message (from constants.s)
 movq $sock_close_parent_msg_length, %rdx        # length of the message (from constants.s)
 call print_info

popq %rbp                     # restore the caller's base pointer
ret                           # return to the caller

handle_sock_close_parent_err:
 lea sock_close_parent_err_msg(%rip), %rsi           # pointer to the message (from constants.s)
 movq $sock_close_parent_err_msg_length, %rdx        # length of the message (from constants.s)
 call print_info
 call exit_program

 handle_sock_close_child_err:
 lea sock_close_child_err_msg(%rip), %rsi           # pointer to the message (from constants.s)
 movq $sock_close_child_err_msg_length, %rdx        # length of the message (from constants.s)
 call print_info
 call exit_program
