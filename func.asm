section	.text
global  scale_bitmap

scale_bitmap:
  ; arguments
	; =================
	; rdi = &dst_bitmap
	; rsi = &src_bitmap
	; rdx = src_width
	; rcx = src_height
	; =================

  push rbp
  mov rbp, rsp

  ; local variables
  ; =======================================
  push rdi ; src_ptr [rbp-8] = &dst_bitmap
  push rsi ; dst_ptr [rbp-16] = &src_bitmap
  ; =======================================

	mov rax, rdx
	mul rcx      ; rax = width * height
	mov rcx, 3
	mul rcx      ; rax = width * height * 3

  ; local variables
  ; ===============================================
  push rax ; src_size [rbp-24] = width * height * 3
	push 0   ; counter  [rbp-32] = 0
  push 0   ; left_top  [rbp-40]    - array of 8 bytes (only 3 used)
  push 0   ; right_top [rbp-48]    - array of 8 bytes (only 3 used)
  push 0   ; left_bottom  [rbp-56] - array of 8 bytes (only 3 used)
  push 0   ; right_bottom [rbp-60] - array of 8 bytes (only 3 used)
  ; ===============================================

loop:
  mov rax, [rbp-16] ; bl = *src_ptr
	mov bl, [rax]

  inc rax           ; src_ptr++
  mov [rbp-16], rax

  mov rax, [rbp-8]  ; *dst_ptr = bl
	mov [rax], bl

  inc rax           ; dst_ptr++
  mov [rbp-8], rax

  mov rax, [rbp-32] ; counter++
	inc rax
  mov [rbp-32], rax

	cmp rax, [rbp-24] ; while (counter < src_size)
	jl loop

end:
  mov rsp, rbp
  pop rbp
	ret

read_pixel:
  ; arguments
  ; ===================
  ; rdi = &pixel_buffer
  ; rsi = x
  ; rdx = y
  ; rcx = src_width
  ; r8 = src_bitmap
  ; ===================

  push rbp
  mov rbp, rsp

  ; local variables
  ; =============================
  push rdi ; pixel_buffer [rbp-8]
  push rsi ; x [rbp-16]
  push rdx ; y [rbp-24]
  push rcx ; src_width  [rbp-32]
  push r8  ; src_ptr    [rbp-40]
  ; =============================

  mov rax, [rbp-24] ; y
  mov rbx, [rbp-32] ; src_width
  mul rbx           ; y*src_width

  mov rax, 3
  mul rbx           ; y*src_width*3

  mov rax, 3
  mov rcx, [rbp-16] ; x
  mul rcx           ; x*3

  add rbx, rcx      ; y*src_width*3 + x*3

  ; local variables
  ; ====================================================
  push rbx ; pixel_number [rbp-48] = y*src_width*3 + x*3
  ; ====================================================

  mov rbx, [rbp-40] ; src_ptr
  add rbx, [rbp-48] ; src_ptr + pixel_number

  mov rax, [rbx]    ; read BLUE
  mov [rbp-8], rax  ; pixel_buffer[0] = BLUE

  mov rax, [rbx+1]  ; read GREEN
  mov [rbp-8], rax  ; pixel_buffer[1] = GREEN

  mov rax, [rbx+2]  ; read RED
  mov [rbp-8], rax  ; pixel_buffer[2] = RED

read_pixel_exit:
  mov rsp, rbp
  pop rbp
  ret

;============================================
; STOS
;============================================
;
; wieksze adresy
;
;  |                             |
;  | ...                         |
;  -------------------------------
;  | parametr funkcji            | RBP+16
;  -------------------------------
;  | adres powrotu               | RBP+8
;  -------------------------------
;  | zachowane rbp               | RBP, RSP
;  -------------------------------
;  | ... tu ew. zmienne lokalne  | RBP-8n
;  |                             |
;
; \/                         \/
; \/ w ta strone rosnie stos \/
; \/                         \/
;
; mniejsze adresy
;
;
;============================================
