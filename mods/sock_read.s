.section .data
.equ request_buffer_size, 1024

sock_read_err_msg:    .asciz "Faied to read client request!\n"
sock_read_err_msg_length = . - sock_read_err_msg

.section .bss
.lcomm request_buffer, 1024  # Allocates 1024 bytes for the request_buffer, zero-initialized

.section .text

.type sock_read, @function
sock_read:

push %rbp                              # save the caller's base pointer
mov %rsp, %rbp                         # set the new base pointer (stack frame)

mov $0, %rdx                            # Set %rdx to 0 for flags if needed
mov %r12, %rdi                          # client socket file descriptor
lea request_buffer(%rip), %rsi                # pointer to the request_buffer to store the request
mov $request_buffer_size, %rdx           # max number of bytes to read
mov $0, %rax                            # syscall number for read
syscall                                 # invoke syscall

cmp $0, %rax                            # Check if read was successful
jl handle_sock_read_err                 # Jump if there was an error


lea request_buffer(%rip), %rsi          # pointer to the message
mov %rax, %rdx                          # length of the message
call print_info

 pop %rbp                               # restore the caller's base pointer
 ret                                    # return to the caller

handle_sock_read_err:
 lea sock_read_err_msg(%rip), %rsi      # pointer to the message (from constants.s)
 movq $sock_read_err_msg_length, %rdx   # length of the message (from constants.s)
 call print_info
 call exit_program
 