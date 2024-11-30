.section .bss
.lcomm req_route_B, req_route_B_size

.section .data

.GET_STRING: .asciz "GET"    


.sock_read_err_msg:    .asciz "\033[31mFailed to read client request! ❌\033[0m\n"

.bad_request_path: .asciz "./asm_server/public/400.html"

.not_found_path: .asciz "./asm_server/public/404.html"

.method_not_allowed_path: .asciz "./asm_server/public/405.html"

.server_err_path: .asciz "./asm_server/public/500.html"


.section .text

# Function: sock_read
# Parameters:
# - %rdi > %r12: Pointer to the request_buffer;
# - %rsi > %r13: Pointer to the file_path_buffer;
# - %rdx > %r14: Pointer to the extension_buffer;
# - %rcx > %r15: Pointer to the response_buffer;
# Implicit parameters:
# - %r12 Socket file descriptor;
# Return Values:
#   - %rax: Actual file size (size of the opened file)
#   - %rdx: HTTP status code
# Side effects:
#   - Extracts the route and route extension into buffers
#   - Opens requested file into buffer

.type sock_read, @function
sock_read:
    push %rbp                               # save the caller's base pointer
    mov %rsp, %rbp                          # set the new base pointer (stack frame)

    push %r12
    push %r13
    push %r14
    push %r15

    mov %r13, %r8                           # Preserve Connection FD    
    mov %rdi, %r12                          # request buffer
    mov %rsi, %r13                          # route buffer
    mov %rdx, %r14                          # extension buffer
    mov %rcx, %r15                          # response buffer



    # READ AND VALIDATE CLIENT'S REQUEST
    mov %r8, %rdi                           # client socket file descriptor
    mov %r12, %rsi                          # pointer to the request_content_buffer to store the request
    mov $req_B_size, %rdx                   # max number of bytes to read
    mov $0, %rax                            # syscall number for read
    syscall                                 # invoke syscall

    cmp $0, %rax                            # Check if read was successful
    jl .bad_request                          # Jump if there was an error
    

    # COMPARE THE REQUEST METHOD TO "GET"
    # Extract the method
    mov %r12, %rdi                         # Load source buffer (request buffer)
    call extract_method                    # Returns pointer to method in %rax
    mov %rax, %rdi                         # First parameter for str_cmp

    lea .GET_STRING(%rip), %rsi            # Second parameter
    call str_cmp
    # Handle the method not allowed

    cmp $0, %rax
    je .method_not_allowed


    # ATTEMPT TO OPEN THE REQUESTED FILE

    # Extract the route
    lea req_route_B(%rip), %rdi            # Destination buffer for route
    mov %r12, %rsi                         # The HTTP req buffer to extract route and ext from
    call extract_route                     # Extract the route


    # Build the file path
    mov %r13, %rdi                         # Destination buffer for file path
    lea req_route_B(%rip), %rsi            # Route buffer
    call build_file_path                   # Build the file path



    # Open the file 

    mov %r13, %rdi                          # 1st param for file_open
    mov %r15, %rsi                          # Pass the response_content_buffer pointer as the second param for file_open
    call file_open
    # Handle the file not found error
    cmp $-1, %rax                            # Check if file_open returned -1 (error)
    je .file_not_found                        # Jump if file not found


    mov $HTTP_OK_code, %rdx
    jmp .finish_sock_read 

# HANDLE ERRORS

.file_not_found:
    # Clear the response_content_buffer before the next attempt
    mov %rdi, %rsi                            # Use the passed response_content_buffer pointer
    mov $response_B_size, %rsi   # Number of bytes to clear
    call clear_buffer

    lea .not_found_path(%rip), %rdi            # Load .not_found_path as the file path
    mov %r15, %rsi                             # Use the same buffer for the response
    call file_open                            # Attempt to open the not found file

    cmp $-1, %rax                             # Check if the second file_open returned -1 (error)
    jl .server_err                            # Jump to .bad_request if it fails

    mov $HTTP_file_not_found_code, %rdx            # Set error code to -1 (file not found)
    jmp .finish_sock_read

.bad_request:
    # Clear the response_content_buffer before the next attempt
    mov %rdi, %rsi                           # Use the passed response_content_buffer pointer
    mov $response_B_size, %rsi   # Number of bytes to clear
    call clear_buffer

    lea .bad_request_path(%rip), %rdi          # Load .not_found_path as the file path
    mov %r15, %rsi                            # Use the same buffer for the response
    call file_open                            # Attempt to open the not found file

    cmp $-1, %rax                             # Check if the second file_open returned -1 (error)
    jl .server_err                             # Jump to .bad_request if it fails

    mov $HTTP_bad_req_code, %rdx            # Set error code to -2 (bad request)
    jmp .finish_sock_read

.method_not_allowed:
    # Clear the response_content_buffer before the next attempt
    mov %rdi, %rsi                           # Use the passed response_content_buffer pointer
    mov $response_B_size, %rsi   # Number of bytes to clear
    call clear_buffer

    lea .method_not_allowed_path(%rip), %rdi   # Load .not_found_path as the file path
    mov %r15, %rsi                             # Use the same buffer for the response
    call file_open                            # Attempt to open the not found file

    cmp $-1, %rax                             # Check if the second file_open returned -1 (error)
    jl .server_err                             # Jump to .bad_request if it fails

    mov $HTTP_method_not_allowed_code, %rdx            # Set error code to -3 (method not allowed)
    jmp .finish_sock_read

.server_err:
    # Clear the response_content_buffer before the next attempt
    mov %rdi, %rsi                           # Use the passed response_content_buffer pointer
    mov $response_B_size, %rsi   # Number of bytes to clear
    call clear_buffer

    lea .bad_request_path(%rip), %rdi          # Load .not_found_path as the file path
    mov %r15, %rsi                            # Use the same buffer for the response
    call file_open                            # Attempt to open the not found file

    mov $HTTP_serve_err_code, %rdx            # Set error code to -4 (server error)
    cmp $-1, %rax                             # Check if the second file_open returned -1 (error)
    
    jne .finish_sock_read

    mov $0, %rax                               # Set return value to 0 (no file size)

.finish_sock_read:
    pop %r15
    pop %r14
    pop %r13
    pop %r12    

    # mov %rax, %rax (file size is already in %rax after file_open)
    pop %rbp                                  # restore the caller's base pointer
    ret


 