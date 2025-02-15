# Function: create_server_header
# Parameters:
#   - %rdi: pointer to response buffer
#   - %rsi: max buffer size
#   - %rdx: max buffer size
# Global Registers:
#   - %r15: server configuration pointer (for server name)
# Return Values:
#   - %rax: length of concatenated string
# Error Handling:
#   - Truncates if buffer size exceeded
#   - Uses default server name if not configured
# Side Effects:
#   - Modifies response buffer

.section .rodata

server_header:    .asciz "Server: "
server_header_length = . - server_header

.section .text
.globl create_server_header
.type create_server_header, @function

create_server_header:
    push %rbp                          # save the caller's base pointer
    mov %rsp, %rbp                     # set the new base pointer
    push %r12                          # save the destination buffer
    push %r13                          # save the max buffer size

    mov %rdi, %r12                    # destination buffer
    mov %rsi, %r13                    # max buffer size


    mov %r12, %rdi                    # destination buffer
    mov %r13, %rcx                     # move max_size to %rcx for str_cat
    lea server_header(%rip), %rsi
    mov $server_header_length, %rdx
    call str_cat

    mov %r12, %rdi                    # destination buffer
    mov %r13, %rcx                     # move max_size to %rcx for str_cat
    lea CONF_SERVER_NAME_OFFSET(%r15), %rsi      # source string
    xor %rdx, %rdx                     # length
    call str_cat                    # concatenate the server header


    mov %r12, %rdi # destination buffer
    mov %r13, %rcx # max buffer size
    lea CRLF(%rip), %rsi
    mov $CRLF_length, %rdx
    call str_cat

    pop %r13
    pop %r12
    leave
    ret
    