.include "exti_map.inc"
.extern delay
.cpu cortex-m3      @ Generates Cortex-M3 instructions
.section .text
.align	1
.syntax unified
.thumb
.global EXTI9_5_Handler 

EXTI9_5_Handler:
    ldr     r0, =EXTI_BASE
    ldr     r1, [r0, EXTI_PR_OFFSET]
    ldr     r0, =0x20 @ encender el bit 5 para PA5
    cmp     r1, r0 @ EXTI10 = on
    beq     EXTI5_Handler
    ldr     r0, =EXTI_BASE
    ldr     r1, [r0, EXTI_PR_OFFSET]                    
    ldr     r0, =0x40 @ encender el bit 6 para PA6
    cmp     r1, r0 @ EXTI11 = on
    beq     EXTI6_Handler
    bx      lr

EXTI5_Handler:
    adds    r8, r8, #1 @ suma 1 al contador del modo de check_speed
    ldr     r0, =EXTI_BASE
    ldr     r1, [r0, EXTI_PR_OFFSET]
    orr     r1, r1, 0x20 @ limpia los bits y solo deja el bit de PR5
    str     r1, [r0, EXTI_PR_OFFSET]
    bx      lr


EXTI6_Handler:
    eor     r9, r9, #1 @ cambia entre 0 y 1 al modo (incremento/decremento)
    and     r9,r9, 0x1 @aplica una and para limpiar
    ldr     r0, =EXTI_BASE
    ldr     r1, [r0, EXTI_PR_OFFSET]
    orr     r1, r1, 0x40 @ limpia los bits y solo deja el bit de PR6
    str     r1, [r0, EXTI_PR_OFFSET]
    bx      lr


.size   EXTI9_5_Handler , .-EXTI9_5_Handler 
