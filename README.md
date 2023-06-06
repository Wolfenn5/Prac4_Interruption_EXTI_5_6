
# Practica  'Lab6' Configuracion de interrupcion externa


# Funcionamiento de la implementacion

En esta práctica se diseño e implemento un contador binario de 10 bits que a la salida muestran el valor de la cuenta en 10 ledes. De manera predeterminada, el contador aumentará su
cuenta cada segundo. Al oprimir un botón (PA4 en este caso), el contador cambiará
su modo y trabajará en modo descendente. Si el mismo botón vuelve a
presionarse, entonces el contador regresará al modo ascendente.
Al oprimir un segundo boton, el contador podrá aumentar su velocidad x2, x4 y x8. La velocidad regresará a x1 cuando
ésta esté establecida en x8 y el usuario oprima nuevamente el segundo botón.


# Documentación

-Funcionamiento del Proyecto: Encendido de 10 LED con un valor binario de 0 a 10 con 2 botones push button para incrementar y decrementar la cuenta con un solo boton, cambio de velocidad con un segundo boton multiplicada por 2, 4 y 8. Estando en velocidad x8 al volver al pulsar el boton de modo volvera a velocidad normal.

-Compilacion del software: En una distribucion de linux basada en ubuntu se procedio a instalar los siguientes paquetes con el comando "sudo apt install gcc-arm-none-eabi stlink-tools
libusb-1.0-0-dev" :


    gcc-arm-none-eabi. Este es el compilador cruzado que permite generar código máquina para microcontroladores.

    stlink-tools. Este paquete contiene las utilizadas que permiten grabar un microcontrolador STM32 mediante el dispositivo ST-Link V2.

    libusb-1.0-0-dev. Este paquete contiene los controladores que permiten detectar la conexión con el ST-Link V2.

Posteriormente se establecieron alias para no emplear comandos verbosos(utilizando visual studio) de la siguiente manera:

    cd $HOME. Esta instruccion cambia el directorio a HOME donde se localiza bash

    code .bashrc. Esta instruccion abre el bash para establecer los alias


Alias a establecer:

    alias arm-gcc=arm-none-eabi-gcc

    alias arm-as=arm-none-eabi-as

    alias arm-objdump=arm-none-eabi-objdump

    alias arm-objcopy=arm-none-eabi-objcopy



Una vez establecidos los alias se utilizo una plantilla makefile proporcionada por el profesor del curso. Con dicha plantilla podemos realizar la compilacion con un simple comando el cual es el siguiente:
    
    make


Posteriormente, para realizar la grabación en el µC, se ejecuta la instruccion:

    st-flash write ‘prog.bin’ 0x8000000. 

    La cual sirve para escribir el binario (prog.bin) al µC. Donde prog.bin es el nombre del archivo generado por la plantilla makefile

    Significado de banderas:
    -> "0x8000000" indica la dirección de inicio en la memoria del microcontrolador donde se desea escribir el archivo binario. La dirección de memoria 0x8000000 es donde se almacenan las instrucciones y datos iniciales del programa, que se ejecutaran en el µC después de un reinicio o encendido. Comunmente dicha direccion, se utiliza como la ubicación de inicio del programa principal o firmware.



# Detalles de Interrupciones externas (EXTI)

Como material de apoyo se utilizo el libro Embedded systems with ARM Cortex-M -microcontrollers in Assembly Language and C, Thrid Edition del Dr. Yifeng Zhu

Para fines de esta practica se utilizaron las interrupciones externas EXTI6 Y EXTI5, para ello hay que habilitarlas y saber en que registro estan de las funciones alternas de entrada y salida (AFIO - Advanced Function Input Output). Para el caso de las 5 y 6 se encuentran en el registro  (AFIO_EXTICR2_OFFSET) del archivo afio_map.inc
Donde AFIO_EXTICR2_OFFSET habilita las EXTI7 - EXTI4. 

AFIO_EXTICR1_OFFSET habilita EXTI3 - EXTI0
AFIO_EXTICR2_OFFSET habilita EXTI7 - EXTI4
AFIO_EXTICR3_OFFSET habilita EXTI11 - EXTI8
AFIO_EXTICR4_OFFSET habilita EXTI15 - EXTI12

Ademas hay que indicar que trabajamos con puertos A (para este caso)
Y eso se hace mandando los siguientes valores al "AFIOEXTICRx_OFFSET" que queremos utilizar

0000: PA (Puertos A)
0001: PB (Puertos B)
0010: PC (Puertos C)
0011: PD (Puertos D)
0100: PE (Puertos E)
0101: PF (Puertos F)
0110: PG (Puertos G)


Para establecer que seran los pines PA6 y PA5 hay que mandarle dichos valores al flanco de subida o bajada que quiera utilizarse, en este caso habra que mandarle ( 0110 0000) al flanco de subida y un 0 para el flanco de bajada del archivo exti_map.inc ejemplo:


ldr 	r0, =EXTI_BASE
mov		r1, #0 @ manda un 0 para indicar que no se va a habilitar el flanco de bajada
str 	r1, [r0, EXTI_FTST_OFFSET] @ flanco de bajada desactivado
ldr 	r1, =(0x3<<5) @ puertos PA5 y PA6 (0110 0000) del mapa GPIOA
str		r1, [r0, EXTI_RTST_OFFSET] @flanco de subida activo para PR5 y PR6
str 	r1, [r0, EXTI_IMR_OFFSET] @ solicitud de interrupcion no enmascarada para PR5 y PR6




Posteriormente hay que configurar el vector de interrupciones del ISER_Map (archivo PNG) para que trabaje con las interrupciones deseadas y no se activen otras que no definimos, para este caso que trabajamos con EXTI11 Y EXTI10, se localizan en EXTI15_10 la cual se localiza dentro de ISER1 y con ayuda del archivo nvic_reg_map ejemplo:

ldr 	r0, =NVIC_BASE
ldr 	r1, =(0x1<<23) @ manda un 1 al bit 23 para habilitar EXTI9_5 del mapa ISER0 
str		r1, [r0, NVIC_ISER1_OFFSET]




# Detalles de configuracion de reloj del sistema

Debido a que el reloj del sistema es de 8Mhz hay que configurarlo para que por cada milisegundo (ms) haga una interrupcion y eso hay que configurarlo con una constante de 7999 en el registro de carga del reloj. Asi mismo se utilizo la misma implementacion del libro de zhu mencionado anteriormente.

ldr r0 , =SYSTICK_BASE
mov r1, #0 @ 0 para descativar systick IRQ y el contador de reloj del sistema
str r1, [r0, #STK_CTRL_OFFSET]

ldr r2, =7999 @ Esta constante especifica el numero de ciclos de reloj entre 2 interrupciones. Indica que el reloj del sistema debe encender y apagar los leds cada segundo (dividir por 8000 (8 MHz / 8000 = 1000 Hz (1Khz))
str r2, [r0, #STK_LOAD_OFFSET] 

# Acerca de la plantilla Makefile

Cabe destacar que dentro de la plantilla makefile y para uso academico se utilizaron los siguientes archivos que tambien forman parte del archivo principal main.s

-> delay.s. Función que permite generar retrasos de n milisegundos.

-> systick_isr.s. Funcion que produce retrasos de 1 ms mediante la generación de una excepción producida por el reloj del sistema (SysTick).

-> exti_isr.s. Funcion que atiende las interrupciones generadas por los botones del sistema.


En el archivo main.s, es donde existe la función main. La cual contiene un apartado setup donde se configuran los periféricos del µC. Además, de que contiene un bucle loop donde se define el modo de operación del sistema.


Diagrama de configuracion del µC (blue pill stm32f103c8t6)
![Logo](https://i.ibb.co/KGr6Nwb/Diagrama-STM32-EXTI.png[/img][/url])    


        
