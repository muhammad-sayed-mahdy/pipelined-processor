ldm r0, 0
ldm r1, 1
ldm r2, 2
ldm r3, 3

ldm r5, 3

ldm r7, E
ldm r6, 16

add r2, r3, r2
nop
nop

dec r5
nop
jz r6
inc r1
jmp r7

ldm r7, 20

nop
nop
nop
nop

call r7

add r1, r2, r3
nop
nop

inc r4
inc r6
inc r5
ret
