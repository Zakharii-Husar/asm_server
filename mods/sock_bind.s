.section .data

    # sys_call args
    .equ SYS_sock_bind, 49

    # sock bind args
    .equ AF_INET, 2    # AF_INET (IPv4)
    .equ PORT, 8080    # Port number (8080) in network byte order (use htons equivalent in assembly)
    .equ IP_ADDR, 0    # IP address (0.0.0.0 - binds to all interfaces)
    .equ PADDING, 8    # Padding (8 bytes to make the structure 16 bytes in total)

addr_in:
    .word   AF_INET
    .word   PORT
    .long   IP_ADDR
    .space  PADDING

.section .text

  movq    $SYS_sock_bind, %rax            #sys_bind
  movq    %rbx, %rdi                      #socket file descriptor (saved in rbx)
  lea     addr_in(%rip), %rsi             #pointer to the address structure
  movq    $16, %rdx                       #size of the sockaddr_in structure
  syscall                                 #make syscall
