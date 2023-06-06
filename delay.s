	.section .text
 	.align  1
 	.syntax unified
 	.thumb
 	.global delay
delay:
        mov r10, r0 @ recibe el valor de checkspeed en ms
loop:
        cmp r10, #0 
        bne loop @ si es 0 termina
        bx lr

.size   delay, .-delay
