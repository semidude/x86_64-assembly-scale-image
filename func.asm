section	.text
global  scale_bitmap

scale_bitmap:
  ; arguments
	; =================
	; rdi = &dst_bitmap
	; rsi = &src_bitmap
	; rdx = src_width
	; rcx = src_height
  ; r8 = dst_width
  ; r9 = dst_height
	; =================

  push rbp
  mov rbp, rsp

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

  cvtsi2sd xmm0, [rbp-24] ; xmm0 = (double) src_width
  cvtsi2sd xmm1, [rbp-40] ; xmm1 = (double) dst_width
  divsd xmm0, xmm1
  movsd [rbp-176], xmm0   ; ratio_x = (double)src_width / (double)dst_width

  cvtsi2sd xmm0, [rbp-32] ; xmm0 = (double) src_height
  cvtsi2sd xmm1, [rbp-48] ; xmm1 = (double) dst_height
  divsd xmm0, xmm1
  movsd [rbp-184], xmm0   ; ratio_y = (double)src_height / (double)dst_height

loop:
  cvtsi2sd xmm0, [rbp-64] ; xmm0 = (double)i
  movsd xmm1, [rbp-176]   ; xmm1 = ratio_x
  mulsd xmm0, xmm1
  movsd [rbp-144]         ; x = i * ratio_x

  cvtsi2sd xmm0, [rbp-72] ; xmm0 = (double)j
  movsd xmm1, [rbp-184]   ; xmm1 = ratio_y
  mulsd xmm0, xmm1
  movsd [rbp-152]         ; y = j * ratio_y

  cvttsd2si rax, [rbp-144]
  mov [rbp-112], rax      ; left = (int)x
  add rax, 1
  mov [rbp-120], rax      ; right = (int)x + 1

  cvttsd2si rax, [rbp-152]
  mov [rbp-128], rax      ; bottom = (int)y
  add rax, 1
  mov [rbp-136], rax      ; top = (int)y + 1

  mov rax, [rbp-120]  ; rax = right
  mov rbx, [rbp-24]   ; rbx = src_width
  cmp rax, rbx
  jg not_edge_right
  mov rax, [rbp-112]
  mov [rbp-120], rax  ; right = left

not_edge_right:
  mov rax, [rbp-136]  ; rax = top
  mov rbx, [rbp-32]   ; rbx = src_height
  cmp rax, rbx
  jg not_edge_top
  mov rax, [rbp-128]
  mov [rbp-136], rax  ; top = bottom

not_edge_top:
  movsd xmm0, [rbp-144] ; xmm0 = x
  movsd xmm1, [rbp-112] ; xmm1 = left
  subsd xmm0, xmm1
  movsd [rbp-160], xmm0 ; a = x - left

  movsd xmm0, [rbp-152] ; xmm0 = y
  movsd xmm1, [rbp-128] ; xmm1 = bottom
  subsd xmm0, xmm1
  movsd [rbp-160], xmm0 ; b = y - bottom

  ; mov rax, [rbp-16] ; bl = *src_ptr
	; mov bl, [rax]
  ;
  ; inc rax           ; src_ptr++
  ; mov [rbp-16], rax
  ;
  ; mov rax, [rbp-8]  ; *dst_ptr = bl
	; mov [rax], bl
  ;
  ; inc rax           ; dst_ptr++
  ; mov [rbp-8], rax
  ;
  ; mov rax, [rbp-192] ; counter++
	; inc rax
  ; mov [rbp-192], rax
  ;
	; cmp rax, [rbp-56] ; while (counter < src_size)
	; jl loop

end:
  mov rsp, rbp
  pop rbp
	ret

read_pixel:
  ; arguments
  ; ====================
  ; rdi = &pixel_buffer
  ; rsi = x
  ; rdx = y
  ; rcx = src_width
  ; r8 = src_ptr
  ; ====================

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
