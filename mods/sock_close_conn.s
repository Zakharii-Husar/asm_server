
.section .text

.type sock_close_conn, @function
sock_close_conn:

pushq %rbp                    # save the caller's base pointer
movq %rsp, %rbp               # set the new base pointer (stack frame)

popq %rbp                     # restore the caller's base pointer
ret                           # return to the caller
