.section .text

.type fork_handle_child, @function
fork_handle_child:
push %rbp                    # save the caller's base pointer
mov %rsp, %rbp               # set the new base pointer (stack frame)

# child_process: 
call sock_respond            # Send response
mov $1, %rdi                # passing 1 to indicate child process on sock_close
call sock_close_conn         # Close the connection for the child
call exit_program            # Exit the child process
