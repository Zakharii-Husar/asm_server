.section .rodata
status_ok:       .ascii "HTTP/1.1 200 OK\r\n"
status_ok_length = . - status_ok

file_not_found_status: .ascii "HTTP/1.1 404 Not Found\r\n"
file_not_found_status_length = . - file_not_found_status

bad_request_status: .ascii "HTTP/1.1 400 Bad Request\r\n"
bad_request_status_length = . - bad_request_status

method_not_allowed_status: .ascii "HTTP/1.1 405 Method Not Allowed\r\n"
method_not_allowed_status_length = . - method_not_allowed_status

server_error_status: .ascii "HTTP/1.1 500 Internal Server Error\r\n"
server_error_status_length = . - server_error_status

.section .text
.globl create_status_header
.type create_status_header, @function
create_status_header:
    # Input: %rdi = HTTP status code
    #        %rsi = pointer to response buffer
    # Output: %rax = length of concatenated string (returned from str_cat)
    
    push %rbp
    mov %rsp, %rbp
    push %r12
    
    mov %rsi, %r12     # Save buffer pointer
    
    cmp $HTTP_OK_code, %rdi
    je .write_ok
    
    cmp $HTTP_file_not_found_code, %rdi
    je .write_not_found
    
    cmp $HTTP_bad_req_code, %rdi
    je .write_bad_request
    
    cmp $HTTP_method_not_allowed_code, %rdi
    je .write_method_not_allowed
    
    cmp $HTTP_serve_err_code, %rdi
    je .write_server_error
    
    # Default to 500 if unknown status code
    jmp .write_server_error

.write_ok:
    mov %r12, %rdi                      # destination buffer
    lea status_ok(%rip), %rsi           # source string
    mov $status_ok_length, %rdx         # length
    mov $response_header_B_size, %rcx
    call str_cat
    jmp .return_status_header                           # Jump to single return point

.write_not_found:
    mov %r12, %rdi
    lea file_not_found_status(%rip), %rsi
    mov $file_not_found_status_length, %rdx
    mov $response_header_B_size, %rcx
    call str_cat
    jmp .return_status_header                           # Jump to single return point

.write_bad_request:
    mov %r12, %rdi
    lea bad_request_status(%rip), %rsi
    mov $bad_request_status_length, %rdx
    mov $response_header_B_size, %rcx
    call str_cat
    jmp .return_status_header                           # Jump to single return point

.write_method_not_allowed:
    mov %r12, %rdi
    lea method_not_allowed_status(%rip), %rsi
    mov $method_not_allowed_status_length, %rdx
    mov $response_header_B_size, %rcx
    call str_cat
    jmp .return_status_header                           # Jump to single return point

.write_server_error:
    mov %r12, %rdi
    lea server_error_status(%rip), %rsi 
    mov $server_error_status_length, %rdx
    mov $response_header_B_size, %rcx
    call str_cat
    # Falls through to .return_status_header since it's the last one

.return_status_header:                                  # Changed label name from .return
    pop %r12
    pop %rbp
    ret
    