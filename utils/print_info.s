.section .text

.type print_info, @function
print_info:
    pushq %rbp                    # save the caller's base pointer
    movq %rsp, %rbp               # set the new base pointer (stack frame)

    # pushing and popping rax so print_info doesn't clobber rax register
    pushq %rax

    movq $SYS_write, %rax         # syscall: sys_write (1)
    movq $SYS_stdout, %rdi        # file descriptor: stdout (1)
    syscall                       # make the syscall

    popq %rax

    popq %rbp                     # restore the caller's base pointer
    ret                           # return to the caller
