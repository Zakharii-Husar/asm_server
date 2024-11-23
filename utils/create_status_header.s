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
    # Output: %rax = pointer to status string
    #         %rdx = length of status string
    
    cmp $HTTP_OK_code, %rdi
    je .return_ok
    
    cmp $HTTP_file_not_found_code, %rdi
    je .return_not_found
    
    cmp $HTTP_bad_req_code, %rdi
    je .return_bad_request
    
    cmp $HTTP_method_not_allowed_code, %rdi
    je .return_method_not_allowed
    
    cmp $HTTP_serve_err_code, %rdi
    je .return_server_error
    
    # Default to 500 if unknown status code
    jmp .return_server_error

.return_ok:
    lea status_ok(%rip), %rax
    mov $status_ok_length, %rdx
    ret

.return_not_found:
    lea file_not_found_status(%rip), %rax
    mov $file_not_found_status_length, %rdx
    ret

.return_bad_request:
    lea bad_request_status(%rip), %rax
    mov $bad_request_status_length, %rdx
    ret

.return_method_not_allowed:
    lea method_not_allowed_status(%rip), %rax
    mov $method_not_allowed_status_length, %rdx
    ret

.return_server_error:
    lea server_error_status(%rip), %rax
    mov $server_error_status_length, %rdx
    ret