        .arch   armv8-a
        .data
        .text
        .align  2
        .global grey_filter_asm
        .type   grey_filter_asm, %function
grey_filter_asm:
//      x0 - old img
//      x1 - res img
//      x2 - size
//      x4 - end_ptr
//      x5 - p
//      x6 - res_ptr
//      w7 - res_img ptr
//      w8 - min_c
//      w9 - max_c
//      w10 - i
        mov     x5, x0
        mov     x6, x1
        add     x4, x0, x2
1:
        cmp     x5, x4
        beq     4f
        ldrb    w8, [x5]
        ldrb    w9, [x5]
        mov     x10, #1
2:
        cmp     x10, #3
        beq     3f
        ldrb    w11, [x5, x10]
        mov     w2, w8
        mov     w3, w11
        bl      min_
        mov     w8, w1
        mov     w2, w9
        mov     w3, w11
        bl      max_
        mov     w9, w1
        add     x10, x10, #1
        b       2b
3:
        add     w12, w8, w9
        mov     w13, #2
        sdiv    w12, w12, w13
        strb    w12, [x6]
        add     x5, x5, #3
        add     x6, x6, #1
        b       1b
4:
        mov     x0, #0
        ret
        .size   grey_filter_asm, .-grey_filter_asm
        .global min_
        .type   min_, %function
min_:
//      x0 - result code
//      x1 - result
//      x2 - 1st number
//      x3 - 2nd number
        cmp     x2, x3
        ble     1f
        b       2f
1:
        mov     x1, x2
        b       3f
2:
        mov     x1, x3
3:
        mov     x0, #0
        ret
        .size   min_, .-min_
        .global max_
        .type   max_, %function
max_:
//      x0 - result code
//      x1 - result
//      x2 - 1st number
//      x3 - 2nd number
        cmp     x2, x3
        bge     1f
        b       2f
1:
        mov     x1, x2
        b       3f
2:
        mov     x1, x3
3:
        mov     x0, #0
        ret
        .size   max_, .-max_
