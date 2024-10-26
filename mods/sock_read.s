.section .data
.equ buffer_size, 1024

.section .bss
.lcomm buffer, 1024  # Allocates 1024 bytes for the buffer, zero-initialized

.section .text

.type sock_read, @function
sock_read:

push %rbp                              # save the caller's base pointer
mov %rsp, %rbp                         # set the new base pointer (stack frame)

mov $0, %rdx                            # Set %rdx to 0 for flags if needed
mov %r12, %rdi                          # client socket file descriptor
mov buffer, %rsi                        # pointer to the buffer to store the request
mov buffer_size, %rdx                   # max number of bytes to read
mov $0, %rax                            # syscall number for read
syscall                                 # invoke syscall

 pop %rbp                               # restore the caller's base pointer
 ret                                    # return to the caller
 