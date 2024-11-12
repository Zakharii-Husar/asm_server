.type extract_extension, @function
extract_extension:
push %rbp                          # save the caller's base pointer
mov %rsp, %rbp                     # set the new base pointer (stack frame)

pop %rbp                           # restore the caller's base pointer
ret  