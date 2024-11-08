@;=                                                          	     	=
@;=== candy1_init.s: rutinas para inicializar la matriz de juego	  ===
@;=                                                           	    	=
@;=== Programador tarea 1A: joel.lacambra@estudiants.urv.cat				  ===
@;=== Programador tarea 1B: joel.lacambra@estudiants.urv.cat				  ===
@;=                                                       	        	=



.include "../include/candy1_incl.i"



@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
@; matrices de recombinación: matrices de soporte para generar una nueva matriz
@;	de juego recombinando los elementos de la matriz original.
	mat_recomb1:	.space ROWS*COLUMNS
	mat_recomb2:	.space ROWS*COLUMNS



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1A;
@; inicializa_matriz(*matriz, num_mapa): rutina para inicializar la matriz de
@;	juego, primero cargando el mapa de configuración indicado por parámetro (a
@;	obtener de la variable global 'mapas'), y después cargando las posiciones
@;	libres (valor 0) o las posiciones de gelatina (valores 8 o 16) con valores
@;	aleatorios entre 1 y 6 (+8 o +16, para gelatinas)
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocará la rutina
@;			'mod_random'
@;		* para evitar generar secuencias se invocará la rutina
@;			'cuenta_repeticiones' (ver fichero "candy1_move.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = número de mapa de configuración
	.global inicializa_matriz
inicializa_matriz:
		push {r0-r12, lr}			@; guardar registros utilizados
		mov r4, r0					@; passar la direcció de la matriu de joc a r4
		mov r3, r1					@; passar el mapa a r3
		mov r6, #ROWS				@; passar a r6 el nombre de files
		mov r7, #COLUMNS			@; passar a r7 el nombre de columnes
		mov r11, #ROWS*COLUMNS		@; passar a r11 el valor 81 per després calcula les direccions dels mapes
		
		ldr r10, =mapas				@; passem la direcció base de la variable global mapas

		cmp r3, #0					@; comparem el mapa amb 0
		bne .LifMapNo0				@; si aquest es diferent a 0, saltem al if
		b .LifMap0					@; si la comparació no es compleix, saltem l'if següent
		
	.LifMapNo0:						@; calcula la direcció base del mapa de configuració depenent del mapa passat per paràmetre
		mul r12, r3, r11			@; guarda en r12 la multiplicació del mapa per 81
		add r10, r12				@; sumem a la direcció base inicial la multiplicació obtenint la direcció base del mapa

	.LifMap0:						@; comencem a calular les posicions de la matriu
		mov r1, #0					@; passem a r1 el valor inicial de "i" en 0
		
	.Lfori:							@; primer bucle
		mov r2, #0					@; passem a r2 el valor inicial de "j" en 0
		
	.Lforj:							@; segon bucle
		mla r9, r1, r7, r2			@; calculem el desplaçament en la matriu, r9 = i * NC + j
		ldrb r5, [r10, r9]			@; llegim el valor r5 = mapa[i][j]
		
		mov r11, r5					@; passem a r11 el valor llegit
		and r11, #0x07				@; and per obtenir el valors dels bits 2...0
		mov r12, r5, lsr #3			@; passem a r12 el valor desplaçat 3 bits a la dreta, ens quedem amb el bits 4...3

		cmp r12, #0x0				@; comparem el bits 4...3 (00) amb 0
		beq .Lif0					@; si son iguals llavors saltem al if0 per una altra comparació
		
		cmp r12, #0x01				@; comparem el bits 4...3 (01) amb 01
		beq .Lif1					@; si son iguals llavors saltem al if1 per una altra comparació
		cmp r12, #0x02				@; comparem el bits 4...3 (10) amb 10
		beq .Lif1					@; si son iguals llavors saltem al if1 per una altra comparació

	.Lif0:							@; comprovació de 0
		cmp r11, #0x0				@; comparar r11 (bits 2...0) amb 0
		beq .Lifrand1				@; salta al if per random si son iguals
		b .Lifcopia					@; si no ho son salta directament al final i copiar el valor a la matriu de joc

	.Lif1:							@; comprovació de 0
		cmp r11, #0x0				@; comparar r11 (bits 2...0) amb 0
		beq .Lifrand2				@; salta al if per random si son iguals
		b .Lifcopia					@; si no ho son salta directament al final i copiar el valor a la matriu de joc
									@; NOTA: la diferencia d'aquests dos if te que veure en la metodologia del random, explicat seguidament
	.Lifrand1:						@; primer random
		mov r0, #6					@; passem a r0 el rang màximg dels valors randoms
		bl mod_random				@; invoquem la funció
		add r0, #1
		@;cmp r0, #0					@; comparem r0 (el valor random) amb 0
		@;beq .Lifrand1				@; bucle do-while, mentre el valor obtingut sigui 0 seguirà fent randoms
		
		mov r5, r0					@; passem el valor random a r5
		strb r5, [r4, r9]			@; guardem el valor random en la matriu de joc
		mov r0, r4					@; passem a r0 la direcció base de la matriu de joc
		mov r3, #2					@; passem a r3 el valor 2(oeste)
		bl cuenta_repeticiones		@; invoquem a cuenta repeticiones
		cmp r0, #3					@; comparem r0 amb #3
		bhs .Lifrand1				@; si el valor es igual és major o igual és a dir, que hi ha repeticions, passem al principi del if
		
		mov r0, r4					@; passem a r0 la direcció base de la matriu de joc		
		mov r3, #3					@; passem a r3 el valor 3(norte)
		bl cuenta_repeticiones		@; invoquem a cuenta repeticiones
		cmp r0, #3					@; comparem r0 amb #3
		bhs .Lifrand1				@; si es valor es igual és major o igual és a dir, que hi ha repeticions, passem al principi del if
		b .Lfin						@; saltem al final del if si ya no hi ha repeticions

	.Lifrand2:	
		mov r0, #6					@; passem a r0 el rang màximg dels valors randoms
		bl mod_random				@; invoquem la funció
		add r0, #1
		@;cmp r0, #0					@; comparem r0 (el valor random) amb 0
		@;beq .Lifrand2				@; bucle do-while, mentre el valor obtingut sigui 0 seguirà fent randoms
		
		add r5, r0					@; sumem a r5(valor original) el valor obtingut
		strb r5, [r4, r9]			@; guardem el valor random en la matriu de joc
		sub r5, r0					@; restem al valor inicial el valor random, per si hi ha repeticions, per no superposar el valor
		mov r0, r4					@; passem a r0 la direcció base de la matriu
		mov r3, #2					@; passem a r3 el valor 2(oeste)
		bl cuenta_repeticiones		@; invoquem a cuenta repeticiones
		cmp r0, #3					@; comparem r0 amb #3
		bhs .Lifrand2				@; si el valor és major o igual és a dir, que hi ha repeticions, passem al princii del if
		
		mov r0, r4					@; passem a r0 la direcció base de la matriu de joc		
		mov r3, #3					@; passem a r3 el valor 3(norte)
		bl cuenta_repeticiones		@; invoquem a cuenta repeticiones
		cmp r0, #3					@; comparem r0 amb #1
		bhs .Lifrand2				@; si el valor és major o igual és a dir, que hi ha repeticions, passem al principi del if
		b .Lfin						@; saltem al final del if

	.Lifcopia:						@; últims passos
		strb r5, [r4, r9]			@; storage del valor especificat en la matriu de joc
		
	.Lfin:
		add r2, #1					@; r2 = j+1
		cmp r2, #COLUMNS			@; comparar r2 amb columnes
		blo .Lforj					@; mentre que r2 sigui més petit saltarà
		
		add r1, #1					@; r1 = i+1
		cmp r1, #ROWS				@; comprar r1 amb files
		
		blo .Lfori					@; mentre que r1 sigui més petit saltarà
		pop {r0-r12, pc}			@;recuperar registros y volver



@;TAREA 1B;
@; recombina_elementos(*matriz): rutina para generar una nueva matriz de juego
@;	mediante la reubicación de los elementos de la matriz original, para crear
@;	nuevas jugadas.
@;	Inicialmente se copiará la matriz original en 'mat_recomb1', para luego ir
@;	escogiendo elementos de forma aleatoria y colocandolos en 'mat_recomb2',
@;	conservando las marcas de gelatina.
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocará la rutina
@;			'mod_random'
@;		* para evitar generar secuencias se invocará la rutina
@;			'cuenta_repeticiones' (ver fichero "candy1_move.s")
@;		* para determinar si existen combinaciones en la nueva matriz, se
@;			invocará la rutina 'hay_combinacion' (ver fichero "candy1_comb.s")
@;		* se supondrá que siempre existirá una recombinación sin secuencias y
@;			con combinaciones
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
	.global recombina_elementos
recombina_elementos:
		push {r0-r12, lr}
		mov r6, #ROWS				@; passar a r6 el nombre de files
		mov r7, #COLUMNS			@; passar a r7 el nombre de columnes
		
		ldr r10, =mat_recomb1
		ldr r11, =mat_recomb2
		mov r4, r0					@; passem la direcció de la matriu a r4
		
		@; Primer bucle per passar els valors a mat_recomb1 (matriu amb 0s y valors elementals (1-6)
	.LInici:
		
		mov r1, #0					@; r1 = inicialitzacio de i en 0
		
	.Lfori2:
		mov r2, #0					@; passem a r2 el valor inicial de "j" en 0
		
	.Lforj2:
		mla r9, r1, r7, r2			@; calculem el desplaçament en la matriu, r9 = i * NC + j
		ldrb r5, [r4, r9]			@; llegim el valor de la matriu de joc
		
		tst r5, #0x07				@; si valor r5 = 000, flagZ = 1
		beq .Lval0					@; si flagZ = 1, llavors salta
		
		mvn r5, r5					@; neguem els valors 
		tst r5, #0x07				@; si r5 = 111, flagZ = 1
		beq .Lval0					@; si flagZ = 1, llavors salta
		mvn r5, r5					@; si no salta a cap, neguem una altra vegada el valor per obtenir el valor original
		
		mov r12, r5, lsr #3			@; passem els 2bits 4..3 a r12
		
		tst r12, #0x03				@; si valor r12 = 00, flagZ = 1
		beq .Lcopiavalor			@; saltem a copiar valor elemental
		
		and r5, #0x07				@; sabem que el valor només pot ser gel o geld. fem and 0x07 per obtenir el valor elemental (1-6)
		strb r5, [r10, r9]
		b .Lfin1
		
	.Lval0:
		mov r5, #0					@; passem el valor 0 a r5
		strb r5, [r10, r9]			@; copiem el valor a mat_recomb1
		b .Lfin1					@; saltem al final per continuar la iteració
		
	.Lcopiavalor:
		strb r5, [r10, r9]			@; copiem directament el valor de la matriu de joc a mat_recomb1
		
	.Lfin1:
		add r2, #1					@; r2 = j+1
		cmp r2, #COLUMNS			@; comparar r2 amb columnes
		blo .Lforj2					@; mentre que r2 sigui més petit saltarà
		
		add r1, #1					@; r1 = i+1
		cmp r1, #ROWS				@; comprar r1 amb files
		
		blo .Lfori2					@; mentre que r1 sigui més petit saltarà
		
		
		@; Segon bucle per passar els valors a mat_recomb2 (matriu amb bloque sólido, hueco, gel sin elemento y el resto en 0.)

		mov r1, #0					@; r1 = inicialitzacio de i en 0
	.Lfori3:
		mov r2, #0					@; passem a r2 el valor inicial de "j" en 0
	
	.Lforj3:
		mla r9, r1, r7, r2			@; calculem el desplaçament en la matriu, r9 = i * NC + j
		ldrb r5, [r4, r9]			@; Passem el valor a r5 de la matriu de joc
		
		tst r5, #0x07				@; si valor r5 = 000, flagZ = 1
		beq .Lcopia					@; si flagZ = 1, salta (GEl o GEL.D VACIA)
		
		mvn r5, r5					@; neguem el valor llegit
		tst r5, #0x07				@; si valor r5 = 111, flagZ = 1
		beq .Lcopia2				@; si flagZ = 1, salta (BLOQ SOLID O HUECO)
		mvn r5, r5					@; si no salta, neguem una altra vegada per obtenir el valor original
		
		mov r12, r5, lsr #3			@; passem a r12, els bits 4..3
		
		tst r12, #0x03				@; comparem si r12 = 00, llavors flagZ --> 1
		beq .Lvalor0				@; si el flagZ--> 1, saltem
		
		mov r5, r12, lsl #3			@; passem a r5 els bits 4..3 (gel o gel.d) pero sense l'element elemental (1-6)
		strb r5, [r11, r9]			@; passem el valor a mat_recomb1
		b .Lfin2
		
	.Lcopia:
		strb r5, [r11, r9]			@; copia directa del valor a mat_recomb1
		b .Lfin2					@; saltem a una nova iteració

	.Lcopia2:
		mvn r5, r5					@; neguem una altra vegada el valor
		strb r5, [r11, r9]			@; copiem el valor en mat_recomb2
		b .Lfin2					@; saltem a una nova iteració

	.Lvalor0:
		mov r5, #0					@; passem a r5 el valor 0
		strb r5, [r11, r9]			@; passem el valor a mat_recomb1
		
	.Lfin2:
		add r2, #1					@; r2 = j+1
		cmp r2, #COLUMNS			@; comparar r2 amb columnes
		blo .Lforj3					@; mentre que r2 sigui més petit saltarà
		
		add r1, #1					@; r1 = i+1
		cmp r1, #ROWS				@; comprar r1 amb files
		
		blo .Lfori3					@; mentre que r1 sigui més petit saltarà
		
		@; Tercer bucle, passar valor aleatoris de mat_recomb1 != 0 a mat_recomb2 depenent
		@; del valor en la matriu de joc
		
		mov r1, #0					@; inicialitzem r1 amb i = 0
	.Lfori4:
		mov r2, #0					@; inicialitzem r2 amb j = 0
		
	.Lforj4:
		mla r9, r1, r7, r2			@; desplaçament per la matriu --> r9 = i * NC + j
		ldrb r5, [r4, r9]			@; passem a r5 el valor d'una posició de la matriu de joc
		tst r5, #0x07				@; si valor r5 = 000, flagZ = 1
		beq .Lfin3					@; saltem al final per una altra iteració
		
		mvn r5, r5					@; neguem el valor de r5
		tst r5, #0x07				@; si r5 = 111, flagZ = 1
		beq .Lfin3					@; saltem al final per una altra iteració
		mvn r5, r5					@; si no salta al final neguem el valor per obtenir el original
		
		mov r6, #0					@; Posem un contador pere evitar un bucle infinit
		
	.Lnovapos:
		mov r0, #ROWS				@; passem a r0 el rang maxim de files
		bl mod_random				@; invoquem a la funció per obtenir un valor random
		mov r3, r0					@; passem la fila a r3
		mov r0, #COLUMNS			@; passem a r0 el rang maxim de columnes
		bl mod_random				@; invoquem a a la funció per obtenir un valor random
		mov r12, r0					@; passem la columna a r12
		
		mla r8, r3, r7, r12			@; desplaçament per trobar un valor != 0 en mat_recomb1
		ldrb r5, [r10, r8]			@; passem el valor de mat_recomb1 a r5
		cmp r5, #0					@; comparem aquest valor amb 0
		beq .Lnovapos				@; si es 0 saltem
		
		ldrb r0, [r11, r9]			@; passem a r0 el valor de mat_recomb2 (per si es gelatina)
		add r5, r0					@; sumem la possible gelatina amb el valor de mat_recomb1
		strb r5, [r11, r9]			@; finalment passem el valor sumat a la matriu mat_recomb2
		
		push {r3}
		
		mov r0, r11					@; passem a r0 la dirreció de mat_recomb2
		mov r3, #2					@; passem a r3 la primera direcció pel cuenta_repeticiones
		bl cuenta_repeticiones		@; invoquem la funció cuenta_repeticiones
		cmp r0, #3					@; comparem si ha 3 repeticiones
		
		pop {r3}
		
		bhs .LRestagel				@; salta per obtenir una possible gelatina i restituir el valor en mat_recomb2	
		
		push {r3}
		
		mov r0, r11					@; passem a r0 la dirreció de mat_recomb2
		mov r3, #3					@; passem a r3 la primera direcció pel cuenta_repeticiones
		bl cuenta_repeticiones		@; invoquem la funció cuenta_repeticiones
		cmp r0, #3					@; comparem si ha 3 repeticiones
		
		pop {r3}
		
		bhs .LRestagel				@; salta per obtenir una possible gelatina i restituir el valor en mat_recomb2	
		
		mov r5, #0					@; passem a r5 el valor de 0
		strb r5, [r10, r8]			@; possem el valor de mat_recomb1 en 0 perquè no s'agafi una altra vegada

		@;r0 fila elemento	mod_random fila
		@;r1 columna elemto	mod_random columna
		@;r2 fila destino		fila del bucle
		@;r3 columna destino	columna del bucle
		
		push {r0-r4}
		
		mov r4, r2				@; temporal de columna desti
		
		mov r0, r3				@; fila origen a r0
		mov r2, r1				@; fila desti a r1
		mov r1, r12				@; columna origen a r1
		mov r3, r4				@; columna desti a r3
		bl activa_elemento
		
		pop {r0-r4}	
			
		b .Lfin3
	
	.LRestagel:
		mov r12, r5, lsr #3			@; passem a r12 la posible gelatina (aixi eliminem l'element posat pel random)
		mov r5, r12, lsl #3			@; pasem a r5 la posible gelatina
		strb r5, [r11, r9]			@; pasem a la matriu una posible gelatina
		add r6, #1					@; contador sumar 1
		cmp r6, #ROWS*COLUMNS*3		@; comprova un valor 81 vegades, 
		beq .LInici					@; salta si són iguals
		b .Lnovapos					@; necessitem un nou valor, llavors saltem
		
	.Lfin3:
		add r2, #1					@; r2 = j+1
		cmp r2, #COLUMNS			@; comparar r2 amb columnes
		blo .Lforj4					@; mentre que r2 sigui més petit saltarà
	
		add r1, #1					@; r1 = i+1
		cmp r1, #ROWS				@; comparar r1 amb files

		blo .Lfori4					@; mentre r1 sigui més petit saltarà
		
		mov r0, r4					@; passem a r0 la direcció de la matriu de joc completa
		bl hay_combinacion			@; funcio de hay_combinacio
		cmp r0, #1					@; comparem el output de la funció amb 1
		beq .LInici					@; si es 1, hi ha combinacio llavors anem al principi
		
		@; Bucle final per pasar els valors de mat_recomb2 a la matriu de joc
		
		mov r1, #0					@; inicialitzem i en 0
	.Lfori5:
		mov r2, #0					@; inicialitzem i en 0
	.Lforj5:
		mla r9, r1, r7, r2			@; calculem el desplaçament per les matrius
		
		ldrb r5, [r11, r9]			@; llegim el valor de mat_recomb2
		strb r5, [r4, r9]			@; store del valor a la matriu de joc
		
		add r2, #1					@; r2 = j+1
		cmp r2, #COLUMNS			@; comparar r2 amb columnes
		blo .Lforj5					@; mentre que r2 sigui més petit saltarà
		
		add r1, #1					@; r1 = i+1
		cmp r1, #ROWS				@; comprar r1 amb files
		blo .Lfori5
		
		
		
		pop {r0-r12, pc}



@;:::RUTINAS DE SOPORTE:::



@; mod_random(n): rutina para obtener un número aleatorio entre 0 y n-1,
@;	utilizando la rutina 'random'
@;	Restricciones:
@;		* el parámetro 'n' tiene que ser un valor entre 2 y 255, de otro modo,
@;		  la rutina lo ajustará automáticamente a estos valores mínimo y máximo
@;	Parámetros:
@;		R0 = el rango del número aleatorio (n)
@;	Resultado:
@;		R0 = el número aleatorio dentro del rango especificado (0..n-1)
	.global mod_random
mod_random:
		push {r1-r4, lr}
		
		cmp r0, #2				@;compara el rango de entrada con el mínimo
		bge .Lmodran_cont
		mov r0, #2				@;si menor, fija el rango mínimo
	.Lmodran_cont:
		and r0, #0xff			@;filtra los 8 bits de menos peso
		sub r2, r0, #1			@;R2 = R0-1 (número más alto permitido)
		mov r3, #1				@;R3 = máscara de bits
	.Lmodran_forbits:
		cmp r3, r2				@;genera una máscara superior al rango requerido
		bhs .Lmodran_loop
		mov r3, r3, lsl #1
		orr r3, #1				@;inyecta otro bit
		b .Lmodran_forbits
		
	.Lmodran_loop:
		bl random				@;R0 = número aleatorio de 32 bits
		and r4, r0, r3			@;filtra los bits de menos peso según máscara
		cmp r4, r2				@;si resultado superior al permitido,
		bhi .Lmodran_loop		@; repite el proceso
		mov r0, r4			@; R0 devuelve número aleatorio restringido a rango
		
		pop {r1-r4, pc}



@; random(): rutina para obtener un número aleatorio de 32 bits, a partir de
@;	otro valor aleatorio almacenado en la variable global 'seed32' (declarada
@;	externamente)
@;	Restricciones:
@;		* el valor anterior de 'seed32' no puede ser 0
@;	Resultado:
@;		R0 = el nuevo valor aleatorio (también se almacena en 'seed32')
random:
	push {r1-r5, lr}
		
	ldr r0, =seed32				@;R0 = dirección de la variable 'seed32'
	ldr r1, [r0]				@;R1 = valor actual de 'seed32'
	ldr r2, =0x0019660D
	ldr r3, =0x3C6EF35F
	umull r4, r5, r1, r2
	add r4, r3					@;R5:R4 = nuevo valor aleatorio (64 bits)
	str r4, [r0]				@;guarda los 32 bits bajos en 'seed32'
	mov r0, r5					@;devuelve los 32 bits altos como resultado
		
	pop {r1-r5, pc}	



.end
