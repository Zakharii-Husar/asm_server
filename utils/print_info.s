.section .text

.type print_info, @function
print_info:
    pushq %rbp                    # save the caller's base pointer
    movq %rsp, %rbp               # set the new base pointer (stack frame)

    movq $SYS_write, %rax         # syscall: sys_write (1)
    movq $SYS_write, %rdi         # file descriptor: stdout (1) 
    syscall                       # making syscall with arguments from %rsi and %rdx

    popq %rbp                     # restore the caller's base pointer
    ret                           # return to the caller
    
