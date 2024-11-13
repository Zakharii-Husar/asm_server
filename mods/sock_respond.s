.section .bss
    .lcomm response_header_buffer, 1024

.section .data

sock_respond_msg:    .asciz "\033[34mResponse was sent to the client 📬\033[0m\n"
sock_respond_msg_length = . - sock_respond_msg

sock_respond_err_msg:    .asciz "\033[31mFailed to respond to the client! ❌\033[0m\n"
sock_respond_err_msg_length = . - sock_respond_err_msg

http_status:     .ascii "HTTP/1.1 200 OK\r\n"
http_status_length = . - http_status

content_length:  .ascii "Content-Length: "
content_length_length = . - content_length

# Add newline after Content-Length value
newline:        .ascii "\r\n"
newline_length = . - newline

content_type:    .ascii "Content-Type: "
content_type_length = . - content_type

content_type_val: .ascii "text/html"
content_type_val_length = . - content_type_val

# Double CRLF to separate headers from body
headers_end:    .ascii "\r\n\r\n"
headers_end_length = . - headers_end


.section .text

.type sock_respond, @function
sock_respond:
 push %rbp                           # save the caller's base pointer
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

    # Extract the route
    call extract_route # returns %rax = 0 if no extension, 1 if has extension
    mov %rax, %rdi     # move the extension parameter for file_open

    # Read the requested file
    call file_open         # returns file size in %rax
    mov %rax, %rdi         # content length (integer) to be converted
    call int_to_string     # %rax has the string address, %rdx has string length

    # Add content length(in bytes) to response header
    lea response_header_buffer(%rip), %rdi
    mov %rax, %rsi  # rax contains the pointer to the string from int_to_string
    # rdx already contains the length from int_to_string
    call str_concat

    # Add newline after Content-Length value
    lea response_header_buffer(%rip), %rdi
    lea newline(%rip), %rsi
    mov $newline_length, %rdx
    call str_concat

    # Add Content-Type header
    lea response_header_buffer(%rip), %rdi
    lea content_type(%rip), %rsi
    mov $content_type_length, %rdx
    call str_concat

    # Add Content-Type value
    call find_content_type # returns %rax = pointer to the content type string, %rdx = length of the content type string    

    lea response_header_buffer(%rip), %rdi  # Pointer to the beginning of the header        
    mov %rax, %rsi                          # Pointer to the content type string
    xor %rdx, %rdx                          # Length of the content type string
    call str_concat

    lea response_header_buffer(%rip), %rsi
    call print_info

    # lea response_header_buffer(%rip), %rdi
    # lea content_type_val(%rip), %rsi
    # mov $content_type_val_length, %rdx
    # call str_concat

    # Add final double CRLF to separate headers from body
    lea response_header_buffer(%rip), %rdi
    lea headers_end(%rip), %rsi
    mov $headers_end_length, %rdx
    call str_concat
    mov %rax, %r10                  # Save the header length for later

    # Send the header
    mov %r10, %rdx                 # Length of the entire header
    mov $SYS_write, %rax           # syscall number for write
    mov %r12, %rdi                 # File descriptor
    lea response_header_buffer(%rip), %rsi  # Pointer to the beginning of the header
    syscall

    # Send the content
    mov $SYS_write, %rax          # syscall number for write
    mov %r12, %rdi                # File descriptor
    lea response_content_buffer(%rip), %rsi  # Pointer to the content buffer
    mov %r9, %rdx                 # Length of the content
    syscall


   cmp $0, %rax                               # Compare the return value with 0
   jl  handle_sock_respond_err                # Jump to error handling if %rax < 0
    

   lea sock_respond_msg(%rip), %rsi
   call print_info

   lea response_header_buffer(%rip), %rsi
   call print_info


   pop %rbp                     # restore the caller's base pointer
   ret                           # return to the caller

handle_sock_respond_err:
 lea sock_respond_err_msg(%rip), %rsi           # pointer to the message (from constants.s)
 mov $sock_respond_err_msg_length, %rdx        # length of the message (from constants.s)
 call print_info
 call exit_program
