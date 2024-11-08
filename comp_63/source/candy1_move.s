@;=                                                         	      	=
@;=== candy1_move: rutinas para contar repeticiones y bajar elementos ===
@;=                                                          			=
@;=== Programador tarea 1E: genis.martinez@estudiants.urv.cat				  ===
@;=== Programador tarea 1F: genis.martinez@estudiants.urv.cat				  ===
@;=                                                         	      	=



.include "../include/candy1_incl.i"



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1E;
@; cuenta_repeticiones(*matriz,f,c,ori): rutina para contar el número de
@;	repeticiones del elemento situado en la posición (f,c) de la matriz, 
@;	visitando las siguientes posiciones según indique el parámetro de
@;	orientación 'ori'.
@;	Restricciones:
@;		* sólo se tendrán en cuenta los 3 bits de menor peso de los códigos
@;			almacenados en las posiciones de la matriz, de modo que se ignorarán
@;			las marcas de gelatina (+8, +16)
@;		* la primera posición también se tiene en cuenta, de modo que el número
@;			mínimo de repeticiones será 1, es decir, el propio elemento de la
@;			posición inicial
@;	Parámetros:
@;		R0 = dirección base de la matriz
@;		R1 = fila 'f'
@;		R2 = columna 'c'
@;		R3 = orientación 'ori' (0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte)
@;	Resultado:
@;		R0 = número de repeticiones detectadas (mínimo 1)
	.global cuenta_repeticiones
	
cuenta_repeticiones:
		push {lr}

		push {R1-R11}   @; almacenar todos los registros para recuperarlos al final de la rutina
						@; obtiene el desplazamiento de la matriz
		mov R4, #COLUMNS
		mul R4, R1,R4   @; R4=f*num_columnas
						@; R4= f*num_columnas+c   R4 almacena el desplazamiento para obtener la fila y columna de la matriz
  @; R5=M[f][c]   R5 equivale a elemento en lenguaje alto nivel. Multiplica el desplazamiento por 4 que es el numero de posiciones de memoria que ocupa cada elemento.  COMPROBAR QUE EL ELEMENTO OBTENIDO EN R5 SEA CORRECTO!!!
		add R4, R4, R2
		ldrb R5, [R0, R4]
		mov R6, #1      @; R6=numero de elementos repetidos. Empieza con 1
						@; comprueba si es orientacion ESTE
		cmp R3,#0       @; R3-0  -> si da 0 activa el flag Z
		beq este        @; si flag Z=1  salta a etiqueta norte
		cmp R3,#1       @; comprueba si valor R3 es 1
		beq sur
		cmp R3,#2       @; comprueba si valor R3 es 2
		beq oeste
        @; empieza caso norte. 
        @; R4 almacena los nuevos desplazamientos
bucle_norte: 
		sub R4, R4,#COLUMNS    @;R4= fila-- desplamiento * 4     PROBAR si COLUMNS es correcto para no poner 9
        cmp R4,#0
        blt fin
        ldrb R7, [R0,R4]  @;R7=M[f--][c]
        and R10, R7,#0x07
		and R11, R5,#0x07
		cmp R10, R11     	@;  comparar el elemento de la matriz (R5) con el valor de la columna en la fila superior. 
        beq inc_rep     @; si son iguales salta a la etiqueta para incrementar R6 (R6 almacena el contador de repeticiones)
        bne fin   @; si no son iguales entra al bucle norte para restar las n columnas para acceder a la fila superior
inc_rep:
        add R6, R6, #1  @; suma un elemento repetidos
        b bucle_norte   @; vuelve al bucle norte        
                
este:   mov R7,#COLUMNS  
        sub R7, R7, #1   @; columnas-1
        sub R8, R7,R2    @; calcula el numero de veces que ha de repetir el bucle (hasta llegar al final de la fila)
        mov R9, #0       @; numero de iteraciones del bucle
        
bucle_este:
        cmp R9, R8		@; se comprueba si se llega al numero max. de iteraciones
        bge fin
		add R9, R9, #1 @; actualizamos el número de iteraciones
        add R4, R4, #1   @; le sumamos 1 para desplazarnos a la siguiente columna
        ldrb R7,[R0,R4]	@;leemos el elemento de la matriz
		and R10, R7,#0x07
		and R11, R5,#0x07
		cmp R10, R11
		beq inc_rep_este 									                                                                                   
		b fin		
		
inc_rep_este:
        add R6, R6, #1  @; suma un elemento repetidos
        b bucle_este    @; vuelve al bucle este
     
sur:    mov R7,#ROWS
        mov R8, #COLUMNS
        mul R8, R7, R8     @; R7 almacena la longitud de la matriz (fila*columna)
bucle_sur: 
		add R4, R4, #COLUMNS        
        cmp R4,R8
        bhs fin
        @;obtener el elemento de la nueva posicion e incrementar el contador si se repite
        ldrb  R7, [R0,R4]     @; obtiene el  elemento  de la siguiente posicion hacia el este
        and R10, R7,#0x07
		and R11, R5,#0x07
		cmp R10, R11
        bne fin
        add R6, R6, #1
        b bucle_sur
        
oeste:  mov R8, R2   @; R8=num.colum que tenemos que decrementar
bucle_oeste:
        cmp R8,#0  @; Al llegar a 0 finalizamos
        beq fin
        sub R8,R8,#1   @; contador de columnas -1
        sub R4,R4,#1   @;decrementa el desplazamiento
        ldrb R7,[R0,R4]  @;obtiene elemento matriz
        and R10, R7,#0x07
		and R11, R5,#0x07
		cmp R10, R11      @;compara si el elemento es igual al leido anteriormente
        bne fin
        add R6, R6, #1   @;elemento igual. Incrementa en una unidad los elementos repetidos (R6)
        b bucle_oeste
        
fin:
        mov R0, R6

        pop {R1-R11}
	
		pop {pc}




@;TAREA 1F;
@; baja_elementos(*matriz): rutina para bajar elementos hacia las posiciones
@;	vacías, primero en vertical y después en sentido inclinado; cada llamada a
@;	la función sólo baja elementos una posición y devuelve cierto (1) si se ha
@;	realizado algún movimiento, o falso (0) si está todo quieto.
@;	Restricciones:
@;		* para las casillas vacías de la primera fila se generarán nuevos
@;			elementos, invocando la rutina 'mod_random' (ver fichero
@;			"candy1_init.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica se ha realizado algún movimiento, de modo que puede que
@;				queden movimientos pendientes. 
	.global baja_elementos
baja_elementos:
		push {lr}
		
		
		pop {pc}



@;:::RUTINAS DE SOPORTE:::



@; baja_verticales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en vertical; cada llamada a la función sólo baja elementos una posición y
@;	devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento. 
baja_verticales:
		push {lr}
		push {R0-R10}
		mov R1, #-1    @; pieza=-1  -> R1
		mov R2, #0     @; gelatina=0  -> R2
        mov R5, R4     @; R5-> direccion filas superiores
        
        sub R5, R5, #COLUMNS
        
        ldrb R6,[R5]
        cmp R6, #'7'
        beq sin_movimiento_vertical
        
        cmp R6, #'1'
        blt sin_movimiento_vertical
        cmp R6, #6
        ble intercambio_elemento_simple
        @; gelatinas....... 
        
        
		
		
intercambio_elemento_simple:
        str R6,[R4]
        mov R6,#0
        str R6,[R5]
        mov R0,#1
        b fin_baja_vertical
sin_movimiento_vertical:
        mov R0, #0
fin_baja_vertical:
		pop {R0-R10}
		
		pop {pc}



@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en diagonal; cada llamada a la función sólo baja elementos una posición y
@;	devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento. 
baja_laterales:
		push {lr}
		
		
		pop {pc}



.end