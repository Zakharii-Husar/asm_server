
.section .text

# Create socket (AF_INET, SOCK_STREAM, 0)
.type sock_create, @function
sock_create:
pushq %rbp                    # save the caller's base pointer
movq %rsp, %rbp               # set the new base pointer (stack frame)

 mov $SYS_sock_create, %rax
 mov $AF_INET, %rdi
 mov $SOCK_STREAM, %rsi
 mov $SOCK_PROTOCOL, %rdx
 syscall
 mov %rax, %rbx                    # store socket fd in %rbx

popq %rbp                     # restore the caller's base pointer
ret                           # return to the caller


