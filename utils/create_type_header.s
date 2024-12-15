# Function: create_type_header
# Input: 
#   %rdi - pointer to response buffer
#   %rsi - file extension
# Output:
#   %rax - length of concatenated string

.section .rodata

// Extensions for comparison
ext_html:   .ascii ".html"
ext_html_length = . - ext_html
ext_css:    .ascii ".css"
ext_css_length = . - ext_css

ext_js:     .ascii ".js"
ext_js_length = . - ext_js

ext_jpg:    .ascii ".jpg"
ext_jpg_length = . - ext_jpg

ext_jpeg:   .ascii ".jpeg"
ext_jpeg_length = . - ext_jpeg

ext_png:    .ascii ".png"
ext_png_length = . - ext_png

ext_gif:    .ascii ".gif"
ext_gif_length = . - ext_gif

ext_webp:   .ascii ".webp"
ext_webp_length = . - ext_webp

ext_svg:    .ascii ".svg"
ext_svg_length = . - ext_svg

ext_ico:    .ascii ".ico"
ext_ico_length = . - ext_ico

// MIME types for return values
mime_css:    .ascii "Content-Type: text/css\r\n"
mime_css_length = . - mime_css

mime_js:     .ascii "Content-Type: text/javascript\r\n"
mime_js_length = . - mime_js

mime_html:   .ascii "Content-Type: text/html\r\n"
mime_html_length = . - mime_html

mime_jpeg:   .ascii "Content-Type: image/jpeg\r\n"
mime_jpeg_length = . - mime_jpeg

mime_png:    .ascii "Content-Type: image/png\r\n"
mime_png_length = . - mime_png

mime_gif:    .ascii "Content-Type: image/gif\r\n"
mime_gif_length = . - mime_gif

mime_webp:   .ascii "Content-Type: image/webp\r\n"
mime_webp_length = . - mime_webp

mime_svg:    .ascii "Content-Type: image/svg+xml\r\n"
mime_svg_length = . - mime_svg

mime_ico:    .ascii "Content-Type: image/x-icon\r\n"
mime_ico_length = . - mime_ico

.section .text

.type create_type_header, @function
create_type_header:
push %rbp                          # save the caller's base pointer
mov %rsp, %rbp                     # set the new base pointer (stack frame)
push %r12
push %r13
mov %rdi, %r12           # Save buffer pointer
mov %rsi, %r13           # Save extension pointer

# cmp HTML extension
mov %r13, %rsi
lea ext_html(%rip), %rdi
call str_cmp
cmp $1, %rax
je .write_html

# cmp CSS extension
mov %r13, %rsi
lea ext_css(%rip), %rdi
call str_cmp
cmp $1, %rax
je .write_css

# cmp JS extension
mov %r13, %rsi
lea ext_js(%rip), %rdi
call str_cmp
cmp $1, %rax
je .write_js

# cmp JPG extension
mov %r13, %rsi
lea ext_jpg(%rip), %rdi
call str_cmp
cmp $1, %rax
je .write_jpeg

# cmp JPEG extension
mov %r13, %rsi
lea ext_jpeg(%rip), %rdi
call str_cmp
cmp $1, %rax
je .write_jpeg

# cmp PNG extension
mov %r13, %rsi
lea ext_png(%rip), %rdi
call str_cmp
cmp $1, %rax
je .write_png

# cmp GIF extension
mov %r13, %rsi
lea ext_gif(%rip), %rdi
call str_cmp
cmp $1, %rax
je .write_gif

# cmp WEBP extension
mov %r13, %rsi
lea ext_webp(%rip), %rdi
call str_cmp
cmp $1, %rax
je .write_webp

# cmp SVG extension
mov %r13, %rsi
lea ext_svg(%rip), %rdi
call str_cmp
cmp $1, %rax
je .write_svg

# cmp ICO extension
mov %r13, %rsi
lea ext_ico(%rip), %rdi
call str_cmp
cmp $1, %rax
je .write_ico

.write_html:
mov %r12, %rdi                      # destination buffer
lea mime_html(%rip), %rsi           # source string
mov $mime_html_length, %rdx         # length
call str_concat
jmp .return

.write_css:
mov %r12, %rdi                      # destination buffer
lea mime_css(%rip), %rsi           # source string
mov $mime_css_length, %rdx         # length
call str_concat
jmp .return

.write_js:
mov %r12, %rdi                      # destination buffer
lea mime_js(%rip), %rsi           # source string
mov $mime_js_length, %rdx         # length
call str_concat
jmp .return

.write_jpeg:
mov %r12, %rdi                      # destination buffer
lea mime_jpeg(%rip), %rsi           # source string
mov $mime_jpeg_length, %rdx         # length
call str_concat
jmp .return

.write_png:
mov %r12, %rdi                      # destination buffer
lea mime_png(%rip), %rsi           # source string
mov $mime_png_length, %rdx         # length
call str_concat
jmp .return

.write_gif:
mov %r12, %rdi                      # destination buffer
lea mime_gif(%rip), %rsi           # source string
mov $mime_gif_length, %rdx         # length
call str_concat
jmp .return

.write_webp:
mov %r12, %rdi                      # destination buffer
lea mime_webp(%rip), %rsi           # source string
mov $mime_webp_length, %rdx         # length
call str_concat
jmp .return

.write_svg:
mov %r12, %rdi                      # destination buffer
lea mime_svg(%rip), %rsi           # source string
mov $mime_svg_length, %rdx         # length
call str_concat
jmp .return

.write_ico:
mov %r12, %rdi                      # destination buffer
lea mime_ico(%rip), %rsi           # source string
mov $mime_ico_length, %rdx         # length
call str_concat
jmp .return

.return:
pop %r13
pop %r12
pop %rbp
ret
