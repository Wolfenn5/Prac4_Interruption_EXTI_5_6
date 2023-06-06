	.thumb              @ Assembles using thumb mode
	.cpu cortex-m3      @ Generates Cortex-M3 instructions
	.syntax unified

	.include "gpio_map.inc"
	.include "rcc_map.inc"
	.include "systick_map.inc"
	.include "nvic_reg_map.inc"
	.include "afio_map.inc"
	.include "exti_map.inc"
	
	.extern delay
	.extern SysTick_Initialize


check_speed:
		@ Prologo
		push 	{r7} @ respalda r7
		sub 	sp, sp, #12 @ respalda un marco de 16 bytes
		add		r7, sp, #0 @ actualiza r7
@ if modo == 1
		cmp		r8, #1
		bne		L1
@ return 1000 ms (velocidad normal)
		mov		r0, #1000 

		@ Epilogo 
		adds	r7, r7, #12
		mov		sp, r7
		pop		{r7}
		bx 		lr
L1:	
@ if modo == 2
		cmp		r8, #2
		bne		L2
@ return 500 ms (velocidad x2)
		mov		r0, #500

		@ Epilogo
		adds	r7, r7, #12
		mov		sp, r7
		pop		{r7}
		bx 		lr
L2:	
@ if modo == 3
		cmp		r8, #3
		bne		L3
@ return 250 ms (velocidad x4)
		mov		r0, #250

		@ Epilogo
		adds	r7, r7, #12
		mov		sp, r7
		pop		{r7}
		bx 		lr
L3:	
@ if modo == 4
		cmp		r8, #4
		bne		L4
@ return 125 ms (velocidad x8)
		mov		r0, #125

		@ Epilogo
		adds	r7, r7, #12
		mov		sp, r7
		pop		{r7}
		bx 		lr
L4:	
@ if modo < 4 
@ modo = 1
		mov		r8, #1
@ return 1000 ms (velocidad normal)
		mov		r0, #1000
		@ Epilogo
		adds	r7, r7, #12
		mov		sp, r7
		pop		{r7}
		bx 		lr






	.section .text
 	.align  1
 	.syntax unified
 	.thumb
 	.global __main
__main:
		@Prologo 
		push 	{r7} @ respalda r7 y lr
		sub 	sp, sp, #8 @ respalda un marco de 16 bytes
		add		r7, sp, #0 @ actualiza r7

		


@ Configuracion de puertos de reloj
        @ Habilitacion de puertos A y B
        ldr     r1, =RCC_BASE
        mov     r2, 0xC @ carga 12 (1100) en r2 para habilitar reloj en puertos A (IOPA) y puertos B (IOPB)
        str     r2, [r1, RCC_APB2ENR_OFFSET] 

	

@ configuracion de pines de entrada y salida
        @ Configura los puertos PA7, PA4 - PA0 en modo reset y PA6, PA5 como entradas 2 botones push button
		ldr     r1, =GPIOA_BASE
        ldr     r2, =0x48844444 @ constante que establece el estado de pines
        str     r2, [r1, GPIOx_CRL_OFFSET]

		@ Configura los puertos PA15 - PA8 en modo reset
        ldr     r1, =GPIOA_BASE
        ldr     r2, =0x44444444 @ constante que establece el estado de pines 
        str     r2, [r1, GPIOx_CRH_OFFSET]

		@ Configura los puertos PB7 - PB5 como salidas push pull (3 LEDS) y PB4 - PB0 en modo reset
        ldr     r1, =GPIOB_BASE
        ldr     r2, =0x33344444 @ constante que establece el estado de pines 
        str     r2, [r1, GPIOx_CRL_OFFSET]

		@ Configura los puertos PB15 en reset y PB14 - PB8 como salidas push pull (7 LEDS)
        ldr     r1, =GPIOB_BASE
        ldr     r2, =0x43333333 @ constante que establece el estado de pines
        str     r2, [r1, GPIOx_CRH_OFFSET]




@Habilitacion de interrupciones
		ldr 	r0, =AFIO_BASE
		mov		r1, #0 @ trabaja con pines A 
		ldr 	r1, [r0, AFIO_EXTICR2_OFFSET] @ habilita EXTI7 - EXTI4


		@ Configuracion de puertos de interrupcion
		@ PA6 como incremento/decremento y PA5 como modo de velocidad
		ldr 	r0, =EXTI_BASE
		mov		r1, #0 @ manda un 0 para indicar que no se va a habilitar el flanco de bajada
		str 	r1, [r0, EXTI_FTST_OFFSET] @ flanco de bajada desactivado
		ldr 	r1, =(0x3<<5) @ puertos PA5 y PA6 (0110 0000) del mapa GPIOA
		str		r1, [r0, EXTI_RTST_OFFSET] @flanco de subida activo para PR11 y PR10
		str 	r1, [r0, EXTI_IMR_OFFSET] @ solicitud de interrupcion no enmascarada para PR11 y PR10

		@ Configuracion del vector de interrupciones
		ldr 	r0, =NVIC_BASE
		ldr 	r1, =(0x1<<23) @ manda un 1 al bit 23 para habilitar EXTI9_5 del mapa ISER0 
		str		r1, [r0, NVIC_ISER0_OFFSET]



@ Inicializacion de leds 
		ldr     r3, =GPIOB_BASE
		mov		r4, 0x0 @ establece el estado de los leds en 0 
		str		r4, [r3, GPIOx_ODR_OFFSET]

		bl 		SysTick_Initialize @ configuracion de reloj para interrupciones

		@ contador y retraso (delay en ms)
		mov		r6, 0x0 @ mueve un 0 a r6 (contador = 0)
		str		r6, [r7, #4] @ guarda el valor del contador dentro del marco
		mov		r6, #1000 @ mueve un 1000 a r6 (1000 ms)
		str 	r6, [r7, #8] @ guarda el valor del delay dentro del marco


		@ Establecer el modo de velocidad (PA0) y conteo (PA4)
		eor		r9,r9 @limpia r9
		eor		r8,r8 @limpia r8
		mov		r9, #1 @ modo en incremento PA4 (0 para decremento)
		mov		r8, #1 @ modo a check speed PA0 (modo 1 con velocidad de 1000ms)






loop:
		bl		check_speed
		str 	r0, [r7, #8] @ guarda el valor de check_speed dentro del marco

		cmp 	r9, #1 @ compara para saber si la bandera vale 1 o 0 (esta en modo ascendente o descendente)
		bne 	L5 @ si no es igual a 1 (tiene valor actual de 0) entonces decrementa
		@ Incremento
		ldr		r0, [r7, #4] @ trae el valor actual del contador
    	adds	r0, r0, #1 @ contador += 1
		str		r0, [r7, #4] @ guarda el nuevo valor del contador dentro del marco
		b 		L6
L5:
		@ Decremento 
		ldr		r0, [r7, #4] @ trae el valor actual del contador
    	subs	r0, r0, #1 @ contador -= 1
		str		r0, [r7, #4] @ guarda el nuevo valor del contador dentro del marco
L6:
		@ Encendido de leds con valor del contador incluido
    	ldr 	r3, =GPIOB_BASE
		ldr		r0, [r7, #4] @ trae el valor del contador actual desde el marco
		mov 	r1, r0 @ mueve el valor del contador a r1
		lsl 	r1, r1, #5 @ desplaza 5 unidades hacia la izquierda (PB5 bit5 leds)
    	str 	r1, [r3, GPIOx_ODR_OFFSET]
		ldr		r0, [r7, #8] @ trae el valor de check_speed y se lo manda a delay
		bl		delay
		b 		loop

		