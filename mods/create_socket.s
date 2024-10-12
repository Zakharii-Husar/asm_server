.section .data

    # sys_call args
    .equ SYS_create_sock, 41

    # create socket args
    .equ AF_INET, 2 
    .equ SOCK_STREAM, 1
    .equ SOCK_PROTOCOL, 0

.section .text

# Create socket (AF_INET, SOCK_STREAM, 0)
mov $SYS_create_sock, %rax
mov $AF_INET, %rdi
mov $SOCK_STREAM, %rsi
mov $SOCK_PROTOCOL, %rdx
syscall
mov %rax, %rbx                    # store socket fd in %rbx

