.org 0
20
.org 2
40

.org 32

LDM r2, 5
ldm r1, 10
NOP


swap r1, r2
NOP
NOP

add r1, r2, r3
sub r1, r2, R4
and r1, r2, r5
or r1, r2, r6
shl r4, 1
shr r3, 3
iadd r5, r0, 4

inc r1
dec r2

not R4
NOP
NOP

out r4


.org 64
#ISR

ldm r7, 8001

pop r5

nop
nop
nop
nop
nop

RTI
