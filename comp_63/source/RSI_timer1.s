@;=                                                          	     	=
@;=== RSI_timer1.s: rutinas para escalar los elementos (sprites)	  ===
@;=                                                           	    	=
@;=== Programador tarea 2F: marc.fonseca@estudiants.urv.cat				  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.align 2
		.global timer1_on
	timer1_on:	.hword	0 			@;1 -> timer1 en marcha, 0 -> apagado
	divFreq1: 	.hword	-5727,487	@;divisor de frecuencia para timer 1 (-523655,96875/(32/0,35))



@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
	escSen: .space	2				@;sentido de escalado (0-> dec, 1-> inc)
	escFac: .space	2				@;factor actual de escalado
	escNum: .space	2				@;número de variaciones del factor


@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Fb;
@;activa_timer1(init); rutina para activar el timer 1, inicializando el sentido
@;	de escalado según el parámetro init.
@;	Parámetros:
@;		R0 = init;  valor a trasladar a la variable 'escSen' (0/1)
	.global activa_timer1
activa_timer1:
		push {r0-r2, lr}
		
		ldr r1, =escSen				@; r1 = @escSen
		strh r0, [r1]				@; escSen = init
		
		cmp r0, #1					@; if (init == 1)
		beq .LescSen_1				@; salta
		
		ldr r1, =escFac				@; r1 = @escFac
		mov r2, #1					@; r2 = 1
		mov r2, r2, lsl #8			@; r2 = 1 en 0.8.8
		strh r2, [r1]				@; escFac = 1 en 0.8.8
		
		mov r1, r2					@; r1 = escFac
		bl SPR_fijarEscalado		@; crida de funcio
	.LescSen_1:
		
		ldr r1, =escNum				@; r1 = @escNum
		mov r0, #0					@; r0 = 0
		strh r0, [r1]				@; escNum = 0
		
		ldr r1, =timer1_on			@; r1 = @timer1_on
		mov r0, #1					@; r0 = 1
		strh r0, [r1]				@; timer1_on = 1
		
		ldr r1, =divFreq1			@; r1 = @divFreq1
		ldrh r0, [r1]				@; r0 = divFreq1
		
		ldr r1, =0x04000104			@; direccio de TIMER1_DATA
		strh r0, [r1]				@; TIMER1_DATA = freq
		
		mov r0, #0x00C1				@; Mascara 1100 0001 per ficar el timer en marcha amb interrupcions de F/64
		
		ldr r1, =0x04000106			@; direccio de TIMER1_CR
		strh r0, [r1]				@; TIMER1_CR = freq modificada
		
		pop {r0-r2, pc}


@;TAREA 2Fc;
@;desactiva_timer1(); rutina para desactivar el timer 1.
	.global desactiva_timer1
desactiva_timer1:
		push {r0-r1, lr}
		
		mov r0, #0					@; r0 = 0
		ldr r1, =timer1_on			@; r1 = @timer1_on
		strh r0, [r1]				@; timer_on = 0
		
		ldr r1, =0x04000106			@; direccio de TIMER1_CR
		ldrh r0, [r1]				@; r0 = TIMER1_CR
		bic r0, #0x80				@; ponemos 0 en el bit 7 que significa STOP
		strh r0, [r1]				@; TIMER1_CR = timer desactivat
		
		pop {r0-r1, pc}



@;TAREA 2Fd;
@;rsi_timer1(); rutina de Servicio de Interrupciones del timer 1: incrementa el
@;	número de escalados y, si es inferior a 32, actualiza factor de escalado
@;	actual según el código de la variable 'escSen'; cuando se llega al máximo,
@;	se desactiva el timer1.
	.global rsi_timer1
rsi_timer1:
		push {r0-r3, lr}
		
		ldr r1, =escNum				@; r1 = @escNum
		ldrh r0, [r1]				@; r0 = escNum
		add r0, #1					@; escNum++
		
		cmp r0, #32					@; if (escNum < 32)
		strloh r0, [r1]				@; guardem escNum
		blhs desactiva_timer1		@; else desactiva timer 
		bhs .Ltimer1_fin			@; y acaba
		
		ldr r1, =escSen				@; r1 = @escSen
		ldrh r0, [r1]				@; r0 = escSen
		
		ldr r1, =escFac				@; r1 = @escFac
		ldrh r2, [r1]				@; r2 = escFac
		
		cmp r0, #0					@; if (escFac == 0)
		mov r3, #10					@; r3 = 1
		subne r2, r3				@; escFac--
		addeq r2, r3				@; escFac++
		
		strh r2, [r1]				@; guardem escFac
		
		mov r0, #0					@; r0 = 0
		mov r1, r2					@; r1 = escFac
		bl SPR_fijarEscalado
		
		ldr r1, =update_spr			@; r1 = @update_spr
		mov r0, #1					@; r0 = 1
		strh r0, [r1]				@; guardem update_spr
		
	.Ltimer1_fin:
		pop {r0-r3, pc}



.end
