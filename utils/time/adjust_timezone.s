# Adjusts a UTC timestamp by adding the configured timezone offset
#
# Parameters:
#   %rdi - UTC timestamp (seconds since epoch)
#   CONF_TIMEZONE_OFFSET(%r15) - Timezone offset in ±HHMM format (e.g., +0530, -0800)
#
# Returns:
#   %rax - Adjusted timestamp in local time
#
# Error Handling:
#   - If timezone offset is invalid (outside -1200 to +1400),
#     logs error and returns original timestamp unchanged
#
.section .rodata
timezone_err_msg: .asciz "MODERATE: Invalid timezone offset in adjust_timezone.s"
timezone_err_msg_len = . - timezone_err_msg

.section .text  

.global adjust_timezone
.type adjust_timezone, @function
adjust_timezone:
    push %rbp
    mov %rsp, %rbp
    # Preserve non-volatile registers
    push %r12
    push %r13
    # Save arguments
    mov %rdi, %r12              # Store UTC timestamp
    
    # Get timezone offset
    mov CONF_TIMEZONE_OFFSET(%r15), %rax
    
    # Validate timezone offset
    cmp $1400, %rax
    jg .timezone_error
    cmp $-1200, %rax
    jl .timezone_error
    
    # Split into hours and minutes
    mov %rax, %r13              # Save original offset
    mov $100, %rcx
    cqo                         # Sign-extend RAX into RDX
    idiv %rcx                   # Divide by 100
                               # Now: RAX = hours, RDX = minutes
    
    # Convert hours to seconds (multiply by 3600)
    imul $3600, %rax, %rax
    
    # Convert minutes to seconds (multiply by 60)
    imul $60, %rdx, %rdx
    
    # Add hours and minutes
    add %rdx, %rax
    
    # Add the total offset to timestamp
    add %rax, %r12
    mov %r12, %rax              # Put result in return register


.exit_adjust_timezone:
    pop %r13
    pop %r12
    leave
    ret

.timezone_error:
    lea timezone_err_msg(%rip), %rdi
    mov $timezone_err_msg_len, %rsi
    call log_err
    mov %r12, %rax    # Return original timestamp on error
    jmp .exit_adjust_timezone
