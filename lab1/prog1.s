	.arch   armv8-a
//	res=(a*e-b*c+d/b)/((b+c)*a)
//  signed type
	.data
    .align  3

res:.skip   8
a:  .long   2147483647
//a:  .long 2
d:  .long  -2147483647
//d:  .long 5
e:  .long   2147483647
//e:  .long 3
c:  .short  -32767
//c:  .short 4
b:  .byte   126
//b:  .byte 6

    .align  2
	.text
	.global _start
	.type	_start, %function

_start:
	adr	    x0, a
	ldr 	w1, [x0]
	adr	    x0, b
	ldrsb	w2, [x0]
	adr	    x0, c
	ldrsh	w3, [x0]
	adr	    x0, d
	ldr 	w4, [x0]
	adr	    x0, e
	ldr 	w5, [x0]

    cbz     w2, _bad_exit

    //w7 = (b+c)*a
    adds    w7, w2, w3
    smull   x7, w7, w1

    cbz     x7, _bad_exit

    sdiv    w6, w4, w2
    mul     w8, w2, w3
    add     w6, w8, w6
    smull   x8, w1, w5
    subs    x6, x8, x6
    sdiv    x7, x6, x7

    adr	    x0, res
    str	    x8, [x0]
    mov	    x0, #0
    b       _exit

_bad_exit:
    mov     x0, #1
_exit:
    mov	    x8, #93
    svc     #0

    .size	_start, .-_start
