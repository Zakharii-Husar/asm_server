   # 1. If route has extension -> try exact path
   # 2. If no extension:
   #    a. Try with .html first (most common case)
   #    b. If not found, try .css
   #    c. If not found, try .js
   # 3. If nothing found -> 404

.section .data

sock_respond_msg:    .asciz "\033[34mResponse was sent to the client 📬\033[0m\n"
sock_respond_msg_length = . - sock_respond_msg

sock_respond_err_msg:    .asciz "\033[31mFailed to respond to the client! ❌\033[0m\n"
sock_respond_err_msg_length = . - sock_respond_err_msg

http_header:
    .ascii "HTTP/1.1 200 OK\r\n"
    .ascii "Content-Length: "                     # Reserve 10 bytes for Content-Length (as ASCII)
after_content_length:
    .ascii "          \r\nContent-Type: text/html\r\n\r\n"
http_header_end:


header_length = http_header_end - http_header  # Length of the entire header

.section .text

.type sock_respond, @function
sock_respond:
 pushq %rbp                          # save the caller's base pointer
 mov %rsp, %rbp                      # set the new base pointer (stack frame)

    # Extract route will set %r8 with extension flag
    
    
    # Step 1: Read the HTML file
    call file_open
    mov %r9, %rdi                                # content length (integer) to be converted
    call int_to_string                           # Convert integer to ASCII; %rax has address, %rdx has string length

    # Step 2: Prepare HTTP header with content length

    # Fill in content length placeholder in the header
    lea after_content_length(%rip), %rdi  # Start of Content-Length placeholder
    mov %rax, %rsi                  # Source address of ASCII content length
    mov %rdx, %rcx                  # Length of ASCII string (exact bytes to copy)
    rep movsb                       # Copy exactly the length of the string

    # PRINT RESPONSE HEADER
    # lea http_header(%rip), %rsi           # pointer to the message (from constants.s)
    # mov $header_length, %rdx        # length of the message (from constants.s)
    # call print_info

   
    # Step 3: Send the header with the updated Content-Length
    mov $SYS_write, %rax               # syscall number for write
    mov %r12, %rdi         # File descriptor (assumed to be in a register or memory) 
    lea http_header(%rip), %rsi        # Pointer to the beginning of the header
    mov $header_length, %rdx            # Length of the entire header
    syscall                            # Perform the write

    # Step 4: send the content
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
