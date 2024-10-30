.section .data

sock_respond_msg:    .asciz "\033[34mResponse was sent to the client 📬\033[0m\n"
sock_respond_msg_length = . - sock_respond_msg

sock_respond_err_msg:    .asciz "\033[31mFailed to respond to the client! ❌\033[0m\n"
sock_respond_err_msg_length = . - sock_respond_err_msg

http_header:
    .ascii "HTTP/1.1 200 OK\r\n"
    .ascii "Content-Length: "
content_length_placeholder:
    .space 10                                    # Reserve 10 bytes for Content-Length (as ASCII)
after_content_length:
    .ascii "\r\nContent-Type: text/html\r\n\r\n"
http_header_end:

header_length = http_header_end - http_header  # Length of the entire header

.section .text

.type sock_respond, @function
sock_respond:
 pushq %rbp                    # save the caller's base pointer
 mov %rsp, %rbp               # set the new base pointer (stack frame)


    # Step 1: Read the HTML file
    call file_open                 # returns file desc in %r8 and file length in %rcx

    # Step 2: Prepare HTTP header with content length

    # Fill in content length placeholder in the header
    mov %rcx, %rdi                    # content length (integer) to be converted
    call int_to_string                # Convert integer to ASCII; %rax has address, %rdx has string length
    push %rdx

    lea content_length_placeholder(%rip), %rdi  # Destination for ASCII content length
    mov %rdx, %rcx                              # Length of ASCII string
    mov %rax, %rsi                              # Source (ASCII content length from int_to_string)
    rep movsb                                    # Copy %rcx bytes from %rsi to %rdi

   
    # Step 3: Send the header with the updated Content-Length
    mov $SYS_write, %rax               # syscall number for write
    mov %r12, %rdi         # File descriptor (assumed to be in a register or memory) 
    lea http_header(%rip), %rsi        # Pointer to the beginning of the header
    mov $header_length, %rdx            # Length of the entire header
    syscall                            # Perform the write

pop %rdx

    # Step 4: send the content
    mov $SYS_write, %rax               # syscall number for write
    mov %r12, %rdi         # File descriptor
    lea file_buffer(%rip), %rsi        # Pointer to the content buffer
    # mov %rdi, %rdx           # Length of the content
    syscall                            # Send the content


   cmp $0, %rax                               # Compare the return value with 0
   jl  handle_sock_respond_err                # Jump to error handling if %rax < 0
    
   lea sock_respond_msg(%rip), %rsi           # pointer to the message (from constants.s)
   mov $sock_respond_msg_length, %rdx         # length of the message (from constants.s)
   call print_info


    pop %rbp                     # restore the caller's base pointer
    ret                           # return to the caller

handle_sock_respond_err:
 lea sock_respond_err_msg(%rip), %rsi           # pointer to the message (from constants.s)
 mov $sock_respond_err_msg_length, %rdx        # length of the message (from constants.s)
 call print_info
 call exit_program
