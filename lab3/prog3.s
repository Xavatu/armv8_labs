    .arch armv8-a
//  Remove symbols in even positions
//  From the keyboard to the specified file
    .data
errmes1:
    .string	"Usage: "
    .equ	errlen1, .-errmes1
errmes2:
    .ascii	" filename\n"
    .equ    errlen2, .-errmes2
existmes:
    .ascii  "Rewrite? (y, n)\n"
    .equ    existlen, .-existmes
filename:
    .asciz  "FILENAME"
fd:
    .skip   8
ans:
    .skip   2
    .text
    .align  2
//  Filename handling
    .global _start
    .type	_start, %function
_start:
    ldr     x0, [sp]
    mov     x1, #8
    mul     x0, x0, x1
    add     x0, x0, #8
    add     x0, sp, x0
    adr     x8, filename
    mov     x9, x0
get_filename_env:
    mov     x0, x9
    add     x0, x0, #8
    mov     x9, x0
    ldr     x1, [x0]
    cmp     x1, #0
    beq     7f
    mov     x2, x8
    bl      string_cmp
    cmp     x0, #1
    bne     get_filename_env
    mov     x2, #0
0:
//  Count x2 - len of progname
    ldrb    w3, [x1, x2]
    cbz     w3, 2f
    add     x2, x2, #1
    b       0b
1:
    mov	x8, #64
    svc	#0
    mov	x0, #2
    adr	x1, errmes2
    mov	x2, errlen2
    mov	x8, #64
    svc	#0
    mov	x0, #1
    b   4f
2:
//  Open file
    mov x0, x1
    mov x20, x0
    mov x1, x0 //Adress of filename
    mov x0, #-100
    mov x2, #0xc1
    mov x3, #0644
//  mov x3, #0 //Check "Permission denied"
    mov x8, #56
    svc #0
    cmp x0, #-17 //File exists
    beq 5f
    cmp x0, #0
    ble 7f
    adr x1, fd
    str x0, [x1]
    bl work
    cbnz x0, 7f //If an error is returned
3:
//  Close file
    str x0, [sp, #-16]!
    mov x21, x0
    mov x0, x20
    mov x8, #57
//  ldr x0, [sp], #16
    svc #0
    mov x0, x21
4:
//  Exit
    mov x8, #93
    svc #0
5:
//  File exist
    bl printerror
    mov x0, #2
    adr x1, existmes
    mov x2, existlen
    mov x8, #64
    svc #0
    mov x0, #0
    adr x1, ans
    mov x2, #3
    mov x8, #63
    svc #0
    cmp x0, #2
    bne 6f //Bad input
    adr x1, ans
    ldrb w0, [x1]
    cmp w0, 'y'
    bne 6f //Not rewrite
    mov x1, x20
    mov x0, #-100
    mov x2, 0x201 //0x2 - clean file
    mov x8, #56
    svc #0
    cmp x0, #0
    ble 7f
    adr x1, fd
    str x0, [x1]
    bl work
    cbnz x0, 7f //If an error is returned
    b 3b
6:
    ldr x0, [sp], #16
    mov x0, #1
    b 4b
7:
    bl printerror
    mov x0, #1
    b 3b
    .size	_start, .-_start
.data
str:
    .skip 16
newstr:
    .skip 16
prompt:
    .ascii  "Enter string: "
    .equ    len, .-prompt
newline:
    .ascii  "\n"
input_len:
    .quad   0
    .text
    .align  2
    .type   work, %function
    .text
work:
    //Enter string
    mov x0, #1
    adr x1, prompt
    mov x2, len
    mov x8, #64
    svc #0

    mov x5, #1
    mov x14, #1 //first word
    mov x15, #1 //word
    mov x16, #1 //word
0:
    //Input
    mov x0, #0
    adr x1, str
    mov x2, #15
    mov x8, #63
    svc #0

    //Conditions
    cmp x0, #0
    beq 10f
    blt 9f

    adr x1, str
    add x2, x0, x1
    ldrb w3, [x2, #-1]
    cmp w3, '\n'
    bne 1f
    str wzr, [x2, #-1]
1:
    //x5  - {0 - even, 1 - odd}
    //x14 - word {0 - not first; 1 - first}
    //x15 - prev state {0 - space, 1 - word}
    //x16 - cur state
    //x17 - istr
    //x18 - inewstr
    //x19 - newstr

    eor x5, x5, #1
    mov x17, #0 //istr
    mov x18, #0 //inewstr
    adr x19, newstr
    strb wzr, [x19]
2:
    cmp x17, x0 //end of read string
    beq 5f
    ldrb w3, [x1, x17]
    add x17, x17, #1

    cmp w3, ' '
    beq 4f

    cmp w3, '\t'
    beq 4f

    cbz w3, 5f  //end of string

    //symbol

    eor x5, x5, #1
    cmp x5, #0
    beq 2b

    mov x15, x16
    mov x16, #1

    add x15, x15, x14   //prev state = 0 (space) + x14 = 0 (not first word)
    cmp x15, #0
    bne 3f  //don't put a space

    //put a space
    mov x4, ' '
    strb w4, [x19, x18]
    add x18, x18, #1

    b 3f
3:
    //put a symbol
    strb w3, [x19, x18]
    add x18, x18, #1

    mov x14, #0
    b 2b
4:
    mov x5, #0
    mov x15, x16    //prev state = cur state
    mov x16, #0     //cur state = space
    b 2b
5:
    strb w3, [x19, x18]
    cmp w3, wzr
    eor x5, x5, #1

    //output to file
    adr x0, fd
    ldr x0, [x0]
    mov x1, x19
    mov x2, x18
    mov x8, #64
    svc #0

    bne 0b      //cur string

    adr x0, fd
    ldr x0, [x0]
    adr x1, newline
    mov x2, #1
    mov x8, #64
    svc #0

    b work      //new string
9:
    //if num of symbols < 0
    mov x0, #-1
10:
    //if CTRL+D
    ret
    .size   work, .-work
.data
perdenied:
    .string "Permission denied\n"
    .equ    perlen, .-perdenied
exist:
    .string "File exists\n"
    .equ    existlen, .-exist
unknown:
    .string "Unknown error\n"
    .equ    ulen, .-unknown
    .text
    .align  2
    .type   printerror, %function
printerror:
    cmp x0, #-13
    bne 0f
    adr x1, perdenied
    mov x2, perlen
    b 2f
0:
    cmp x0, #-17
    bne 1f
    adr x1, exist
    mov x2, existlen
    b 2f
1:
    adr x1, unknown
    mov x2, ulen
2:
    mov x0, #2
    mov x8, #64
    svc #0
    ret
    .size printerror, .-printerror
    .global string_cmp
    .type   string_cmp, %function
string_cmp:
    //x1 - string 1
    //x2 - string 2
    stp x29, x30, [sp, #-16]!
    mov x0, #1
    mov x11, #0
1:
    ldrb w3, [x1]
    ldrb w4, [x2, x11]
    add x1, x1, #1
    add x11, x11, #1
    cmp  w3, wzr
    beq 3f
    cmp w4, wzr
    beq 3f
    cmp w3, w4
    beq 1b
    mov x0, #0
3:
    ldp x29, x30, [sp], #16
    ret
    .size   string_cmp, .-string_cmp
