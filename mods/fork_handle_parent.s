# fork_handle_parent: Handles the fork for the parent process.
# Parameters:
#   - None (implicitly uses %rdi for sock_close_conn)
# Return Value:
#   - None (returns to the caller)


.section .text

.type fork_handle_parent, @function
fork_handle_parent:
    push %rbp                    # save the caller's base pointer
    mov %rsp, %rbp               # set the new base pointer (stack frame)

    mov $0, %rdi                # passing 0 to indicate parent process on sock_close
    call sock_close_conn         # Close the connection for the parent

    pop %rbp                     # restore the caller's base pointer
    ret                           # return to the caller
    