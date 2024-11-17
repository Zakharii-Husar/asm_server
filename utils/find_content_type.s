# Function: find_content_type
# Input: 
#   %rdi - pointer to the file extension (extracted from the request)
# Output:
#   %rax - pointer to the corresponding MIME type string

.section .data

.section .rodata

// Extensions for comparison
ext_html:   .asciz ".html"
ext_html_length = . - ext_html
ext_css:    .asciz ".css"
ext_css_length = . - ext_css

ext_js:     .asciz ".js"
ext_js_length = . - ext_js

ext_jpg:    .asciz ".jpg"
ext_jpg_length = . - ext_jpg

ext_jpeg:   .asciz ".jpeg"
ext_jpeg_length = . - ext_jpeg

ext_png:    .asciz ".png"
ext_png_length = . - ext_png

ext_gif:    .asciz ".gif"
ext_gif_length = . - ext_gif

ext_webp:   .asciz ".webp"
ext_webp_length = . - ext_webp

ext_svg:    .asciz ".svg"
ext_svg_length = . - ext_svg

ext_ico:    .asciz ".ico"
ext_ico_length = . - ext_ico

// MIME types for return values
mime_css:    .asciz "text/css"
mime_css_length = . - mime_css

mime_js:     .asciz "text/javascript"
mime_js_length = . - mime_js

mime_html:   .asciz "text/html"
mime_html_length = . - mime_html

mime_jpeg:   .asciz "image/jpeg"
mime_jpeg_length = . - mime_jpeg

mime_png:    .asciz "image/png"
mime_png_length = . - mime_png

mime_gif:    .asciz "image/gif"
mime_gif_length = . - mime_gif

mime_webp:   .asciz "image/webp"
mime_webp_length = . - mime_webp

mime_svg:    .asciz "image/svg+xml"
mime_svg_length = . - mime_svg

mime_ico:    .asciz "image/x-icon"
mime_ico_length = . - mime_ico

.section .text

.type find_content_type, @function
find_content_type:
push %rbp                          # save the caller's base pointer
mov %rsp, %rbp                     # set the new base pointer (stack frame)

# cmp HTML extension
lea request_file_ext(%rip), %rsi
lea ext_html(%rip), %rdi
call str_cmp
cmp $1, %rax
je return_html

# cmp CSS extension
lea request_file_ext(%rip), %rsi
lea ext_css(%rip), %rdi
call str_cmp
cmp $1, %rax
je return_css

# cmp JS extension
lea request_file_ext(%rip), %rsi
lea ext_js(%rip), %rdi
call str_cmp
cmp $1, %rax
je return_js

# cmp JPG extension
lea request_file_ext(%rip), %rsi
lea ext_jpg(%rip), %rdi
call str_cmp
cmp $1, %rax
je return_jpeg

# cmp JPEG extension
lea request_file_ext(%rip), %rsi
lea ext_jpeg(%rip), %rdi
call str_cmp
cmp $1, %rax
je return_jpeg

# cmp PNG extension
lea request_file_ext(%rip), %rsi
lea ext_png(%rip), %rdi
call str_cmp
cmp $1, %rax
je return_png

# cmp GIF extension
lea request_file_ext(%rip), %rsi
lea ext_gif(%rip), %rdi
call str_cmp
cmp $1, %rax
je return_gif

# cmp WEBP extension
lea request_file_ext(%rip), %rsi
lea ext_webp(%rip), %rdi
call str_cmp
cmp $1, %rax
je return_webp

# cmp SVG extension
lea request_file_ext(%rip), %rsi
lea ext_svg(%rip), %rdi
call str_cmp
cmp $1, %rax
je return_svg

# cmp ICO extension
lea request_file_ext(%rip), %rsi
lea ext_ico(%rip), %rdi
call str_cmp
cmp $1, %rax
je return_ico

return_html:
lea mime_html(%rip), %rax          # Load effective address of mime_html string
jmp exit_find_content_type         # Jump to the exit point

return_css:
lea mime_css(%rip), %rax          # Load effective address of mime_css string
jmp exit_find_content_type

return_js:
lea mime_js(%rip), %rax
jmp exit_find_content_type

return_jpeg:
lea mime_jpeg(%rip), %rax
jmp exit_find_content_type

return_png:
lea mime_png(%rip), %rax
jmp exit_find_content_type

return_gif:
lea mime_gif(%rip), %rax
jmp exit_find_content_type

return_webp:
lea mime_webp(%rip), %rax
jmp exit_find_content_type

return_svg:
lea mime_svg(%rip), %rax
jmp exit_find_content_type

return_ico:
lea mime_ico(%rip), %rax
jmp exit_find_content_type

exit_find_content_type:
pop %rbp                           # restore the caller's base pointer
ret                                # return to the caller
