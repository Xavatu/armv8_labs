	.arch armv8-a
	.data
	.align 1
matrix:
    .byte -9, 9, 6
    .byte -1, 1, 2
    .byte -4, 4, -2
    .byte  0, 0, 0
    .byte -5, -5, -9
    .byte -3, 3, -5
    .byte -2, 2, 3
    .byte -7, 7, 7
    .byte -6, 6, 4
    .byte -8, 8, 11
    .byte -8, -10, 8
n:
	.byte 11
m:
	.byte 3
k:
    .byte 0
	.text
	.align 2
	.global _start
	.type _start, %function
_start:
	adr x0, matrix
	adr x1, n
	ldrb w1, [x1]   //num of strings
    adr x2, m
	ldrb w2, [x2]   //num of columns
    adr x5, k
    ldrb w5, [x5]   //column_mover counter
column_mover:
    cmp w5, w2      //k ? m
    mov x3, #1      //i
    mov x4, #2      //j
    blt gnome_sort  //k < m
    b end           //!(k < m)
gnome_sort:
    cmp w3, w1      //i ? n
    bge 0f          //!(i < n)
    mov x6, x0
    madd x9, x3, x2, x5
    add x6, x6, x9
    ldrb w8, [x6]   //a[i]
    sub x6, x6, x2
    ldrb w7, [x6]   //a[i-1]
    sxtb x7, w7
    sxtb x8, w8
    cmp x7, x8
.ifdef reverse
    blt             //a[i-1] < a[i]
.else
    bgt 1f          //a[i-1] > a[i]
.endif
    b   2f          //else
0:
    add w5, w5, #1
    b column_mover
1:
    mov x3, x4
    add w4, w4, #1
    b gnome_sort
2:
    strb w8, [x6]   //a[i] = a[i-1]
    add x6, x6, x2
    strb w7, [x6]   //a[i-1] = a[i]
    sub w3, w3, #1
    cbz w3, 3f
    b gnome_sort
3:
    mov x3, x4
    add w4, w4, #1
    b gnome_sort
end:
	mov x0, #0
	mov x8, #93
	svc #0
	.size	_start, .-_start
