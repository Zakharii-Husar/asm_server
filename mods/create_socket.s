.section .data

    # sys_call args
    .equ SYS_socket, 41

    # create socket args
    .equ AF_INET, 2 
    .equ SOCK_STREAM, 1
    .equ SOCK_PROTOCOL, 0

.section .text

# Create socket (AF_INET, SOCK_STREAM, 0)
mov $SYS_socket, %rax        # move the immediate value into %rax
mov $AF_INET, %rdi           # move the immediate value into %rdi
mov $SOCK_STREAM, %rsi       # move the immediate value into %rsi
mov $SOCK_PROTOCOL, %rdx     # move the immediate value into %rdx
syscall                      # make the syscall
mov %rax, %rbx               # store socket fd in %rbx

