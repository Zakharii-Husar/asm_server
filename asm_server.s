.section .text
    .global _start

_start:

    # ----------------------------
    # 1. Create Socket
    # ----------------------------
    .include "./asm_server/mods/sock_create.s"
    # ----------------------------
    # 2. Bind Socket
    # ----------------------------
    .include "./asm_server/mods/sock_bind.s"
    # 3. Listen for requests
    # ----------------------------
    .include "./asm_server/mods/sock_listen.s"

     # Exit the program
    mov $60, %rax        # 60 is the syscall number for exit
    xor %rdi, %rdi       # return code 0
    syscall              # invoke the exit system call
