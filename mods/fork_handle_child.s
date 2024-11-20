.section .bss
.lcomm response_content_buffer, response_content_buffer_size  # Allocate space for the file buffer

.section .text
.type fork_handle_child, @function
fork_handle_child:
push %rbp                    # save the caller's base pointer
mov %rsp, %rbp               # set the new base pointer (stack frame)

# child_process: 
lea response_content_buffer(%rip), %rdi
call sock_read

lea response_content_buffer(%rip), %rdi  # 1) Pass the content buffer pointer to sock_respond
mov %rax, %rsi                           # 2) Pass content size to sock_respond
mov %rdx, %rdx                           # 3) Pass Error code or 0 on success to sock_respond
call sock_respond            # Send response

mov $1, %rdi                 # passing 1 to indicate child process on sock_close
call sock_close_conn         # Close the connection for the child

call exit_program            # Exit the child process

pop %rbp
ret
