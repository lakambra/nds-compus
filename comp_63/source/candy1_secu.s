	@;=                                                               		=
@;=== candy1_secu.s: rutinas para detectar y elimnar secuencias 	  ===
@;=                                                             	  	=
@;=== Programador tarea 1C: marc.fonseca@estudiants.urv.cat				  ===
@;=== Programador tarea 1D: marc.fonseca@estudiants.urv.cat				  ===
@;=                                                           		   	=



.include "../include/candy1_incl.i"



@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
@; número de secuencia: se utiliza para generar números de secuencia únicos,
@;	(ver rutinas 'marcar_horizontales' y 'marcar_verticales') 
	num_sec:	.space 1



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1C;
@; hay_secuencia(*matriz): rutina para detectar si existe, por lo menos, una
@;	secuencia de tres elementos iguales consecutivos, en horizontal o en
@;	vertical, incluyendo elementos en gelatinas simples y dobles.
@;	Restricciones:
@;		* para detectar secuencias se invocará la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 si hay una secuencia, 0 en otro caso
	.global hay_secuencia
hay_secuencia:
		push {r1-r12, lr}
		
		mov r12, r0							@; r12 = @martriz		
		
		mov r1, #0							@; i = 0
		mov r2, #0							@; j = 0
		
		mov r4, #ROWS						@; r4 = #ROWS
		mov r5, #COLUMNS					@; r5 = #COLUMNS
		
		mov r8, #0x07						@; r8 = 111
		
		mov r9, #ROWS-2						@; r9 = #ROW - 2
		mov r10, #COLUMNS-2					@; r10 = #COLUMN - 2
		
	.Lsv_forROWS:							@; i = 0; i < row; i++
		cmp r1, r4							@; r4 < #ROWS (9)
		bhs .Lsv_endROWS					@; Salta al final si es 8 o mayor (N)
		mov r2, #0							@; j = 0
		
	.Lsv_forCOLUMNS:						@; j = 0; j < col; j++
		cmp r2, r5							@; r5 < #COLUMNS (9)
		bhs .Lsv_endCOLUMNS					@; Salta al final si es 8 o mayor (N)
		
		mla r6, r1, r5, r2					@; r6 = i * NC + j
		ldrb r11, [r12, r6]					@; r11 = matriz [i][j]
		
	.Lsv_if_1:				
		tst r8, r11							@; xx 000 = xx 000 -> salta
		beq .Lsv_endif1
		
		mvn r7, r11							@; r7 = -matriz [i][j]
		tst r7, r8							@; xx 111 = xx 111 -> salta
		beq .Lsv_endif1
		
	.Lsv_if_2:		
		cmp r1, r9							@; i >= #ROW - 2
		bhs .Lsv_if_else_2_1					
		
		cmp r2, r10							@; j >= #COLUMN - 2
		bhs .Lsv_if_else_2_2
		
		mov r0, r12							@; r0 = @matriz
		mov r3, #1							@; orientació -> vertical
		bl cuenta_repeticiones				@; funcion de prog 3
		cmp r0, #3							@; r0 >= 3 -> return TRUE;
		bhs .Lsv_noEsZero
		
		mov r0, r12							@; r0 = @matriz
		mov r3, #0							@; orientació -> horizontal
		bl cuenta_repeticiones				@; funcion de prog 3
		cmp r0, #3							@; r0 >= 3 -> return TRUE;
		bhs .Lsv_noEsZero
		
		b .Lsv_endif1	
	 
	.Lsv_if_else_2_1:
		mov r0, r12							@; r0 = @matriz
		mov r3, #0							@; orientació -> horizontal
		bl cuenta_repeticiones				@; funcion de prog 3
		cmp r0, #3							@; r0 >= 3 -> return TRUE;
		bhs .Lsv_noEsZero
		
	.Lsv_if_else_2_2:
		mov r0, r12							@; r0 = @matriz
		mov r3, #1							@; orientació -> vertical
		bl cuenta_repeticiones				@; funcion de prog 3
		cmp r0, #3							@; r0 >= 3 -> return TRUE
		bhs .Lsv_noEsZero
		
	.Lsv_endif1:
		add r2, #1							@; j++
		b .Lsv_forCOLUMNS	
		
	.Lsv_endCOLUMNS:
		add r1, #1							@; i++
		b .Lsv_forROWS
		
	.Lsv_endROWS:
		mov r0, #0							@; r0 = FALSE
		b .Fin
		
	.Lsv_noEsZero:
		mov r0, #1							@; r0 = TRUE
		
	.Fin:
		pop {r1-r12, pc}



@;TAREA 1D;
@; elimina_secuencias(*matriz, *marcas): rutina para eliminar todas las
@;	secuencias de 3 o más elementos repetidos consecutivamente en horizontal,
@;	vertical o combinaciones, así como de reducir el nivel de gelatina en caso
@;	de que alguna casilla se encuentre en dicho modo; 
@;	además, la rutina marca todos los conjuntos de secuencias sobre una matriz
@;	de marcas que se pasa por referencia, utilizando un identificador único para
@;	cada conjunto de secuencias (el resto de las posiciones se inicializan a 0). 
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección de la matriz de marcas
@;=                                                               		=
@;=== candy1_secu.s: rutinas para detectar y elimnar secuencias 	  ===
@;=                                                               		=

	.global elimina_secuencias
elimina_secuencias:
		push {r0-r2, r5-r12, lr}
		
		mov r6, #0
		mov r8, #0							@; R8 es desplazamiento posiciones matriz
		
	.Lelisec_for0:			
		strb r6, [r1, r8]					@; poner matriz de marcas a cero 
		add r8, #1
		cmp r8, #ROWS*COLUMNS
		blo .Lelisec_for0
		
		mov r8, #1							@; r8 = 1
		ldr r9, =num_sec					@; r9 = @num_sec
		strb r8, [r9]						@; num_sec = r8
		
		bl marcar_horizontales				
		bl marcar_verticales
		
		mov r9, #COLUMNS					@; r9 = numero columnas
		
		mov r11, r1							@; r11 = matriz marcas
		mov r12, r0							@; r12 = matriz juego
		
		mov r0, #0							@; r0 = i
		mov r1, #0							@; r1 = j
		
	.Lsv_forROWS4:							@; i = 0; i < row; i++
		cmp r0, #ROWS						@; r0 < #ROWS
		bhs .Lsv_endROWS4					
		mov r1, #0							@; j = 0
		
	.Lsv_forCOLUMNS4:						@; j = 0; j < col; j++
		cmp r1, #COLUMNS					@; r1 < #COLUMNS
		bhs .Lsv_endCOLUMNS4				
		
		mla r5, r0, r9, r1					@; r5 = i * NC + j	
		ldrb r6, [r11, r5]					@; r6 = marcas[i][j]
		ldrb r10, [r12, r5]					@; r10 = juego[i][j]
		
		cmp r6, #0							@; r6 == 0 (casilla vacia) -> next
		beq .Lsv_nextElemento
		
		mov r10, r10, lsr #3				@; 10 010 -> 00 010 = r10
		
		cmp r10, #0x01						@; 00 001 == 00 001 -> gelatina simple
		beq .Lsv_gelatinaSimple
		
		cmp r10, #0x02						@; 00 010 == 00 010 -> gelatina doble
		beq .Lsv_gelatinaDoble
		
		push {r0}
		
		bl elimina_elemento
		
		pop {r0}
		
		mov r10, #0							@; r10 = 00 000 (espai buit) 
		strb r10, [r12, r5]
		b .Lsv_nextElemento
		
	.Lsv_gelatinaSimple:
		push {r0-r2}
		
		mov r2, r1
		mov r1, r0
		ldr r0, =0x06000000					@; r0 = @mapaddr
		
		bl elimina_gelatina
		
		pop {r0-r2}
		
		push {r0}
		
		bl elimina_elemento
		
		pop {r0}
		
		mov r10, #0
		strb r10, [r12, r5] 
		b .Lsv_nextElemento
		
	.Lsv_gelatinaDoble:
		
		push {r0-r2}
		
		mov r2, r1
		mov r1, r0
		ldr r0, =0x06000000					@; r0 = @mapaddr
		
		bl elimina_gelatina
		
		pop {r0-r2}
		
		push {r0}
		
		bl elimina_elemento
		
		pop {r0}
		
		mov r10, #8				
		strb r10, [r12, r5]
	.Lsv_nextElemento:
		add r1, #1							@; j++
		b .Lsv_forCOLUMNS4	
		
	.Lsv_endCOLUMNS4:
		add r0, #1							@; i++
		b .Lsv_forROWS4
		
	.Lsv_endROWS4:
		pop {r0-r2, r5-r12, pc}


	
@;:::RUTINAS DE SOPORTE:::



@; marcar_horizontales(mat): rutina para marcar todas las secuencias de 3 o más
@;	elementos repetidos consecutivamente en horizontal, con un número identifi-
@;	cativo diferente para cada secuencia, que empezará siempre por 1 y se irá
@;	incrementando para cada nueva secuencia, y cuyo último valor se guardará en
@;	la variable global 'num_sec'; las marcas se guardarán en la matriz que se
@;	pasa por parámetro 'mat' (por referencia).
@;	Restricciones:
@;		* se supone que la matriz 'mat' está toda a ceros
@;		* para detectar secuencias se invocará la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección de la matriz de marcas
marcar_horizontales:
		push {r0-r12, lr}
		
		mov r12, r0							@; r12 = @martriz
		mov r4, r1							@; r4 = @marcas
		
		mov r1, #0							@; i = 0
		mov r2, #0							@; j = 0
		
		mov r3, #0							@; orientació -> horizontal
		
		mov r5, #0x07						@; r5 = 111
		
		mov r6, #ROWS						@; r6 = #ROWS (9)
		mov r7, #COLUMNS					@; r7 = #COLUMNS (9)
		
		ldr r8, =num_sec					@; r8 = @num_sec
		
		mov r9, #COLUMNS-2					@; r9 = #COLUMN - 2
		
	.Lsv_forROWS2:							@; i = 0; i < row; i++
		cmp r1, #ROWS						@; r1 < #ROWS (9)
		bhs .Lsv_endROWS2					@; Salta al final si es 8 o mayor (N)
		mov r2, #0							@; j = 0
		
	.Lsv_forCOLUMNS2:						@; j = 0; j < col-2; j++
		cmp r2, r9							@; r2 < #COLUMNS-2 (7)
		bhs .Lsv_endCOLUMNS2				@; Salta al final si es 6 o mayor (N)
		
		mla r10, r1, r7, r2					@; r10 = i * NC + j
		ldrb r11, [r12, r10]				@; r11 = matriz [i][j]
		
		tst r5, r11							@; xx 000 = xx 000 -> salta
		beq .Lsv_next
		
		mvn r11, r11						@; r11 = -matriz [i][j]
		tst r5, r11							@; xx 111 = xx 111 -> salta
		beq .Lsv_next
		
		mov r0, r12							@; r0 = @matriz
		bl cuenta_repeticiones				@; funcion de prog 3
		cmp r0, #3							@; r0 >= 3 -> marcar la secuencia
		bhs .Lsv_marcar_1
		
		cmp r0, #2							@; if r0 == 2 -> j = j++ and next    
		addeq r2, #1	
		beq .Lsv_next
		
		cmp r0, #1							@; if r0 = 1 -> next
		beq .Lsv_next
		
	.Lsv_marcar_1:
		add r11, r2, r0						@; r11 = j + quants nombres hi ha a la secuencia (>=3)
		
	.Lsv_marcar_2:
		cmp r2, r11							@; r2 < r11
		bhs .Lsv_endmarcar					@; Salta al final si es superior al nombre final de la secuancia (N)
		
		ldrb r6, [r8]						@; r6 = num_sec
		
		mla r10, r1, r7, r2					@; r10 = i * NC + j
		strb r6, [r4, r10]					@; marcas [i][j] = num_sec
		
		add r2, #1							@; j++
		b .Lsv_marcar_2
	 
	.Lsv_endmarcar:
		add r6, #1							@; num_sec++
		strb r6, [r8]						@; num_sec = num_sec++
		
		b .Lsv_forCOLUMNS2
		
	.Lsv_next:
		add r2, #1							@; j++
		b .Lsv_forCOLUMNS2	
		
	.Lsv_endCOLUMNS2:
		add r1, #1							@; i++
		b .Lsv_forROWS2
		
	.Lsv_endROWS2:
		
		pop {r0-r12, pc}



@; marcar_verticales(mat): rutina para marcar todas las secuencias de 3 o más
@;	elementos repetidos consecutivamente en vertical, con un número identifi-
@;	cativo diferente para cada secuencia, que seguirá al último valor almacenado
@;	en la variable global 'num_sec'; las marcas se guardarán en la matriz que se
@;	pasa por parámetro 'mat' (por referencia);
@;	sin embargo, habrá que preservar los identificadores de las secuencias
@;	horizontales que intersecten con las secuencias verticales, que se habrán
@;	almacenado en en la matriz de referencia con la rutina anterior.
@;	Restricciones:
@;		* se supone que la matriz 'mat' está marcada con los identificadores
@;			de las secuencias horizontales
@;		* la variable 'num_sec' contendrá el siguiente indentificador (>=1)
@;		* para detectar secuencias se invocará la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección de la matriz de marcas
marcar_verticales:
		push {r0-r12, lr}
		
		mov r12, r0							@; r12 = @martriz
		mov r4, r1							@; r4 = @marcas
		
		mov r1, #0							@; i = 0
		mov r2, #0							@; j = 0
		
		mov r7, #COLUMNS					@; r7 = #COLUMNS (9)
		
		ldr r8, =num_sec					@; r8 = @num_sec
		
	.Lsv_forCOLUMNS3:						@; j = 0; j < col; j++
		cmp r2, r7							@; r2 < #COLUMNS (9)
		bhs .Lsv_fin3						@; Salta al final si es 8 o mayor (N)
		
	.Lsv_forROWS3:							@; i = 0; i < row-2; i++
		cmp r1, #ROWS-2						@; r1 < #ROWS-2 (7)
		bhs .Lsv_endROWS3					@; Salta al final si es 6 o mayor (N)
		
		mla r10, r1, r7, r2					@; r10 = i * NC + j
		ldrb r11, [r12, r10]				@; r11 = matriz [i][j]
		
		mov r5, #0x07						@; r8 = 111
		
		tst r5, r11							@; xx 000 = xx 000 -> salta
		beq .Lsv_next2
		
		mvn r11, r11						@; r11 = -matriz [i][j]
		tst r11, r5							@; xx 111 = xx 111 -> salta
		beq .Lsv_next2
		
		mov r0, r12							@; r0 = @matriz
		mov r3, #1							@; orientació -> vertical
		bl cuenta_repeticiones				@; funcion de prog 3
		cmp r0, #3							@; r0 >= 3 -> marcar la secuencia
		blo .Lsv_next2
		
	.Lsv_marcar2_1:
		add r11, r1, r0						@; r11 = i + quants nombres hi ha a la secuencia (>=3)
		mov r5, #0							@; r5 = nombre de vegades que comproba si existeix alguna sequencia creuant
	.Lsv_marcar2_2:
		
		mla r10, r1, r7, r2					@; r10 = i * NC + j
		ldrb r9, [r4, r10]					@; r10 = marcas [i][j]
		
		cmp r9, #0							@; r11 != 0 -> aquella sequencia marcarla amb aquell numero
		bne marcar_mismaSequencia_1
		
		cmp r1, r11							@; r1 >= r11 -> No es creua cap sequencia ja creada
		bhs marcar_nuevaSequencia_1
		
		add r1, #1							@; i++
		add r5, #1							@; r5 = r5 + 1
		b .Lsv_marcar2_2
		
	marcar_mismaSequencia_1:
		sub r1, r5							@; r1 = i (moguda) - nombre de vegades que comproba si existeix alguna sequencia creuant
		add r11, r1, r0						@; r11 = i (actual) + quants nombres hi ha a la secuencia (>=3)
	 
	marcar_mismaSequencia_2:
		cmp r1, r11							@; r1 < r11
		beq .Lsv_endmismaSequencia2
		
		mla r10, r1, r7, r2					@; r10 = i * NC + j
		strb r9, [r4, r10]					@; marcas [i][j] = num_sec
		
		add r1, #1							@; i++
		b marcar_mismaSequencia_2
		
	.Lsv_endmismaSequencia2:
		sub r1, r0
		b .Lsv_next2
	marcar_nuevaSequencia_1:
		sub r1, r0							@; r1 = i (moguda) - nombre de secuencia
		add r11, r1, r0						@; r11 = i (actual) + quants nombres hi ha a la secuencia (>=3)
	marcar_nuevaSequencia_2:
		cmp r1, r11							@; r1 < r1 + quants nombres hi ha a la secuencia (>=3)
		bhs .Lsv_endmarcar2					@; Salta al final si es superior al nombre final de la secuancia  (N)
		
		ldrb r6, [r8]						@; r6 = num_sec
		
		mla r10, r1, r7, r2					@; r10 = i * NC + j
		strb r6, [r4, r10]					@; marcas [i][j] = num_sec
		
		add r1, #1							@; i++
		b marcar_nuevaSequencia_2
	  
	.Lsv_endmarcar2:
		add r6, #1							@; num_sec++
		strb r6, [r8]						@; num_sec = num_sec++
      
		b .Lsv_forROWS3
		
	.Lsv_next2:
		add r1, #1							@; i++
		b .Lsv_forROWS3	
	.Lsv_endROWS3:
		add r2, #1							@; j++
		mov r1, #0							@; i = 0
		b .Lsv_forCOLUMNS3
		
	.Lsv_fin3:
	  
		pop {r0-r12, pc}



.end
