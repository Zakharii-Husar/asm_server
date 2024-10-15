# main.s

.section .data

.include "./asm_server/constants.s"

.section .text

    # Include function files
    .include "./asm_server/mods/sock_create.s"
    .include "./asm_server/mods/sock_bind.s"
    .include "./asm_server/mods/sock_listen.s"
    .include "./asm_server/mods/sock_accept.s"

    .include "./asm_server/utils/print_info.s"

    .global _start

_start:


    # ----------------------------
    # 1. Create Socket
    # ----------------------------
    call sock_create

    lea sock_created_msg(%rip), %rsi           # pointer to the message (from constants.s)
    movq $sock_created_msg_length, %rdx        # length of the message (from constants.s)

    call print_info
    # ----------------------------
    # 2. Bind Socket
    # ----------------------------
    call sock_bind

    lea sock_bound_msg(%rip), %rsi           # pointer to the message (from constants.s)
    movq $sock_bound_msg_length, %rdx        # length of the message (from constants.s)

    call print_info
    # 3. Listen for requests
    # ----------------------------
    call sock_listen

    lea sock_listen_msg(%rip), %rsi           # pointer to the message (from constants.s)
    movq $sock_listen_msg_length, %rdx        # length of the message (from constants.s)

    call print_info

    # 4. Accept connection
    # ----------------------------

    call sock_accept

# Check if the connection was successful
cmpq    $0, %rax                     # Compare the return value with 0
jl      .accept_error                # Jump if less than 0 (error)

# Print message indicating client connected
lea     client_connected_msg(%rip), %rsi  # Pointer to the message
movq    $client_connected_msg_length, %rdx # Length of the message
call    print_info                    # Call print function

jmp     .continue                    # Continue to the next part of your code

.accept_error:
# Handle connection error (optional, can log or print error)
# For example, you can print an error message or handle it as needed

.continue:
# Continue with your existing code                # Call print function

    # --------------------------------
    # 5. Send "Hello, World" response
    # --------------------------------
    movq    %rax, %rdi           # socket file descriptor from accept (in %rax) is moved to %rdi
    lea     response(%rip), %rsi # address of the response in %rsi
    movq    $response_len, %rdx  # length of the response in %rdx
    movq    $44, %rax            # sys_sendto (system call number for sending data: 44)
    xorq    %r10, %r10           # flags = 0
    syscall                      # send the data (response to browser)

    # --------------------------------
    # 6. Close the connection
    # --------------------------------
    movq    %rdi, %rdi           # socket file descriptor
    movq    $3, %rax             # sys_close (system call number for closing a file descriptor: 3)
    syscall                      # close the connection

     # Exit the program
    mov $SYS_exit, %rax
    xor %rdi, %rdi       # return code 0
    syscall
