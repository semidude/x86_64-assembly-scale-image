; local variables
; =======================================
push rdi ; dst_ptr [rbp-8] = &dst_bitmap
push rsi ; src_ptr [rbp-16] = &src_bitmap
push rdx ; src_width [rbp-24]
push rcx ; src_height [rbp-32]
push r8  ; dst_width  [rbp-40]
push r9  ; dst_height [rbp-48]
; =======================================

mov rax, rdx
mul rcx      ; rax = width * height
mov rcx, 3
mul rcx      ; rax = width * height * 3

; local variables
; =================================================================
push rax ; src_size [rbp-56] = width * height * 3
push 0   ; i [rbp-64] = 0
push 0   ; j [rbp-72] = 0

push 0   ; left_top     [rbp-80]  - array of 8 bytes (only 3 used)
push 0   ; right_top    [rbp-88]  - array of 8 bytes (only 3 used)
push 0   ; left_bottom  [rbp-96]  - array of 8 bytes (only 3 used)
push 0   ; right_bottom [rbp-104] - array of 8 bytes (only 3 used)

push 0   ; left   [rbp-112]
push 0   ; right  [rbp-120]
push 0   ; bottom [rbp-128]
push 0   ; top    [rbp-136]

push 0   ; x [rbp-144] : double
push 0   ; y [rbp-152] : double

push 0   ; a [rbp-160] : double
push 0   ; b [rbp-168] : double

push 0   ; ratio_x [rbp-176]
push 0   ; ratio_y [rbp-184]

push 0   ; counter [rbp-192]
; =================================================================
