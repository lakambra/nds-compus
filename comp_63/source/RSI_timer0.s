@;=                                                          	     	=
@;=== RSI_timer0.s: rutinas para mover los elementos (sprites)		  ===
@;=                                                           	    	=
@;=== Programador tarea 2E: joel.lacambra@estudiants.urv.cat				  ===
@;=== Programador tarea 2G: genis.martinez@estudiants.urv.cat				  ===
@;=== Programador tarea 2H: zzz.zzz@estudiants.urv.cat				  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables globales inicializadas ---
.data
		.align 2
		.global update_spr
	update_spr:	.hword	0			@;1 -> actualizar sprites
		.global timer0_on
	timer0_on:	.hword	0 			@;1 -> timer0 en marcha, 0 -> apagado
	divFreq0: .hword	-5720		@;divisor de frecuencia inicial para timer 0



@;-- .bss. variables globales no inicializadas ---
.bss
		.align 2
	divF0: .space	2				@;divisor de frecuencia actual


@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm

@;TAREAS 2Ea,2Ga,2Ha;
@;rsi_vblank(void); Rutina de Servicio de Interrupciones del retroceso vertical;
@;Tareas 2E,2F: actualiza la posición y forma de todos los sprites
@;Tarea 2G: actualiza las metabaldosas de todas las gelatinas
@;Tarea 2H: actualiza el desplazamiento del fondo 3
	.global rsi_vblank
rsi_vblank:
		push {r0-r6, lr}
		
@;Tareas 2Ea
		ldr r2, =update_spr			@; direcció de update_spr en r2
		ldrh r3, [r2]				@; valor de update_spr en r2
		cmp r3, #1					@; comparem el update_spr amb 1
		
		bne .LnoChange				@; si es diferent de 1, no hi ha canvis
		mov r0, #0x07000000			@; pel processador gràfic principal (oam)
		mov r1, #128				@; index maxim de sprites
		bl SPR_actualizarSprites	@; ja que update_spr == 1, actualitzem
		
		mov r0, #0					@; movem a r0 el valor 0
		strh r0, [r2]				@; després d'actualitzar desactivem update_spr
		
		.LnoChange:

@;Tarea 2Ga
		ldr r4, =update_gel
		ldrb r2, [r4]					@; valor de udate_gel
		cmp r2, #0
		beq .Lfi						@; si es igual a 0, finalitza
		ldr r5, =mat_gel
		mov r1, #0						@;r1=files
	.bucleFil:
		mov r2, #0						@;r2=columnes
	.bucleCol:
		ldrb r6, [r5, #GEL_II]			@;r1=camp ii
		cmp r6, #0
		bgt .L_final					@;si es major que 0, ignorem la posicio
		tst r6, #0x80					@;comparem el bit de signe (1000 0000)
		bne .L_final					@;si es -1, ignorem la posicio
		@;si el camp ii es igual a 0
		mov r6, #10
		strb r6, [r5]					@;reinicialitzem a 10 el camp ii
		ldr r0, =0x06000000				@;r0=direccio base matriu
		@;r1=filas
		@;r2=columnas
		ldrb r3, [r5, #GEL_IM]			@;r3=camp im
		bl fija_metabaldosa
	.L_final:
		add r2, #1						@;seguent columna
		add r5, #GEL_TAM				@;seguent casella
		cmp r2, #COLUMNS				@;comparem amb el final de columna
		blo .bucleCol
		add r1, #1						@;seguent fila
		cmp r1, #ROWS					@;comparem amb el final de les files
		blo .bucleFil
		mov r0, #0
		strb r0, [r4]					@;desactivem update_gel
	.Lfi:

@;Tarea 2Ha

		
		pop {r0-r6, pc}




@;TAREA 2Eb;
@;activa_timer0(init); rutina para activar el timer 0, inicializando o no el
@;	divisor de frecuencia según el parámetro init.
@;	Parámetros:
@;		R0 = init; si 1, restablecer divisor de frecuencia original 'divFreq0'
	.global activa_timer0
activa_timer0:
		push {r0-r4, lr}
		
		cmp r0, #1				@; comparem si hem de restablir la frequencia
		bne .LnoInit0			@; si es diferent de 1, saltem 
		
		ldr r0, =divFreq0		@; direcció en r0 del divisor
		ldrh r1, [r0]			@; valor en r1 del divisor
		
		ldr r2, =divF0			@; direcció en r2 del divisor actual
		strh r1, [r2]			@; store del divisor de frecuencia inicial al actual
		
		ldr r3, =0x04000100		@; direcció de la data de timer0
		strh r1, [r3]			@; carreguem el divisor de frecuencia
		
	.LnoInit0:
		ldr r0, =timer0_on		@; direcció de la variable global timer0_on
		mov r1, #1				@; mov valor 1 a r1
		strh r1, [r0]			@; store de r1 en direcció de la variable global timer0_on
	
		ldr r4, =0x04000102 	@; registre de control del timer0
		mov r0, #0xC1			@; Start | IRQ Enabled | Prescaler 1 (F/64)
		strh r0, [r4]			@; store en la direcció de control del timer0

		pop {r0-r4, pc}


@;TAREA 2Ec;
@;desactiva_timer0(); rutina para desactivar el timer 0.
	.global desactiva_timer0
desactiva_timer0:
		push {r0-r2, lr}
		
		ldr r0, =timer0_on		@; direcció del timer0_on
		mov r1, #0				@; movem a r1 el valor 0
		strh r1, [r0]			@; fem un store del valor en la direcció del timer0_on
		
		ldr r2, =0x04000102		@; registre de control del timer0
		mov r1, #0		
		strh r1, [r2]			@; store del valor en el control del timer0
		
		pop {r0-r2, pc}



@;TAREA 2Ed;
@;rsi_timer0(); rutina de Servicio de Interrupciones del timer 0: recorre todas
@;	las posiciones del vector 'vect_elem' y, en el caso que el código de
@;	activación (ii) sea mayor que 0, decrementa dicho código y actualiza
@;	la posición del elemento (px, py) de acuerdo con su velocidad (vx,vy),
@;	además de mover el sprite correspondiente a las nuevas coordenadas;
@;	si no se ha movido ningún elemento, se desactivará el timer 0. En caso
@;	contrario, el valor del divisor de frecuencia se reducirá para simular
@;  el efecto de aceleración (con un límite).
	.global rsi_timer0
rsi_timer0:
		push {r0-r7, lr}
		mov r3, #0				@; control pel moviment del sprite (per desactivar timer0)
		ldr r4, =vect_elem		@; direcció del vector amb elements
		ldr r5, =n_sprites		@; direcció del nombre de sprites
		ldr r5, [r5]			@; valor del nombre de sprites
		mov r0, #0				@; index per controlar el bucle while (index també pel sprite, s'uilitza en moverSprite)
		
	.Lwhile:
		ldrh r6, [r4]			@; load de la primera posició del struct
		cmp r6, #0				@; comparem 'ii' amb 0
		ble .LnoMov				@; si r6 es menor o igual, vol dir que no hi ha canvi, saltem 
								@; si no salta, llavors hi ha element a moure
		sub r6, #1				@; decrementem 'ii' en 1
		mov r3, #1				@; control del moviment en 1 (com que hi ha moviment, no es desactivarà el timer0)
		strh r6, [r4]			@; guardem el nou valor 'ii' en r4 
		
		@; actualizar posición de acuerdo con su velocidad
		@; si moviment vertical --> vx = 0 i vy != 0 , si moviment horizontal --> vx != 0 i vy = 0

		ldrh r1, [r4, #ELE_PX]	@; offset en 2, osigui r1 = px		(registres per moverSprite)
		ldrh r2, [r4, #ELE_VX]	@; ofset en 6, osigui r2 = vx
		
		cmp r2, #0				@; comparem vx amb 0
		beq .LmovY				@; si vx es igual a 0, llavors no cal sumar px y vx
								@; si es diferent, llavors moviment vertical
		add r1, r2				@; sumem px amb vs, obtenim la seguent posició (tic a tic)
		strh r1, [r4, #ELE_PX]	@; store de px en el seu offset
		
	.LmovY:
		ldrh r2, [r4, #ELE_PY]	@; offset en 4, osigui r1 = py
		ldrh r7, [r4, #ELE_VY]	@; offset en 8, osigui r3 = vy
		
		add r2, r7				@; sumem py amb vy, obtenim la següent posició
		strh r2, [r4, #ELE_PY]	@; store de py en el seu offset
		
		@; mover sprite correspondiente a la nuevas coordenadas con funcion de SPR_moverSprite(),
		bl SPR_moverSprite
		
	.LnoMov:
		add r4, #10				@; pasem a la seguent posició del vector
		add r0, #1				@; suma 1 a l'index
		cmp r0, r5				@; comparem l'index amb n_sprites
		bne .Lwhile				@; si l'index es menor, saltem
		
		cmp r3, #0				@; comparem el control amb 0
		bleq desactiva_timer0	@; si es igual a 0, no hi ha hagut moviment, desactivem el timer0
		beq .Lfin				@; saltem al fina
								@; si no salta, activar la variable update_spr
		ldr r0, =update_spr		@; direcció del update_spr
		mov r1, #1				@; movem 1 a r1
		strh r1, [r0]			@; guardem l'update en 1
		
		@; decrementar divisor de frecuencia actual
		@;ldr r5, =7000
		@;ldr r6, =1000
		@;ldr r0, =divF0			@; direcció de la frequencia actual
		@;ldrb r1, [r0]			@; valor de la frequencia actual
		
		@;rsb r1, r1, #0			@; valor en positiu per poder treballar amb ell
		@;cmp r1, r5				@; comparem la frecuencia amb un divisor de 1000
		@;bhs .Lfin				@; si l'actual esta per sota d'aquest, saltem

		@;add r1, r6			@; si esta per sobre de 1000, restem 150 al divisor actual
		@;rsb r1, r1, #0			@; neguem el divisor
		@;strh r1, [r0]			@; fem un store d'aquest en la direcció de la frecuencia actual
		
		@;ldr r2, =0x04000100		@; e/s timer0 data
		@;strh r1, [r2] 			@; store freq
	.Lfin:
		
	pop {r0-r7, pc}

.end
