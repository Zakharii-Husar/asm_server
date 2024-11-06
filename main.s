.section .bss
.lcomm original_string, 8192 

.section .data

str_2:    .asciz "string_2"
str_2_length = . - str_2

str_3:    .asciz "string_3"
str_3_length = . - str_3

.include "./asm_server/constants.s"

.section .text

    # Include function files
    .include "./asm_server/mods/sock_create.s"
    .include "./asm_server/mods/sock_bind.s"
    .include "./asm_server/mods/sock_listen.s"
    .include "./asm_server/mods/sock_accept.s"
    .include "./asm_server/mods/sock_read.s"
    .include "./asm_server/mods/sock_respond.s"
    .include "./asm_server/mods/sock_close_conn.s"

    .include "./asm_server/mods/process_fork.s"
    .include "./asm_server/mods/fork_handle_child.s"
    .include "./asm_server/mods/fork_handle_parent.s"

    .include "./asm_server/mods/exit_program.s"

    .include "./asm_server/utils/print_info.s"
    .include "./asm_server/utils/int_to_string.s"
    .include "./asm_server/utils/file_open.s"
    .include "./asm_server/utils/extract_route.s"
    .include "./asm_server/utils/extract_method.s"
    .include "./asm_server/utils/str_len.s"
    .include "./asm_server/utils/str_cmp.s"
    .include "./asm_server/utils/str_concat.s"
    .global _start

_start:

.type main, @function
main:

    # Call str_concat with original_string and str_2
    mov $original_string, %rdi          # First arg: destination buffer
    mov $str_2, %rsi          # Second arg: source string
    mov $str_2_length, %rdx   # Third arg: string length
    call str_concat

    lea original_string(%rip), %rsi      # pointer to the message (from constants.s)
    mov %rax, %rdx    # length of the message (from constants.s)
    call print_info

        # Call str_concat with original_string and str_3
    mov $original_string, %rdi          # First arg: destination buffer
    mov $str_3, %rsi          # Second arg: source string
    mov $str_3_length, %rdx   # Third arg: string length
    call str_concat

    lea original_string(%rip), %rsi      # pointer to the message (from constants.s)
    mov %rax, %rdx    # length of the message (from constants.s)
    call print_info

    # FUNCTION ARGS
    
    # ----------------------------
    # 1. Create Socket
    # ----------------------------
    call sock_create
    # ----------------------------
    # 2. Bind Socket
    # ----------------------------
    call sock_bind
    # ----------------------------
    # 3. Listen for requests
    # ----------------------------
    call sock_listen

    # Main server loop (parent process will jump here after forking)
main_loop:
    # ----------------------------
    # 4. Accept connection (blocking call)
    # ----------------------------
    call sock_accept
    # --------------------------------
    # 5. Fork the process(child reads and responds to a user and parent
    # is going back to accepting new connections)
    # --------------------------------

    call process_fork
    cmp $0, %rax               # Check if we're in the child or parent
    jg parent_process

    # for child process handle user request and close the program 
    child_process:
    call fork_handle_child

    # for  parent process close connection and repeate the cycle
    parent_process:
    call fork_handle_parent

jmp main_loop
