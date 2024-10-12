.section .text
    .global _start

_start:

    # ----------------------------
    # 1. Create Socket
    # ----------------------------
    .include "./asm_server/mods/create_socket.s"
    # ----------------------------
    # 2. Bind Socket
    # ----------------------------
    .include "./asm_server/mods/bind_socket.s"

     # Exit the program
    mov $60, %rax        # 60 is the syscall number for exit
    xor %rdi, %rdi       # return code 0
    syscall              # invoke the exit system call
