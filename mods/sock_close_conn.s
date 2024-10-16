
.section .text

.type sock_close_conn, @function
sock_close_conn:

pushq %rbp                    # save the caller's base pointer
movq %rsp, %rbp               # set the new base pointer (stack frame)

movq    %rdi, %rdi           # socket file descriptor
movq    $3, %rax             # sys_close (system call number for closing a file descriptor: 3)
syscall                      # close the connection

popq %rbp                     # restore the caller's base pointer
ret                           # return to the caller
