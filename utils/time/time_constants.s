.section .data
.global days_per_month
.global days_per_month_leap
.global epoch_year

days_per_month:
    .byte 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
days_per_month_leap:
    .byte 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
epoch_year:
    .quad 1970