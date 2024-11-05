.section .text

.type exit_program, @function
exit_program:

mov $SYS_exit, %rax
xor %rdi, %rdi       # return code 0
syscall
