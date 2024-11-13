.section .data
.equ request_buffer_size, 1024

GET_STRING: .asciz "GET"    

method_is_get_msg:    .asciz "method is GET\n"
method_is_not_get_msg:    .asciz "method is not GET\n"
sock_read_err_msg:    .asciz "\033[31mFailed to read client request! ❌\033[0m\n"

.section .bss
.lcomm request_buffer, 1024  # Allocates 1024 bytes for the request_buffer, zero-initialized

.section .text

.type sock_read, @function
sock_read:

push %rbp                              # save the caller's base pointer
mov %rsp, %rbp                         # set the new base pointer (stack frame)


mov $0, %rdx                            # Set %rdx to 0 for flags if needed
mov %r12, %rdi                          # client socket file descriptor
lea request_buffer(%rip), %rsi          # pointer to the request_buffer to store the request
mov $request_buffer_size, %rdx          # max number of bytes to read
mov $0, %rax                            # syscall number for read
syscall                                 # invoke syscall

cmp $0, %rax                            # Check if read was successful
jl handle_sock_read_err                 # Jump if there was an error

# Calculate request length
# lea request_buffer(%rip), %rdi          # Load buffer address
# call str_len                             # Calculate string length
# mov %rax, %rdx                          # Move length to %rdx for print_info
# PRINT CLIENT'S REQUEST
# lea request_buffer(%rip), %rsi          # pointer to the message
# call print_info

# COMPARE THE REQUEST METHOD TO "GET"
call extract_method
lea request_method(%rip), %rdi
lea GET_STRING(%rip), %rsi
call str_cmp
# Jump to the appropriate label based on the comparison result
cmp $1, %rax
je method_is_allowed
jne method_is_not_allowed

method_is_allowed:

pop %rbp                               # restore the caller's base pointer
ret                                    # return to the caller

method_is_not_allowed:

pop %rbp                               # restore the caller's base pointer
ret                                    # return to the caller



handle_sock_read_err:
 lea sock_read_err_msg(%rip), %rsi      # pointer to the message (from constants.s)
 call print_info
 call exit_program
 