.section .bss
    .lcomm response_header_buffer, 1024

.section .data

sock_respond_msg:    .asciz "\033[34mResponse was sent to the client 📬\033[0m\n"
sock_respond_msg_length = . - sock_respond_msg

sock_respond_err_msg:    .asciz "\033[31mFailed to respond to the client! ❌\033[0m\n"
sock_respond_err_msg_length = . - sock_respond_err_msg

http_status:     .asciz "HTTP/1.1 200 OK\r\n"
http_status_length = . - http_status

content_length:  .asciz "Content-Length: "
content_length_length = . - content_length

content_type:    .asciz "\r\nContent-Type: "
content_type_length = . - content_type

content_type_val:.asciz "text/html\r\n\r\n"
content_type_val_length = . - content_type_val

# Add a newline constant for after Content-Length value
newline:        .asciz "\r\n"
newline_length = . - newline


.section .text

.type sock_respond, @function
sock_respond:
 push %rbp                          # save the caller's base pointer
 mov %rsp, %rbp                      # set the new base pointer (stack frame)
    
    # Add HTTP status line to response header
    lea response_header_buffer(%rip), %rdi
    lea http_status(%rip), %rsi
    mov $http_status_length, %rdx
    call str_concat

    # Add Content-Length header to response header
    lea response_header_buffer(%rip), %rdi
    lea content_length(%rip), %rsi
    mov $content_length_length, %rdx
    call str_concat

    # Step 1: Extract the route
    call extract_route # returns %rax = 0 if no extension, 1 if has extension
    mov %rax, %rdi # move parameter for file_open

    # Step 2: Read the HTML file
    call file_open
    mov %rax, %rdi                                # content length (integer) to be converted
    call int_to_string                           # Convert integer to ASCII; %rax has address, %rdx has string length

    # Step 3: Add length to response header
    lea response_header_buffer(%rip), %rdi
    mov %rax, %rsi  # rax contains the pointer to the string from int_to_string
    # rdx already contains the length from int_to_string
    call str_concat

        # Add newline after the Content-Length value
    lea response_header_buffer(%rip), %rdi
    lea newline(%rip), %rsi
    mov $newline_length, %rdx
    call str_concat

    # Step 4: Find the content type

    # PRINT RESPONSE HEADER
    lea response_header_buffer(%rip), %rsi           # pointer to the message (from constants.s)
    mov %rax, %rdx        # length of the message (from constants.s)
    call print_info

   
    # Step 5: Send the header with the updated Content-Length
    mov $SYS_write, %rax               # syscall number for write
    mov %r12, %rdi                     # File descriptor (assumed to be in a register or memory) 
    lea response_header_buffer(%rip), %rsi        # Pointer to the beginning of the header
    mov %rax, %rdx           # Length of the entire header
    syscall                            # Perform the write

    # Step 6: send the content
    mov $SYS_write, %rax               # syscall number for write
    mov %r12, %rdi                     # File descriptor
    lea response_content_buffer(%rip), %rsi        # Pointer to the content buffer
    mov %r9, %rdx                     # Length of the content
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
