@;=                                                               		=
@;== func_sprites.s: rutinas de manipular sprites para plataforma NDS ===
@;=                                                         			=
@;=== Autor: santiago.romani@urv.cat	(2017-08-10)		 		  ===
@;=                                                         	      	=


@;-- .bss. data section ---
.bss
		.align 1
	oam_data:	.space 128 * 8		@; memoria de trabajo para 128 sprites


@;-- .text. Program code ---
.text	
		.align 2
		.arm


@;SPR_actualizarSprites(u16* base, int limite);
@;Rutina para copiar la información de los sprites almacenada en la variable
@;global 'oam_data' sobre los registros de E/S correspondientes, según la
@;base OAM del procesador gráfico y los límites establecidos
@;Parámetros:
@;	base (R0):	0700 0000 para procesador gráfico principal
@;				0700 0400 para procesador gráfico secundario
@;	lim_spr (R1):	valor máximo del índice de los sprites
@;	act_grp (R2):	bits de activación de los grupos de transformación
@;					a copiar
@;Código:
	.global SPR_actualizarSprites
SPR_actualizarSprites:
		push {r1-r6, lr}
		
		ldr r4, =oam_data		@; R4 = dirección inicial de datos oam
		cmp r1, #0
		beq .LaS_copygrp		@; saltar a copiar grupos si límite sprites = 0
		cmp r1, #128
		movhi r1, #128			@; limitar valor máximo a 128
		
		mov r1, r1, lsl #3		@; R1 = límite índice * 8 (= límite posiciones)
		mov r5, #0				@; R5 = índice de posiciones
	.LaS_buclespr:
		ldr r3, [r4, r5]		@; cargar valor de atributos 0 y 1
		str r3, [r0, r5]		@; guarda el valor en los registros de E/S
		add r5, #4
		ldrh r3, [r4, r5]		@; cargar valor de atributo 2
		strh r3, [r0, r5]		@; guarda el valor en los registros de E/S
		add r5, #4
		cmp r5, r1				@; mientras índice < límite (*8)
		blo .LaS_buclespr
		
	.LaS_copygrp:
		cmp r2, #0
		beq .LaS_finactspr		@; salir de rutina si bits activación grupos = 0
		mov r5, #0				@; R5 = índice de grupos
	.LaS_buclegrp:
		tst r2, #1				@; testear bit de menos peso
		beq .LaS_nogrp			@; evitar copiar grupo
		mov r6, r5, lsl #5		@; R6 = base del grupo (índice * 32)
		add r6, #6				@; desplazamiento a PA
		mov r1, #0				@; R1 = contador bucle parámetros del grupo
	.LaS_bucparam:
		ldrh r3, [r4, r6]
		strh r3, [r0, r6]
		add r6, #8				@; desplazamiento a siguiente parámetro
		add r1, #1
		cmp r1, #4
		blo .LaS_bucparam
	.LaS_nogrp:
		mov r2, r2, lsr #1		@; desplazar máscara de bits de activación (1 bit derecha)
		add r5, #1
		cmp r5, #32
		blo .LaS_buclegrp
		
	.LaS_finactspr:
		pop {r1-r6, pc}



@;SPR_crearSprite(int indice, int forma, int tam, int baldosa);
@;Rutina para configurar el sprite indicado por parámetro
@;Parámetros:
@;	indice (R0):	índice del sprite a crear
@;	forma (R1):		0-> cuadrada, 1-> horizontal, 2-> vertical
@;	tam (R2):	forma cuadrada		0-> 8x8, 1-> 16x16, 2-> 32x32, 3-> 64x64
@;				forma horizontal	0-> 8x16, 1-> 8x32, 2-> 16x32, 3-> 32x64
@;				forma vertical		0-> 16x8, 1-> 32x8, 2-> 32x16, 3-> 64x32
@;	baldosa (R3):	índice de baldosa de 8x8 píxeles (256 colores)
@;Código:
	.global SPR_crearSprite
SPR_crearSprite:
		push {r4-r5, lr}
		
		and r0, #127			@; filtrar índice de sprite
		and r1, #3				@; filtrar forma
		and r2, #3				@; filtrar tamaño
		mov r3, r3, lsl #23		@; filtrar índice de baldosa, borrando 
		mov r3, r3, lsr #23		@; los 23 bits de más peso: únicos bits
								@; activos posibles 8..0 (9 bits bajos)
		ldr r4, =oam_data		@; R4 = direccion inicial de datos oam
		add r4, r0, lsl #3		@; sumar índice de sprite * 8
		
		ldrh r5, [r4]			@; cargar valor de atributo 0
		orr r5, #0x2000			@; activar bit 13 (256 colores)
		bic r5, #0xC000			@; borrar bits 15..14 (bits de forma)
		orr r5, r1, lsl #14		@; activar bits forma, desplazado a bits 15..14
		strh r5, [r4]			@; guarda el nuevo valor del atributo 0
		
		ldrh r5, [r4, #2]		@; cargar valor de atributo 1
		bic r5, #0xC000			@; borrar bits 15..14 (bits de tamaño)
		orr r5, r2, lsl #14		@; activar bits tamaño, desplazado a bits 15..14
		strh r5, [r4, #2]		@; guarda el nuevo valor del atributo 1
		
		ldrh r5, [r4, #4]		@; cargar valor de atributo 2
		bic r5, #0x00FF			@; borrar bits 7..0
		bic r5, #0x0300			@; borrar bits 9..8
		orr r5, r3, lsl #1		@; activar bits índice baldosa (desplazado un
								@; un bit a la izquierda por ser 256 colores)
		strh r5, [r4, #4]		@; guarda el nuevo valor del atributo 2
		
		pop {r4-r5, pc}



@;SPR_mostrarSprite(int indice);
@;Rutina para mostrar el sprite indicado por parámetro
@;Restricciones: el sprite no tendrá la funcionalidad de rotación/escalado
@;	activada; si fuese necesario aplicar dicha transformación, será necesario
@;  volver a llamar a la rutina rutina SPR_activarRotacionEscalado() para
@;  recuperar esta estado.
@;Parámetros:
@;	indice (R0):	índice del sprite a mostrar
@;Código:
	.global SPR_mostrarSprite
SPR_mostrarSprite:
		push {r1-r3, lr}
		
		and r0, #127			@; filtrar índice de sprite (0..127)
		ldr r1, =oam_data		@; R1 = dirección inicial de datos oam
		mov r2, r0, lsl #3		@; R2 = índice sprite * 8
		ldrh r3, [r1, r2]		@; cargar valor de atributo 0
		bic r3, #0x0300			@; desactivar bits 8 y 9 para mostrar sprite
		strh r3, [r1, r2]		@; guarda el nuevo valor del atributo
		
		pop {r1-r3, pc}


@;SPR_ocultarSprite(int indice);
@;Rutina para ocultar el sprite indicado por parámetro
@;Restricciones: el sprite perderá la activación de rotación/escalado, si
@;	la tuviese activa; ver rutina SPR_mostrarSprite() para más detalles.
@;Parámetros:
@;	indice (R0):	índice del sprite a ocultar
@;Código:
	.global SPR_ocultarSprite
SPR_ocultarSprite:
		push {r1-r3, lr}
		
		and r0, #127			@; filtrar índice de sprite
		ldr r1, =oam_data		@; R1 = direccion inicial de datos oam
		mov r2, r0, lsl #3		@; R2 = índice sprite * 8
		ldrh r3, [r1, r2]		@; cargar valor de atributo 0
		bic r3, #0x0100			@; desactivar bit 8 (no rotación/escalado)
		orr r3, #0x0200			@; activar bit 9 para ocultar sprite
		strh r3, [r1, r2]		@; guarda el nuevo valor del atributo
		
		pop {r1-r3, pc}


@;SPR_ocultarSprites(int límite);
@;Rutina para ocultar todos los sprites hasta el límite indicado
@;Parámetros:
@;	límite (R0):	valor máximo del índice de los sprites 
@;Código:
	.global SPR_ocultarSprites
SPR_ocultarSprites:
		push {r0-r1, lr}
		
		cmp r0, #0
		beq .LbS_fibucle		@; salir de rutina si valor máximo = 0
		cmp r0, #128
		bls .LbS_cont
		mov r0, #128			@; limitar valor máximo a 128
	.LbS_cont:
		mov r1, r0				@; R1 guardará el límite
		mov r0, #0				@; R0 = índice de sprite
	.LbSbucle:					@; por cada índice,
		bl SPR_ocultarSprite	@; llamar a la rutina que efectúa la ocultación
		add r0, #1
		cmp r0, r1
		blo .LbSbucle			@; repetir hasta el último índice
		
	.LbS_fibucle:
		pop {r0-r1, pc}



@;SPR_moverSprite(int indice, int px, int py);
@;Rutina para mover el extremo superior-izquierdo
@;hasta la posición (px, py) indicada por parámetro
@;Parámetros:
@;	indice (R0):	índice del sprite a mover
@;	px (R1):		nueva coordenada x del sprite
@;	py (R2):		nueva coordenada y del sprite
@;Código:
	.global SPR_moverSprite
SPR_moverSprite:
		push {r4-r5, lr}
		
		and r0, #127			@; filtrar índice de sprite
		mov r1, r1, lsl #23		@; filtrar coordenada X, dejando pasar
		mov r1, r1, lsr #23		@; solo los 9 bits bajos (0..511)
		and r2, #0xFF			@; filtrar coordenada Y (0..255)
		ldr r4, =oam_data		@; R4 = direccion inicial de datos oam
		add r4, r0, lsl #3		@; sumar índice de sprite * 8
		
		ldrh r5, [r4]			@; cargar valor de atributo 0
		bic r5, #0x00FF			@; borrar bits 7..0
		orr r5, r2				@; activar bits py
		strh r5, [r4]			@; guarda el nuevo valor del atributo 0
		
		ldrh r5, [r4, #2]		@; cargar valor de atributo 1
		bic r5, #0x00FF			@; borrar bits 7..0
		bic r5, #0x0100			@; borrar bit 8
		orr r5, r1				@; activar bits px
		strh r5, [r4, #2]		@; guarda el nuevo valor del atributo 1
		
		pop {r4-r5, pc}


@;SPR_fijarBaldosa(int indice, int id_baldosa);
@;Rutina para fijar el índice de la primera baldosa del sprite, con el
@;fin de mostrar la animación de los objetos
@;Parámetros:
@;	indice (R0):	índice del sprite a modificar sus baldosas
@;	id_baldosa (R1):	índice de la primera baldosa (0..511)
@;Código:
	.global SPR_fijarBaldosa
SPR_fijarBaldosa:
		push {r2-r3, lr}
		
		and r0, #127			@; filtrar índice de sprite (0..127)
		mov r1, r1, lsl #23		@; filtrar índice de baldosa, borrando 
		mov r1, r1, lsr #23		@; los 23 bits de más peso: únicos bits
								@; activos posibles 8..0 (9 bits bajos)
		ldr r2, =oam_data		@; R2 = direccion inicial de datos oam
		add r2, r0, lsl #3		@; sumar índice de sprite * 8
		ldrh r3, [r2, #4]		@; cargar valor de atributo 2
		bic r3, #0x00FF			@; borrar bits 7..0
		bic r3, #0x0300			@; borrar bits 9..8
		orr r3, r1, lsl #1		@; activar bits índice baldosa (desplazado un
								@; un bit a la izquierda por ser 256 colores)
		strh r3, [r2, #4]		@; guarda el nuevo valor del atributo 2
		
		pop {r2-r3, pc}



@;SPR_fijarPrioridad(int indice, int prioridad);
@;Rutina para fijar la prioridad del sprite respecto a los fondos gráficos
@;Parámetros:
@;	indice (R0):	índice del sprite a modificar su prioridad
@;	prioridad (R1):	prioridad relativa (0..3, 0 -> màxima)
@;Código:
	.global SPR_fijarPrioridad
SPR_fijarPrioridad:
		push {r2-r3, lr}
		
		and r0, #127			@; filtrar índice de sprite (0..127)
		and r1, #3				@; filtrar prioridad (0..3)
		ldr r2, =oam_data		@; R2 = direccion inicial de datos oam
		add r2, r0, lsl #3		@; sumar índice de sprite * 8
		ldrh r3, [r2, #4]		@; cargar valor de atributo 2
		bic r3, #0x0C00			@; borrar bits 11..10
		orr r3, r1, lsl #10		@; añadir prioridad, desplazada a bits 11..10
		strh r3, [r2, #4]		@; guarda el nuevo valor del atributo
		
		pop {r2-r3, pc}



@;SPR_activarRotacionEscalado(int indice, int grupo, int doblado);
@;Rutina para asignar un grupo de rotación/escalado el sprite indicado
@;Parámetros:
@;	indice (R0):	índice del sprite a fijar
@;	grupo (R1):		índice del grupo (0..31)
@;	doblado (R2):	si diferente de cero, doblará el tamaño del sprite para
@;					permitir rotaciones sin cortes
@;Código:
	.global SPR_activarRotacionEscalado
SPR_activarRotacionEscalado:
		push {r4-r5, lr}
		
		and r0, #127			@; filtrar índice de sprite
		and r1, #31				@; filtrar índice de grupo (0..31)
		ldr r4, =oam_data		@; R4 = direccion inicial de datos oam
		add r4, r0, lsl #3		@; sumar índice de sprite * 8
		
		ldrh r5, [r4, #2]		@; cargar valor de atributo 1
		bic r5, #0x3E00			@; borrar bits 13..9
		orr r5, r1, lsl #9		@; fijar grupo, desplazado a bits 13..9
		strh r5, [r4, #2]		@; guarda el nuevo valor del atributo 1
		
		ldrh r5, [r4]			@; cargar valor de atributo 0
		orr r5, #0x0100			@; activar bit 8 (rotación/escalado activo)
		cmp r2, #0
		bne .LaR_doblado
		bic r5, #0x0200			@; desactivar bit 9 (tamaño normal)
		beq .LaR_cont
	.LaR_doblado:
		orr r5, #0x0200			@; activar bit 9 (tamaño doblado)
	.LaR_cont:
		strh r5, [r4]			@; guarda el nuevo valor del atributo 0
		
		pop {r4-r5, pc}


@;SPR_desactivarRotacionEscalado(int indice);
@;Rutina para desactivar la rotación/escalado del sprite indicado
@;Restricciones: el sprite quedará visible, porque se supone que lo era
@;  cuando se estaba aplicando una transformación de rotación/escalado;
@;	en caso contrario, habrá que llamar a SPR_ocultarSprite() después de
@;	llamar a esta rutina.
@;Parámetros:
@;	indice (R0):	índice del sprite a fijar
@;Código:
	.global SPR_desactivarRotacionEscalado
SPR_desactivarRotacionEscalado:
		push {r4-r5, lr}
		
		and r0, #127			@; filtrar índice de sprite
		ldr r4, =oam_data		@; R4 = direccion inicial de datos oam
		add r4, r0, lsl #3		@; sumar índice de sprite * 8
		ldrh r5, [r4]			@; cargar valor de atributo 0
		bic r5, #0x0300			@; desactivar bit 8 (rotación/escalado)
								@; desactivar bit 9 (sprite visible)
		strh r5, [r4]			@; guarda el nuevo valor del atributo 0
		
		pop {r4-r5, pc}


@;SPR_fijarRotacionEscalado(int igrp, int pb_pa, int pd_pc);
@;Rutina para fijar los valores de la matriz de transformacion
@; 		(PA PB)
@; 		(PC PD)
@;	de rotación/escalado indicado en el parámetro igrp;
@;	si se quiere realizar un escalado (sx,sy), hay que pasar los
@;	valores en PA y PD, respectivamente, dejando PB y PC a 0:
@;		(sx  0)
@;		(0  sy)
@;	si se quiere realizar una rotación de un cierto ángulo (a),
@;	hay que pasar la siguiente matriz:
@;		( cos(a) sin(a))
@;		(-sin(a) cos(a))
@;	si se quiere combinar una rotación (a) con un escalado (sx, sy),
@;	se pueden combinar las matrices de la siguiente forma:
@;		( sx*cos(a)  sy*sin(a))
@;		(-sx*sin(a)  sy*cos(a))
@;	Todos los parámetros PA, PB, PC, PD deben proporcionarse en
@;	formato de números racionales de coma fija 0.8.8 (8 bits altos
@;	para la parte entera y 8 bits bajos para la parte fraccionaria)
@;Parámetros:
@;	igrp (R0):		índice del grupo de rotación-escalado (0..31)
@;	pb_pa (R1):		parámetros PB (16 bits altos) | PA (16 bits bajos)
@;	pd_pc (R2):		parámetros PD (16 bits altos) | PC (16 bits bajos)
@;Código:
	.global SPR_fijarRotacionEscalado
SPR_fijarRotacionEscalado:
		push {r4-r5, lr}
		
		and r0, #31				@; filtrar índice de grupo (0..31)
		ldr r4, =oam_data		@; R4 = direccion inicial de datos oam
		add r4, r0, lsl #5		@; sumar índice de grupo * 32
		mov r5, r1, lsl #16
		mov r5, r5, lsr #16		@; R5 = 16 bits bajos de R1 (PA)
		strh r5, [r4, #6]		@; guardar PA
		mov r5, r1, lsr #16		@; R5 = 16 bits altos de R1 (PB)
		strh r5, [r4, #14]		@; guardar PB
		mov r5, r2, lsl #16
		mov r5, r5, lsr #16		@; R5 = 16 bits bajos de R2 (PC)
		strh r5, [r4, #22]		@; guardar PC
		mov r5, r2, lsr #16		@; R5 = 16 bits altos de R2 (PD)
		strh r5, [r4, #30]		@; guardar PD
		
		pop {r4-r5, pc}




.end
