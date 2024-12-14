.section .data

.section .bss
.lcomm req_B, req_B_size                             # For reading user request
.lcomm file_path_B, file_path_B_size                 # For built file path
.lcomm extension_B, extension_B_size                 # For extracted extension
.lcomm response_content_B, response_content_B_size   # For file content

.section .text
.type fork_handle_child, @function
fork_handle_child:
push %rbp                    # save the caller's base pointer
mov %rsp, %rbp               # set the new base pointer (stack frame)

lea req_B(%rip), %rdi
mov $req_B_size, %rsi
call clear_buffer

lea file_path_B(%rip), %rdi
mov $file_path_B_size, %rsi
call clear_buffer

lea extension_B(%rip), %rdi
mov $extension_B_size, %rsi
call clear_buffer   

# child_process: 
lea req_B(%rip), %rdi                # 1st param: request buffer
lea file_path_B(%rip), %rsi          # 2nd param: route buffer
lea extension_B(%rip), %rdx          # 3rd param: extension buffer
lea response_content_B(%rip), %rcx   # 4th param: response buffer
call sock_read                       # Returns: %rax=content size, %rdx=status code


lea response_content_B(%rip), %rdi
mov $723, %rsi
call print_info

# Prepare parameters for sock_respond (directly use return values from sock_read)
lea response_content_B(%rip), %rdi        # 1st param: response content buffer
mov %rax, %rsi                            # 2nd param: content size
# mov %rdx, %rdx                          # 3rd param: status code (already in correct register)
lea extension_B(%rip), %rcx               # 4th param: file extension
call sock_respond


mov $1, %rdi                 # passing 1 to indicate child process on sock_close
call sock_close_conn         # Close the connection for the child
call exit_program            # Exit the child process

pop %rbp
ret
