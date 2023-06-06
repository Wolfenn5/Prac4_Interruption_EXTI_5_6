.include "systick_map.inc"
.include "scb_map.inc"

.cpu cortex-m3     
.extern __main
.section .text
.align	1
.syntax unified
.thumb
.global SysTick_Initialize

@ Esto configura el reloj del sistema para que genere interrupciones a un cierto intervalo
SysTick_Initialize:
    ldr r0 , =SYSTICK_BASE
    mov r1, #0 @ 0 para descativar systick IRQ y el contador de reloj del sistema
    str r1, [r0, #STK_CTRL_OFFSET]

    ldr r2, =7999 @ Esta constante especifica el numero de ciclos de reloj entre 2 interrupciones. Indica que el reloj del sistema debe encender y apagar los leds cada segundo (dividir por 8000 (8 MHz / 8000 = 1000 Hz (1Khz))
    str r2, [r0, #STK_LOAD_OFFSET] 

    mov r1, #0 @ limpia el valor actual del registro de systick
    str r1, [r0, #STK_VAL_OFFSET]

    @ Configurar la prioridad de interrupcion para systick
    ldr r2 , =SCB_BASE
    add r2 , r2 , #SCB_SHPR3_OFFSET
    mov r3, #0x20
    strb r3, [r2, #11]

    @ Configura systick_ctrl para habilitar el temporizador de sytcik y sus interrupciones
    ldr r1, [ r0 , #STK_CTRL_OFFSET]
    orr r1, r1, #7
    str r1, [r0, #STK_CTRL_OFFSET]
    bx lr


.global SysTick_Handler
SysTick_Handler:
    @ Decrementa el tiempo de retraso (delay.s) en uno cuando una interrupcion se genera
    @ el vector de interrupciones automaticamente apila los registros r0, r1, r2, r3, r12, lr, psr y pc
    sub     r10, r10, #1
    bx      lr

.size   SysTick_Handler, .-SysTick_Handler

