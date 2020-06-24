ldm r1, 5
ldm r2, 10

nop
nop

swap r1, r2

call r1

.org 10

inc r4

nop

sub r4, r1, r5

jz r2

ret

inc r1

inc r4
