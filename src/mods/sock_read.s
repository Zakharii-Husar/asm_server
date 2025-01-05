.section .bss
.lcomm req_route_B, req_route_B_size
.lcomm req_method_B, req_method_B_size  

.section .data

.GET_STRING: .asciz "GET"

server_read_err_msg: .asciz "SEVERE: Failed to read any response pages in sock_read.s"
server_read_err_msg_len = . - server_read_err_msg

.bad_request_path: .asciz "./public/400.html"

.not_found_path: .asciz "./public/404.html"

.method_not_allowed_path: .asciz "./public/405.html"

.server_err_path: .asciz "./public/500.html"


.section .text
.type sock_read, @function
# Function: sock_read
# Parameters:
#   - %rdi: pointer to request buffer
#   - %rsi: pointer to file path buffer
#   - %rdx: pointer to extension buffer
#   - %rcx: pointer to response content buffer
# Global Registers:
#   - %r13: connection file descriptor
#   - %r14: client IP string pointer
#   - %r15: server configuration pointer
# Return Values:
#   - %rax: actual file size
#   - %rdx: HTTP status code
# Error Handling:
#   - Returns appropriate HTTP status codes (400, 404, 405, 500)
#   - Loads error pages for each error case
# Side Effects:
#   - Modifies request buffers (route, method)
#   - Opens and reads files into response buffer
#   - Calls logging functions
sock_read:
    push %rbp
    mov %rsp, %rbp
    # Allocate space for local variables (32 bytes instead of 24)
    sub $32, %rsp
    # Preserve non-volatile registers first
    push %r12
    push %r13
    
    # Store extension buffer, response content buffer pointers, and status code
    mov %rdx, -8(%rbp)    # Store extension buffer pointer
    mov %rcx, -16(%rbp)   # Store response content buffer pointer
    # -24(%rbp) will be used for status code later
    # -32(%rbp) is padding for 16-byte alignment
    
    mov %r13, %r8                           # Preserve Connection FD    
    mov %rdi, %r12                          # request buffer
    mov %rsi, %r13                          # route buffer

    # CLEAR THE BUFFERS
    # Method buffer is cleared in extract_method

    # Clear the route buffer:
    lea req_route_B(%rip), %rdi
    mov $req_route_B_size, %rsi
    call clear_buffer



    # READ AND VALIDATE CLIENT'S REQUEST
    mov %r8, %rdi                           # client socket file descriptor
    mov %r12, %rsi                          # pointer to the request_content_buffer to store the request
    mov $req_B_size, %rdx                   # max number of bytes to read
    mov $0, %rax                            # syscall number for read
    syscall                                 # invoke syscall

    cmp $0, %rax                            # Check if read was successful
    jl .bad_request                         # Jump if there was an error

    # EXTRACT THE ROUTE
    # Extract the route
    lea req_route_B(%rip), %rdi            # Destination buffer for route
    mov %r12, %rsi                         # The HTTP req buffer to extract route and ext from
    call extract_route                     # Extract the route

    # COMPARE THE REQUEST METHOD TO "GET"
    # Extract the method
    mov %r12, %rdi                         # Load source buffer (request buffer)
    lea req_method_B(%rip), %rsi           # Load destination buffer (method buffer)
    mov $req_method_B_size, %rdx           # Load destination buffer size
    call extract_method                    # Returns pointer to method in %rax
    mov %rax, %rdi                         # First parameter for str_cmp
    lea .GET_STRING(%rip), %rsi            # Second parameter
    call str_cmp
    # Handle the method not allowed
    cmp $0, %rax
    je .method_not_allowed


    # ATTEMPT TO OPEN THE REQUESTED FILE

    # Build the file path
    mov %r13, %rdi                         # Destination buffer for file path
    lea req_route_B(%rip), %rsi            # Route buffer
    call build_file_path                   # Build the file path

    # Open the file 
    mov %r13, %rdi                          # file path buffer
    mov -16(%rbp), %rsi                          # response buffer
    mov CONF_BUFFER_SIZE_OFFSET(%r15), %rdx      # buffer size
    xor %rcx, %rcx                          # null termination flag
    call file_open

    # Handle the file not found error
    cmp $0, %rax                            # Check if file_open returned -1 (error)
    jle .file_not_found                        # Jump if file not found

    
    mov $HTTP_OK_code, %rdx
    jmp .finish_sock_read 

# HANDLE ERRORS

.file_not_found:

    mov -16(%rbp), %rdi                             # response buffer pointer
    mov $response_content_B_size, %rdx         # Number of bytes to clear (not %rsi)
    call clear_buffer

    lea .not_found_path(%rip), %rdi           # Load 404.html path
    mov -16(%rbp), %rsi                            # response buffer
    mov $response_content_B_size, %rdx         # buffer size
    xor %rcx, %rcx                          # null termination flag
    call file_open      

    # Need to handle the case where even 404.html fails to open
    cmp $0, %rax                              # Check if file_open succeeded
    jle .server_err                           # If failed, serve 500 error

    mov $HTTP_file_not_found_code, %rdx       # Set 404 status code
    jmp .finish_sock_read

.bad_request:
    # Clear the response_content_buffer before the next attempt

    mov -16(%rbp), %rdi                            # response buffer pointer
    mov $response_content_B_size, %rdx         # Number of bytes to clear
    call clear_buffer

    lea .bad_request_path(%rip), %rdi          # Load .not_found_path as the file path
    mov -16(%rbp), %rsi                        # Use the same buffer for the response
    mov $response_content_B_size, %rdx         # buffer size
    xor %rcx, %rcx                             # null termination flag
    call file_open                             # Attempt to open the not found file

    cmp $-1, %rax                             # Check if the second file_open returned -1 (error)
    jl .server_err                             # Jump to .bad_request if it fails

    mov $HTTP_bad_req_code, %rdx            # Set error code to -2 (bad request)
    jmp .finish_sock_read

.method_not_allowed:
    # Clear the response_content_buffer before the next attempt
    mov -16(%rbp), %rdi                            # response buffer pointer
    mov $response_content_B_size, %rdx         # Number of bytes to clear
    call clear_buffer

    lea .method_not_allowed_path(%rip), %rdi   # Load .not_found_path as the file path
    mov -16(%rbp), %rsi                             # Use the same buffer for the response
    mov $response_content_B_size, %rdx         # buffer size
    xor %rcx, %rcx                              # null termination flag
    call file_open                            # Attempt to open the not found file

    cmp $-1, %rax                             # Check if the second file_open returned -1 (error)
    jl .server_err                             # Jump to .bad_request if it fails

    mov $HTTP_method_not_allowed_code, %rdx            # Set error code to -3 (method not allowed)
    jmp .finish_sock_read

.server_err:
    lea server_read_err_msg(%rip), %rdi
    mov $server_read_err_msg_len, %rsi
    mov %rax, %rdx        # Pass error code
    call log_err  

    # Clear the response_content_buffer before the next attempt
    mov -16(%rbp), %rdi                            # response buffer pointer
    mov $response_content_B_size, %rdx         # Number of bytes to clear
    call clear_buffer

    lea .server_err_path(%rip), %rdi          # Load .not_found_path as the file path
    mov -16(%rbp), %rsi                            # Use the same buffer for the response
    mov $response_content_B_size, %rdx         # buffer size
    xor %rcx, %rcx                            # null termination flag
    call file_open                            # Attempt to open the not found file

    mov $HTTP_serve_err_code, %rdx            # Set error code to -4 (server error)
    cmp $-1, %rax                             # Check if the second file_open returned -1 (error)
    
    jne .finish_sock_read

    mov $0, %rax                               # Set return value to 0 (no file size)
    

.finish_sock_read:

    mov %rax, %r12                             # preserve file size
    mov %rdx, -24(%rbp)                        # preserve HTTP status code
    # Extract the extension
    mov -8(%rbp), %rdx
    mov %rdx, %rdi                             # Destination buffer for extension
    mov %r13, %rsi                             # The HTTP req buffer to extract ext from
    call extract_extension                     # Extract the extension  

    lea req_method_B(%rip), %rdi
    lea req_route_B(%rip), %rsi
    mov -24(%rbp), %rdx # pass http status code to log_access
    call log_access

    mov %r12, %rax                             # restore file sizeF
    mov -24(%rbp), %rdx                        # restore http status code
    pop %r13
    pop %r12
    add $32, %rsp
    leave                                   # restore stack frame (mov %rbp, %rsp; pop %rbp)
    ret


 