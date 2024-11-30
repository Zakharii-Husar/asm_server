# Parameters:
# - %rdi: response content buffer
# - %rsi: content size
# - %rdx: status code
# - %rcx: file extension

# Implicit parameters:
# - %r13 Connection file descriptor;


.section .bss
    .lcomm response_header_B, 1024

.section .rodata

sock_respond_msg:    .asciz "\033[34mResponse was sent to the client 📬\033[0m\n"
sock_respond_msg_length = . - sock_respond_msg

sock_respond_err_msg:    .asciz "\033[31mFailed to respond to the client! ❌\033[0m\n"
sock_respond_err_msg_length = . - sock_respond_err_msg

# Double CRLF to separate headers from body
headers_end:    .ascii "\r\n"
headers_end_length = . - headers_end

.section .text

.type sock_respond, @function
sock_respond:
 push %rbp                           # save the caller's base pointer
 mov %rsp, %rbp                      # set the new base pointer (stack frame)

 push %r12
 push %r14
 push %r15

 mov %rdi, %r12 # response content buffer
 mov %rsi, %r14 # content size
 mov %rcx, %r15 # file extension


    # ADD HTTP STATUS LINE TO RESPONSE HEADER
    mov %rdx, %rdi                    # Move status code to first parameter
    lea response_header_B(%rip), %rsi  # Add this line: pass buffer pointer as second parameter
    call create_status_header         # Returns ptr in %rax, len in %rdx

    # ADD CONTENT-LENGTH HEADER TO RESPONSE HEADER
    lea response_header_B(%rip), %rdi # destination
    mov %r14, %rsi # content size
    call create_length_header

    # ADD CONTENT-TYPE HEADER TO RESPONSE HEADER
    lea response_header_B(%rip), %rdi  # destination buffer
    mov %r15, %rsi                          # file extension buffer pointer
    call create_type_header                 # returns length in %rax


    # ADD FINAL DOUBLE CRLF TO SEPARATE HEADERS FROM BODY
    lea response_header_B(%rip), %rdi
    lea headers_end(%rip), %rsi
    mov $headers_end_length, %rdx
    call str_concat

    # SEND THE HEADER
    mov %rax, %rdx                 # Length of the entire header
    mov $SYS_write, %rax           # syscall number for write
    mov %r13, %rdi                 # File descriptor
    lea response_header_B(%rip), %rsi  # Pointer to the beginning of the header
    syscall


    # SEND THE CONTENT
    mov $SYS_write, %rax           # syscall number for write
    mov %r13, %rdi                 # File descriptor
    mov %r12 , %rsi                # Pointer to the content buffer
    mov %r14, %rdx                 # Length of the content
    syscall


   cmp $0, %rax                               # Compare the return value with 0
   jl  .handle_sock_respond_err                # Jump to error handling if %rax < 0


   pop %r15
   pop %r14
   pop %r12

   pop %rbp                     # restore the caller's base pointer
   ret                          # return to the caller

.handle_sock_respond_err:
 lea sock_respond_err_msg(%rip), %rdi           # pointer to the message (from constants.s)
 mov $sock_respond_err_msg_length, %rsi        # length of the message (from constants.s)
 call print_info
 call exit_program
