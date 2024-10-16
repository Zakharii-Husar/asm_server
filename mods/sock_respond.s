
.section .text

.type sock_respond, @function
sock_respond:
 pushq %rbp                    # save the caller's base pointer
 movq %rsp, %rbp               # set the new base pointer (stack frame)

    movq    %rax, %rdi           # socket file descriptor from accept (in %rax) is moved to %rdi
    lea     response(%rip), %rsi # address of the response in %rsi
    movq    $response_len, %rdx  # length of the response in %rdx
    movq    $SYS_sock_sendto, %rax            # sys_sendto (system call number for sending data: 44)
    xorq    %r10, %r10           # flags = 0
    syscall                      # send the data (response to browser)

    popq %rbp                     # restore the caller's base pointer
    ret                           # return to the caller
