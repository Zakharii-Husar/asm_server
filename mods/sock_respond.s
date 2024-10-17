.section .rodata

.equ sock_respond_msg_length, 32
sock_respond_msg:    .asciz "Response was sent to the client\n"

.equ sock_respond_err_msg_length, 38
sock_respond_err_msg:    .asciz "Faied to send response to the client!\n"

# Define HTTP response
 response:
  .ascii  "HTTP/1.1 200 OK\r\n"
  .ascii  "Content-Length: 13\r\n"
  .ascii  "Content-Type: text/plain\r\n"
  .ascii  "\r\n"
  .ascii  "Hello, World!\r\n"
  response_len = . - response

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


   cmpq $0, %rax                   # Compare the return value with 0
   jl  handle_sock_respond_err                 # Jump to error handling if %rax < 0
    
   lea sock_respond_msg(%rip), %rsi           # pointer to the message (from constants.s)
   movq $sock_respond_msg_length, %rdx        # length of the message (from constants.s)
   call print_info

    popq %rbp                     # restore the caller's base pointer
    ret                           # return to the caller

handle_sock_respond_err:
 lea sock_respond_err_msg(%rip), %rsi           # pointer to the message (from constants.s)
 movq $sock_respond_err_msg_length, %rdx        # length of the message (from constants.s)
 call print_info
 call exit_program
