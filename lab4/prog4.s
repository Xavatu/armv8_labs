        .arch   armv8-a
        .data
errmes1:
        .string "error: expected 2 args, got %d\n"
errmes2:
        .string "error: incorrect file format\n"
errmes3:
        .string "error: expected n <= 20, got %d\n"
mode:
        .asciz  "r"
n_format:
        .asciz  "%u"
space:
        .string  " "
new_string:
        .string  "\n"
read_format:
        .string "%f"
write_format:
        .string "%.3f"
        .equ    progname, 32
        .equ    filename, 40
        .equ    fileptr,  48
        .equ    n,        56
        .equ    i,        64
        .equ    matrix1,  72
        .equ    matrix2,  1672
        .equ    tmp,      3272
        .equ    res,      4872
        .text
        .align  2
        .global main
        .type   main, %function
main:
        mov     x9, #6472
        sub     sp, sp, x9
        stp     x29, x30, [sp]
        mov     x29, sp
        cmp     w0, #2
        beq     open_file
//      error:  expected 2 args, got ...
        mov     x2, x0
        adr     x0, stderr
        ldr     x0, [x0]
        adr     x1, errmes1
        bl      fprintf
        mov     x0, #1
        b       exit
open_file:
        ldr     x0, [x1]
        str     x0, [x29, progname]
        ldr     x0, [x1, #8]
        str     x0, [x29, filename]
        adr     x1, mode
        bl      fopen
        cbnz    x0, save_file_ptr
//      error:  file open error
        ldr     x0, [x29, filename]
        bl      perror
        mov     x0, #1
        b       exit
save_file_ptr:
        str     x0, [x29, fileptr]
        b       get_n_from_file
get_n_from_file:
        ldr     x0, [x29, fileptr]
        adr     x1, n_format
        add     x2, x29, n
        bl      fscanf
        cmp     w0, #1
        beq     compare_n
//      error:  incorrect file format
        adr     x0, stderr
        ldr     x0, [x0]
        adr     x1, errmes2
        bl      fprintf
        mov     x0, #1
        b       close_file
compare_n:
        ldr     x3, [x29, n]
        cmp     x3, #20
        bls     work
        mov     x2, x3
        adr     x0, stderr
        ldr     x0, [x0]
        adr     x1, errmes3
        bl      fprintf
        mov     x0, #1
        b       close_file
work:
        mov     x1, res
        add     x1, x29, x1
        ldr     x4, [x29, n]
        bl      init_matrix
        mov     w7, wzr
1:
        strb    w7, [x29, i]
        cmp     w7, #4
        bge     4f
        ldr     x0, [x29, fileptr]
        adr     x1, read_format
        add     x2, x29, matrix1
        ldr     x3, [x29, n]
        bl      read_matrix
        cmp     w0, #0
        bne     error
        ldr     x0, [x29, fileptr]
        adr     x1, read_format
        add     x2, x29, matrix2
        ldr     x3, [x29, n]
        bl      read_matrix
        cmp     w0, #0
        bne     error
2:
        add     x1, x29, matrix1
        add     x2, x29, matrix2
        add     x3, x29, tmp
        ldr     x4, [x29, n]
        bl      mul_matrix
//        adr     x1, write_format
//        add     x2, x29, tmp
//        ldr     x3, [x29, n]
//        bl      print_matrix
        mov     x1, res
        add     x1, x29, x1
        add     x2, x29, tmp
        mov     x3, x1
        ldr     x4, [x29, n]
        bl      sum_matrix
//        mov     x2, res
//        adr     x1, write_format
//        add     x2, x29, x2
//        ldr     x3, [x29, n]
//        bl      print_matrix
3:
        ldrb    w7, [x29, i]
        add     w7, w7, #1
        b       1b
4:
        mov     x2, res
        adr     x1, write_format
        add     x2, x29, x2
        ldr     x3, [x29, n]
        bl      print_matrix
        b       close_file
error:
//      error:  got error from read_matrix
        adr     x0, stderr
        ldr     x0, [x0]
        adr     x1, errmes2
        bl      fprintf
        mov     w0, #3
        b       close_file
close_file:
        ldr     x0, [x29, fileptr]
        bl      fclose
        mov     x0, #0
exit:
        ldp     x29, x30, [sp]
        mov     x9, #6472
        add     sp, sp, x9
        ret
        .size   .main, .-main
        .equ    j, 72
        .global read_matrix
        .type   read_matrix, %function
read_matrix:
//      x0 - fileptr
//      x1 - format
//      x2 - matrix ptr
//      x3 - dimension
//      x8 - var i
//      x9 - var j
        sub     sp, sp, #80
        stp     x29, x30, [sp]
        mov     x29, sp
        str     x0, [x29, #32]  //fileptr
        str     x1, [x29, #40]  //format
        str     x2, [x29, #48]  //matrix ptr
        strb    w3, [x29, #56]  //dimension
        mov     w8, wzr //i
        strb    w8, [x29, i]
1:
        ldrb    w3, [x29, #56]
        ldrb    w8, [x29, i]
        cmp     w8, w3
        bge     6f  //i >= dimension
        mov     w9, wzr //j
        strb    w9, [x29, j]
2:
        ldrb    w3, [x29, #56]
        ldrb    w9, [x29, j]
        cmp     w9, w3
        bge     5f  //j >= dimension
3:
//      index = i * n + j
        ldrb    w8, [x29, i]
        sxtw    x8, w8
        sxtw    x9, w9
        sxtw    x3, w3
        mul     x11, x8, x3
        add     x11, x11, x9    //index
        ldr     x0, [x29, #32]
        ldr     x1, [x29, #40]
        ldr     x2, [x29, #48]
        add     x2, x2, x11, lsl #2
        bl      fscanf
        cmp     w0, #1
        bne     7f
4:
        ldrb    w9, [x29, j]
        add     w9, w9, #1
        strb    w9, [x29, j]
        b       2b
5:
        ldrb    w8, [x29, i]
        add     w8, w8, #1
        strb    w8, [x29, i]
        b       1b
6:
        mov     w0, wzr
        b       8f
7:
        mov     w0, #1
8:
        ldp     x29, x30, [sp]
        add     sp, sp, #80
        ret
        .size   read_matrix, .-read_matrix
        .global print_matrix
        .type   print_matrix, %function
print_matrix:
//      x0 - result code
//      x1 - format
//      x2 - matrix ptr
//      x3 - dimension
        sub     sp, sp, #56
        stp     x29, x30, [sp]
        mov     x29, sp
        str     x1, [x29, #16] //format
        str     x2, [x29, #24] //matrix ptr
        str     x3, [x29, #32] //dimension
        mov     w8, wzr //i
        strb    w8, [x29, #40]
1:
        ldrb    w3, [x29, #32]
        ldrb    w8, [x29, #40]
        cmp     w8, w3
        bge     6f
        mov     w9, wzr
        strb    w9, [x29, #48]
2:
        ldrb    w3, [x29, #32]
        ldrb    w9, [x29, #48]
        cmp     w9, w3
        bge     5f
        sub     w4, w3, w9
        cmp     w4, w3
        beq     3f
        adr     x0, space
        bl      printf
3:
//      index = i * n + j
        ldrb    w3, [x29, #32]
        ldrb    w8, [x29, #40]
        ldrb    w9, [x29, #48]
        sxtw    x3, w3
        sxtw    x8, w8
        sxtw    x9, w9
        mul     x11, x8, x3
        add     x11, x11, x9
        ldr     x1, [x29, #16]
        ldr     x2, [x29, #24]
        add     x2, x2, x11, lsl #2
        ldr     s0, [x2]
        fcvt    d0, s0
        mov     x0, x1
        bl      printf
4:
        ldrb    w9, [x29, #48]
        add     w9, w9, #1
        strb    w9, [x29, #48]
        b       2b
5:
        ldrb    w8, [x29, #40]
        add     w8, w8, #1
        strb    w8, [x29, #40]
        adr     x0, new_string
        bl      printf
        b       1b
6:
        mov     w0, wzr
        ldp     x29, x30, [sp]
        add     sp, sp, #56
        ret
        .size   print_matrix, .-print_matrix
        .global mul_matrix
        .type   mul_matrix, %function
mul_matrix:
//      x0 - result code
//      x1 - matrix1 ptr
//      x2 - matrix2 ptr
//      x3 - result ptr
//      x4 - dimension
//      x8 - i
//      x9 - j
//      x10 - k
//      x11 - index matrix1
//      x12 - index matrix2
//      x13 - index res matrix
        sub     sp, sp, #40
        stp     x29, x30, [sp]
        mov     x29, sp
        str     x1, [x29, #16]
        str     x2, [x29, #24]
        str     x3, [x29, #32]
        mov     w8, wzr
1:
        cmp     w8, w4
        bge     7f
        mov     w9, wzr
2:
        cmp     w9, w4
        bge     6f
//      index res matrix = i * n + j
        sxtw    x4, w4
        sxtw    x8, w8
        sxtw    x9, w9
        mul     x13, x8, x4
        add     x13, x13, x9
        ldr     x3, [x29, #32]
        add     x3, x3, x13, lsl #2
        fsub    s0, s0, s0
        str     s0, [x3]
        mov     w10, wzr
3:
        cmp     w10, w4
        bge     5f
//      index matrix1 = i * n + k
        sxtw    x10, w10
        mul     x11, x8, x4
        add     x11, x11, x10
//      index matrix2 = k * n + j
        mul     x12, x10, x4
        add     x12, x12, x9
//      matrix1[index1]
        ldr     x1, [x29, #16]
        add     x1, x1, x11, lsl #2
        ldr     s1, [x1]
//      matrix2[index2]
        ldr     x2, [x29, #24]
        add     x2, x2, x12, lsl #2
        ldr     s2, [x2]
//      result[index3]
        ldr     x3, [x29, #32]
        add     x3, x3, x13, lsl #2
        ldr     s3, [x3]
//      mul
        fmul    s4, s1, s2
        fadd    s3, s3, s4
        str     s3, [x3]
4:
        add     w10, w10, #1
        b       3b
5:
        add     w9, w9, #1
        b       2b
6:
        add     w8, w8, #1
        b       1b
7:
        mov     w0, wzr
        ldp     x29, x30, [sp]
        add     sp, sp, #40
        ret
        .size   mul_matrix, .-mul_matrix
        .global sum_matrix
        .type   sum_matrix, %function
sum_matrix:
//      x0 - result code
//      x1 - matrix1 ptr
//      x2 - matrix2 ptr
//      x3 - result ptr
//      x4 - dimension
//      x8 - i
//      x9 - j
//      x11 - index
        sub     sp, sp, #40
        stp     x29, x30, [sp]
        mov     x29, sp
        str     x1, [x29, #16]
        str     x2, [x29, #24]
        str     x3, [x29, #32]
        mov     w8, wzr
1:
        cmp     w8, w4
        bge     5f
        mov     w9, wzr
2:
        cmp     w9, w4
        bge     4f
        sxtw    x4, w4
        sxtw    x8, w8
        sxtw    x9, w9
        mul     x11, x8, x4
        add     x11, x11, x9
//      matrix1[index]
        ldr     x1, [x29, #16]
        add     x1, x1, x11, lsl #2
        ldr     s1, [x1]
//      matrix2[index]
        ldr     x2, [x29, #24]
        add     x2, x2, x11, lsl #2
        ldr     s2, [x2]
//      result[index]
        ldr     x3, [x29, #32]
        add     x3, x3, x11, lsl #2
        ldr     s3, [x3]
//      sum
        fadd    s3, s1, s2
        str     s3, [x3]
3:
        add     w9, w9, #1
        b       2b
4:
        add     w8, w8, #1
        b       1b
5:
        mov     w0, wzr
        ldp     x29, x30, [sp]
        add     sp, sp, #40
        ret
        .size   sum_matrix, .-sum_matrix
        .global init_matrix
        .type   init_matrix, %function
init_matrix:
//      x0 - result code
//      x1 - matrix ptr
//      x4 - dimension
//      x8 - i
//      x9 - j
//      x11 - index
        sub     sp, sp, #24
        stp     x29, x30, [sp]
        str     x1, [x29, #16]
        mov     w8, wzr
1:
        cmp     w8, w4
        bge     5f
        mov     w9, wzr
2:
        cmp     w9, w4
        bge     4f
        sxtw    x4, w4
        sxtw    x8, w8
        sxtw    x9, w9
        mul     x11, x8, x4
        add     x11, x11, x9
        ldr     x1, [x29, #16]
        add     x1, x1, x11, lsl #2
        fsub    s0, s0, s0
        str     s0, [x1]
3:
        add     w9, w9, #1
        b       2b
4:
        add     w8, w8, #1
        b       1b
5:
        mov     w0, wzr
        ldp     x29, x30, [sp]
        add     sp, sp, #24
        ret
        .size   init_matrix, .-init_matrix
