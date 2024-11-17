.section .bss
    .lcomm response_header_buffer, 1024

     .lcomm file_path_buffer, 2048                # New buffer for combined path

.section .data

base_path: .asciz "./asm_server/public"    # Base path constant
not_found_path: .asciz "./asm_server/public/404.html"

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

# Double CRLF to separate headers from body
headers_end:    .ascii "\r\n\r\n"
headers_end_length = . - headers_end

.section .rodata

sock_write_err_msg:    .asciz "\033[31mFailed to write to socket! ❌\033[0m\n"
sock_write_success_msg: .asciz "\033[32mData written to socket successfully! ✅\033[0m\n"

.section .text

# Function: sock_write
# Parameters:
#   - %rdi: socket file descriptor (fd) to write to
#   - %rsi: pointer to the buffer containing the data to write
#   - %rdx: number of bytes to write from the buffer
# Return Values:
#   - Returns the number of bytes written on success (>= 0)
#   - Calls handle_sock_write_err on failure (if write fails)

.type sock_write, @function
sock_write:
 push %rbp                    # save the caller's base pointer
 mov %rsp, %rbp               # set the new base pointer (stack frame)

 mov %rdi, %r12                # move socket fd to %r12 for syscall
 mov $SYS_write, %rax          # syscall number for write
 syscall                        # invoke syscall

 cmp $0, %rax                  # Check if write was successful
 jl handle_sock_write_err       # Jump if there was an error

 lea sock_write_success_msg(%rip), %rsi  # pointer to success message
 call print_info                # print success message

 pop %rbp                      # restore the caller's base pointer
 ret                           # return to the caller

handle_sock_write_err:
 lea sock_write_err_msg(%rip), %rsi      # pointer to the error message
 call print_info
 call exit_program

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
    call extract_route

    # Concatenate base_path with route to create full path to the file
    lea file_path_buffer(%rip), %rdi    # Destination buffer
    lea base_path(%rip), %rsi           # Source (base path)
    xor %rdx, %rdx                      # Let str_concat calculate length
    call str_concat

    # Append request route
    lea file_path_buffer(%rip), %rdi    # Destination buffer
    lea request_route(%rip), %rsi       # Source (request route)
    xor %rdx, %rdx                      # Let str_concat calculate length
    call str_concat

    # Read the requested file
    lea file_path_buffer(%rip), %rdi    # Load path into %rdi before calling file_open
    call file_open                      # returns file size in %rax
    cmp $-1, %rax                       # Check if file_open returned -1 (error)
    jne skip_404                        # Jump to skip_404 if file was found

    # Load "./404.html" path and call file_open
    lea not_found_path(%rip), %rdi      # Load 404 path into %rdi
    call file_open                      # Try to open 404.html

    skip_404:
    mov %rax, %rdi        # content length (integer) to be converted
    call int_to_string    # %rax has the string address, %rdx has string length

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
