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
	mul rcx      ; rax = dst_width * dst_height
	mov rcx, 3
	mul rcx      ; rax = width * height * 3

  ; local variables
  ; =================================================================
  push rax ; dst_size [rbp-56] = width * height * 3
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

  mov rax, [rbp-8];
  add rax, 3
  mov [rbp-8], rax

  cvtsi2sd xmm0, [rbp-24] ; xmm0 = (double) src_width
  cvtsi2sd xmm1, [rbp-40] ; xmm1 = (double) dst_width
  divsd xmm0, xmm1
  movsd [rbp-176], xmm0   ; ratio_x = (double)src_width / (double)dst_width

  cvtsi2sd xmm0, [rbp-32] ; xmm0 = (double) src_height
  cvtsi2sd xmm1, [rbp-48] ; xmm1 = (double) dst_height
  divsd xmm0, xmm1
  movsd [rbp-184], xmm0   ; ratio_y = (double)src_height / (double)dst_height

loop:
  ; loop checking
  ; ========================================================
  mov rax, [rbp-40]   ; dst_width
  sub rax, 1          ; dst_width-1
  cmp [rbp-64], rax   ; cmp i and dst_width-1
  jge not_middle_line ; if (i >= dst_width-1) jump
  mov rax, [rbp-64]
  add rax, 1          ; i++
  mov [rbp-64], rax
  jmp processing

not_middle_line:
  mov rax, [rbp-48]
  sub rax, 1
  cmp [rbp-72], rax     ; cmp j and dst_height
  jge end               ; if (j >= dst_height) jump
  mov [rbp-64], DWORD 0 ; i = 0
  mov rax, [rbp-72]
  add rax, 1            ; j++
  mov [rbp-72], rax

processing:
  ; compute x, y
  ; ========================================================
  cvtsi2sd xmm0, [rbp-64] ; xmm0 = (double)i
  movsd xmm1, [rbp-176]   ; xmm1 = ratio_x
  mulsd xmm0, xmm1
  movsd [rbp-144], xmm0   ; x = i * ratio_x

  cvtsi2sd xmm0, [rbp-72] ; xmm0 = (double)j
  movsd xmm1, [rbp-184]   ; xmm1 = ratio_y
  mulsd xmm0, xmm1
  movsd [rbp-152], xmm0   ; y = j * ratio_y

  ; compute left, right, top, bottom
  ; ========================================================
  movsd xmm0, [rbp-144]
  cvttsd2si rax, xmm0
  mov [rbp-112], rax      ; left = (int)x

  movsd xmm0, [rbp-144]
  cvttsd2si rax, xmm0
  add rax, 1
  mov [rbp-120], rax      ; right = (int)x + 1

  cvttsd2si rax, [rbp-152]
  mov [rbp-128], rax      ; bottom = (int)y
  add rax, 1
  mov [rbp-136], rax      ; top = (int)y + 1

  ; check edges right and top
  ; ========================================================
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
  ; compute a, b
  ; ========================================================
  movsd xmm0, [rbp-144]  ; xmm0 = x
  cvtsi2sd xmm1, [rbp-112]  ; xmm1 = left
  subsd xmm0, xmm1
  movsd [rbp-160], xmm0  ; a = x - left

  movsd xmm0, [rbp-152]  ; xmm0 = y
  cvtsi2sd xmm1, [rbp-128]  ; xmm1 = bottom
  subsd xmm0, xmm1
  movsd [rbp-168], xmm0  ; b = y - bottom

  ; read pixels
  ; ========================================================
  mov rax, rbp
  sub rax, 80        ; rax = rbp-80 (left_top)
  mov rdi, rax       ; pixel_buffer = left_top
  mov rsi, [rbp-112] ; x = left
  mov rdx, [rbp-136] ; y = top
  mov rcx, [rbp-24]  ; src_width = src_width
  mov r8, [rbp-16]   ; src_ptr = src_ptr
  call read_pixel

  mov rax, rbp
  sub rax, 88        ; rax = rbp-88 (right_top)
  mov rdi, rax       ; pixel_buffer = right_top
  mov rsi, [rbp-120] ; x = right
  mov rdx, [rbp-136] ; y = top
  mov rcx, [rbp-24]  ; src_width = src_width
  mov r8, [rbp-16]   ; src_ptr = src_ptr
  call read_pixel

  mov rax, rbp
  sub rax, 96        ; rax = rbp-98 (left_bottom)
  mov rdi, rax       ; pixel_buffer = left_bottom
  mov rsi, [rbp-112] ; x = left
  mov rdx, [rbp-128] ; y = bottom
  mov rcx, [rbp-24]  ; src_width = src_width
  mov r8, [rbp-16]   ; src_ptr = src_ptr
  call read_pixel

  mov rax, rbp
  sub rax, 104       ; rax = rbp-104 (right_bottom)
  mov rdi, rax       ; pixel_buffer = right_bottom
  mov rsi, [rbp-120] ; x = right
  mov rdx, [rbp-128] ; y = bottom
  mov rcx, [rbp-24]  ; src_width = src_width
  mov r8, [rbp-16]   ; src_ptr = src_ptr
  call read_pixel

  ; interpolation
  ; ========================================================
  mov rax, QWORD 0
  mov al, [rbp-80]
  mov rdi, rax       ; F_00 = left_top.R

  mov al, [rbp-88]
  mov rsi, rax       ; F_10 = right_top.R

  mov al, [rbp-96]
  mov rdx, rax       ; F_01 = left_bottom.R

  mov al, [rbp-104]
  mov rcx, rax       ; F_11 = right_bottom.R

  mov r8, [rbp-160]  ; a = a
  mov r9, [rbp-168]  ; b = b

  call interpolate
  mov r10, rax



  mov rax, QWORD 0
  mov al, [rbp-79]
  mov rdi, rax       ; F_00 = left_top.G

  mov al, [rbp-87]
  mov rsi, rax       ; F_10 = right_top.G

  mov al, [rbp-95]
  mov rdx, rax       ; F_01 = left_bottom.G

  mov al, [rbp-103]
  mov rcx, rax       ; F_11 = right_bottom.G

  mov r8, [rbp-160]  ; a = a
  mov r9, [rbp-168]  ; b = b
  call interpolate
  mov r11, rax


  mov rax, QWORD 0
  mov al, [rbp-78]
  mov rdi, rax        ; F_00 = left_top.B

  mov al, [rbp-86]
  mov rsi, rax        ; F_10 = right_top.B

  mov al, [rbp-94]
  mov rdx, rax        ; F_01 = left_bottom.B

  mov al, [rbp-102]
  mov rcx, rax        ; F_11 = right_bottom.B

  mov r8, [rbp-160]  ; a = a
  mov r9, [rbp-168]  ; b = b
  call interpolate
  mov r12, rax

  ; save to output bitmap
  ; ========================================================
  mov rax, [rbp-8]  ; rax = dst_ptr

  mov [rax], r10b   ; RED
  mov [rax+1], r11b ; GREEN
  mov [rax+2], r12b ; BLUE

  add rax, 3        ; dst_ptr += 3
  mov [rbp-8], rax

  jmp loop

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
  push rcx ; src_width [rbp-32]
  push r8  ; src_ptr   [rbp-40]
  ; =============================

  mov rax, [rbp-24] ; y
  mov rbx, [rbp-32] ; src_width
  mul rbx           ; y*src_width

  mov rbx, 3
  mul rbx           ; y*src_width*3
  mov rbx, rax

  mov rax, 3
  mov rcx, [rbp-16] ; x
  mul rcx           ; x*3
  mov rcx, rax

  add rbx, rcx      ; y*src_width*3 + x*3

  ; local variables
  ; ====================================================
  push rbx ; pixel_number [rbp-48] = y*src_width*3 + x*3
  ; ====================================================

  mov rbx, [rbp-40] ; rbx = src_ptr
  mov rcx, [rbp-48]
  add rbx, rcx      ; rbx = src_ptr + pixel_number

  mov rcx, [rbp-8]  ; rcx = pixel_buffer

  mov al, [rbx]     ; read BLUE
  mov [rcx], al     ; pixel_buffer[0] = BLUE

  mov al, [rbx+1]   ; read GREEN
  mov [rcx+1], al   ; pixel_buffer[1] = GREEN

  mov al, [rbx+2]   ; read RED
  mov [rcx+2], al   ; pixel_buffer[2] = RED

  mov rsp, rbp
  pop rbp
  ret

interpolate:
  ; arguments
  ; ============
  ; rdi = F_00
  ; rsi = F_10
  ; rdx = F_01
  ; rcx = F_11
  ; r8 = a
  ; r9 = b
  ; ============

  push rbp
  mov rbp, rsp

  ; local variables
  ; ======================
  push rdi ; F_00 [rbp-8]
  push rsi ; F_10 [rbp-16]
  push rdx ; F_01 [rbp-24]
  push rcx ; F_11 [rbp-32]
  push r8 ; a [rbp-40]
  push r9 ; b [rbp-48]
  push 0 ; F_a0 [rbp-56]
  push 0 ; F_a1 [rbp-64]
  push 0 ; F_ab [rbp-72]
  ; ======================

  ; computing F_a0
  ; =======================================
  mov rax, 1
  cvtsi2sd xmm0, rax
  subsd xmm0, [rbp-40]   ; 1-a
  cvtsi2sd xmm1, [rbp-8]
  mulsd xmm1, xmm0       ; xmm1 = (1-a)*F_00

  movsd xmm0, [rbp-40]   ; a
  cvtsi2sd xmm2, [rbp-16]
  mulsd xmm2, xmm0       ; xmm2 = a*F_10

  addsd xmm1, xmm2       ; xmm1 = (1-a)*F_00 + a*F_10
  movsd [rbp-56], xmm1   ; F_a0 = (1-a)*F_00 + a*F_10

  ; computing F_a1
  ; =======================================
  mov rax, 1
  cvtsi2sd xmm0, rax
  subsd xmm0, [rbp-40]   ; 1-a
  cvtsi2sd xmm1, [rbp-24]
  mulsd xmm1, xmm0       ; xmm1 = (1-a)*F_01

  movsd xmm0, [rbp-40]   ; a
  cvtsi2sd xmm2, [rbp-32]
  mulsd xmm2, xmm0       ; xmm2 = a*F_11

  addsd xmm1, xmm2       ; xmm1 = (1-a)*F_01 + a*F_11
  movsd [rbp-64], xmm1   ; F_a1 = (1-a)*F_01 + a*F_11

  ; computing F_ab
  ; =======================================
  movsd xmm0, [rbp-48]  ; b
  movsd xmm1, [rbp-56]
  mulsd xmm1, xmm0      ; xmm1 = b*F_a0

  mov rax, 1
  cvtsi2sd xmm0, rax
  subsd xmm0, [rbp-48]  ; 1-b
  movsd xmm2, [rbp-64]
  mulsd xmm2, xmm0      ; xmm2 = (1-b)*F_a1

  addsd xmm1, xmm2      ; xmm1 = b*F_a0 + (1-b)*F_a1
  movsd [rbp-72], xmm1  ; F_ab = b*F_a0 + (1-b)*F_a1

  movsd xmm0, [rbp-72]
  cvtsd2si rax, xmm0    ; return F_ab

  mov rsp, rbp
  pop rbp
  ret
