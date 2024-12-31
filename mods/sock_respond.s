# Parameters:
# - %rdi: response content buffer
# - %rsi: content size
# - %rdx: status code
# - %rcx: file extension
# Implicit parameters:
# - %r13 Connection file descriptor;

.section .data
    .equ response_header_B_size, 1024

.section .bss
    .lcomm response_header_B, response_header_B_size

.section .rodata


sock_respond_err_msg:    .asciz "CRITICAL: Failed to respond to the client in sock_respond.s"
sock_respond_err_msg_length = . - sock_respond_err_msg

# Double CRLF to separate headers from body
headers_end:    .ascii "\r\n"
headers_end_length = . - headers_end

.section .text
# Function: sock_respond
# Parameters:
#   - %rdi: file path pointer
#   - %rsi: HTTP status code
# Global Registers:
#   - %r12: socket file descriptor
#   - %r13: connection file descriptor
#   - %r14: content size
#   - %r15: server configuration pointer
# Return Values:
#   - None
# Error Handling:
#   - Logs errors if file operations fail
#   - Sends appropriate HTTP status codes
# Side Effects:
#   - Writes to socket
#   - Modifies response buffers
#   - Calls logging functions

.type sock_respond, @function
sock_respond:
    push %rbp                           # save the caller's base pointer
    mov %rsp, %rbp                      # set the new base pointer (stack frame)
    sub $8, %rsp                        # align stack to 16-byte boundary

    push %r12
    push %r14
    push %rcx

    mov %rdi, %r12                      # response content buffer
    mov %rsi, %r14                      # content size

    push %rdx
    lea response_header_B(%rip), %rdi
    mov $response_header_B_size, %rsi
    call clear_buffer
    pop %rdx       
    
     

    # ADD HTTP STATUS LINE TO RESPONSE HEADER
    mov %rdx, %rdi                    # Move status code to first parameter
    lea response_header_B(%rip), %rsi  # Add this line: pass buffer pointer as second parameter
    call create_status_header         # Returns ptr in %rax, len in %rdx

    # ADD CONTENT-LENGTH HEADER TO RESPONSE HEADER
    lea response_header_B(%rip), %rdi # destination
    mov %r14, %rsi # content size
    call create_length_header

    pop %rcx
    # ADD CONTENT-TYPE HEADER TO RESPONSE HEADER
    lea response_header_B(%rip), %rdi       # destination buffer
    mov %rcx, %rsi                          # file extension buffer pointer
    call create_type_header                 # returns length in %rax

    lea response_header_B(%rip), %rdi      # destination buffer
    mov $response_header_B_size, %rsi      # max buffer size
    call create_server_header
    

    # ADD FINAL DOUBLE CRLF TO SEPARATE HEADERS FROM BODY
    lea response_header_B(%rip), %rdi
    lea headers_end(%rip), %rsi
    mov $headers_end_length, %rdx
    mov $response_header_B_size, %rcx
    call str_cat
    
    # Get the actual length of the complete header
    lea response_header_B(%rip), %rdi
    call str_len              # Get the total length of headers

    # check if the server is shutting down
    movq server_shutdown_flag(%rip), %r8
    test %r8, %r8
    jnz .exit_sock_respond

    # SEND THE HEADER
    mov %rax, %rdx                 # Length of the entire header
    mov $SYS_write, %rax           # syscall number for write
    mov %r13, %rdi                 # File descriptor
    lea response_header_B(%rip), %rsi  # Pointer to the beginning of the header
    syscall
    cmp $0, %rax
    jl .handle_sock_respond_err
    
    # check if the server is shutting down
    movq server_shutdown_flag(%rip), %r8
    test %r8, %r8
    jnz .exit_sock_respond

    # SEND THE CONTENT
    mov $SYS_write, %rax           # syscall number for write
    mov %r13, %rdi                 # File descriptor
    mov %r12 , %rsi                # Pointer to the content buffer
    mov %r14, %rdx                 # Length of the content
    syscall
    cmp $0, %rax                               # Compare the return value with 0
    jl  .handle_sock_respond_err                # Jump to error handling if %rax < 0


   .exit_sock_respond:
    pop %r14
    pop %r12
    leave                               # restore stack frame
    ret                                 # return to the caller

.handle_sock_respond_err:
    lea sock_respond_err_msg(%rip), %rdi
    mov $sock_respond_err_msg_length, %rsi
    mov %rax, %rdx                      # error code
    call log_err
    jmp .exit_sock_respond
    