.section .data
.equ request_buffer_size, 1024
GET_STRING: .asciz "GET"    

sock_read_err_msg:    .asciz "\033[31mFailed to read client request! ❌\033[0m\n"

bad_request_path: .asciz "./asm_server/public/400.html"

not_found_path: .asciz "./asm_server/public/404.html"

method_not_allowed_path: .asciz "./asm_server/public/405.html"

server_err_path: .asciz "./asm_server/public/500.html"

.section .bss
.lcomm request_buffer, 1024  # Allocates 1024 bytes for the request_buffer, zero-initialized

.section .text

# Function: sock_read
# Implicit parameters:
# - %r12 Socket file descriptor;
# - %rdi Pointer to the response_content_buffer;
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

    mov %rdi, %r8                           # Preserve request buffer pointer
    # READ AND VALIDATE CLIENT'S REQUEST
    mov $0, %rdx                            # Set %rdx to 0 for flags if needed
    mov %r12, %rdi                          # client socket file descriptor
    lea request_buffer(%rip), %rsi          # pointer to the request_buffer to store the request
    mov $request_buffer_size, %rdx          # max number of bytes to read
    mov $0, %rax                            # syscall number for read
    syscall                                 # invoke syscall

    cmp $0, %rax                            # Check if read was successful
    jl bad_request                          # Jump if there was an error

    # COMPARE THE REQUEST METHOD TO "GET"
    call extract_method
    lea request_method(%rip), %rdi
    lea GET_STRING(%rip), %rsi
    call str_cmp
    cmp $0, %rax
    je method_not_allowed

    # ATTEMPT TO OPEN THE REQUESTED FILE
    lea request_buffer(%rip), %rdi           # The HTTP req buffer to extract route and ext from
    call extract_route                       # Extract the route
    
    mov %rax, %rdi                           # 1st param for file_open
    mov %r8, %rsi                           # Pass the response_content_buffer pointer as the second param for file_open
    call file_open

    cmp $-1, %rax                            # Check if file_open returned -1 (error)
    jl file_not_found                        # Jump if file not found

    mov $HTTP_OK_code, %rdx
    jmp finish_sock_read 

# HANDLE ERRORS

file_not_found:
    # Clear the response_content_buffer before the next attempt
    mov %rdi, %rsi                            # Use the passed response_content_buffer pointer
    mov $response_content_buffer_size, %rsi   # Number of bytes to clear
    call clear_buffer

    lea not_found_path(%rip), %rdi            # Load not_found_path as the file path
    mov %r8, %rsi                           # Use the same buffer for the response
    call file_open                            # Attempt to open the not found file

    cmp $-1, %rax                             # Check if the second file_open returned -1 (error)
    jl server_err                            # Jump to bad_request if it fails

    mov $HTTP_file_not_found_code, %rdx                             # Set error code to -1 (file not found)
    jmp finish_sock_read

bad_request:
    # Clear the response_content_buffer before the next attempt
    mov %rdi, %rsi                           # Use the passed response_content_buffer pointer
    mov $response_content_buffer_size, %rsi   # Number of bytes to clear
    call clear_buffer

    lea bad_request_path(%rip), %rdi          # Load not_found_path as the file path
    mov %r8, %rsi                           # Use the same buffer for the response
    call file_open                            # Attempt to open the not found file

    cmp $-1, %rax                             # Check if the second file_open returned -1 (error)
    jl server_err                             # Jump to bad_request if it fails

    mov $HTTP_bad_req_code, %rdx                             # Set error code to -2 (bad request)
    jmp finish_sock_read

method_not_allowed:
    # Clear the response_content_buffer before the next attempt
    mov %rdi, %rsi                           # Use the passed response_content_buffer pointer
    mov $response_content_buffer_size, %rsi   # Number of bytes to clear
    call clear_buffer

    lea method_not_allowed_path(%rip), %rdi   # Load not_found_path as the file path
    mov %r8, %rsi                             # Use the same buffer for the response
    call file_open                            # Attempt to open the not found file

    cmp $-1, %rax                             # Check if the second file_open returned -1 (error)
    jl server_err                             # Jump to bad_request if it fails

    mov $HTTP_method_not_allowed_code, %rdx                             # Set error code to -3 (method not allowed)
    jmp finish_sock_read

server_err:
    # Clear the response_content_buffer before the next attempt
    mov %rdi, %rsi                           # Use the passed response_content_buffer pointer
    mov $response_content_buffer_size, %rsi   # Number of bytes to clear
    call clear_buffer

    lea bad_request_path(%rip), %rdi          # Load not_found_path as the file path
    mov %r8, %rsi                           # Use the same buffer for the response
    call file_open                            # Attempt to open the not found file

    mov $HTTP_serve_err_code, %rdx                             # Set error code to -4 (server error)


finish_sock_read:
    # mov %rax, %rax (file size is already in %rax after file_open)
    pop %rbp                                  # restore the caller's base pointer
    ret


 