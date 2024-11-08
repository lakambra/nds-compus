/*------------------------------------------------------------------------------

	$Id: movimiento.c, 2017-10-26 Santiago Romani $

	funciones de control del movimiento de las hormigas
	
------------------------------------------------------------------------------*/

#include <nds.h>
#include <stdio.h>
#include <func_sprites.h>

#define NUM_ANTS	128		// número de hormigas máximo que pueden aparecer
							// simultániemente en pantalla
#define INT_FRAC	16		// factor de conversión para trabajar con enteros
							// (INT) en un espacio de fraccionarios (FRAC),
							// es decir, en coma fija con log2(INT_FRAC) bits
							// para la parte decimal
#define NUM_DIRS	30		// número de direcciones posibles, cada dirección
							// supondrá un incremento de 360/NUM_DIRS grados
#define LIM_REDU	45		// límite de ciclos para reducción de mapas de
							// marcas
#define LIM_PASOS	500		// límite de pasos para desplegar todos los niveles
							// de feromonas posibles
#define FAC_SALIDA	6		// determina con que frecuencia salen nuevas
							// hormigas (1..10)

#define MB_FILS		48		// filas y columnas del mapa de baldosas
#define MB_COLS		64
#define MM_FILS		96		// filas y columnas de la matriz de marcas
#define MM_COLS		128
#define CS_FILS		768		// filas y columnas del campo de sprites
#define CS_COLS		1024

#define M_OBST		-100	// marca de obstáculo para las dos matrices
#define M_NIDO		-1		// marca de nido, para la matriz de nido a comida
#define B_OBST		4		// índice de baldosa para obstáculo
#define B_NIDO		5		// índice de baldosa para nido


short cont_redu;			// contador de ciclos para reducción de marcas
short limite_mov = 2;		// límite de ciclos para el movimiento:
							// 		1 -> 60 mov/s (rápido),
							// 		2 -> 30 mov/s (normal),
							// 		4 -> 15 mov/s (lento)
short spr_zoom = 2;				// factor (inverso) de escalado de las hormigas:
							//		1 -> 8x8 píxeles (diminutas),
							//		2 -> 16x16 píxeles (pequeñas),
							//		4 -> 32x32 píxeles (normales)
short coord_despx;			// coordenadas iniciales (x, y) del terreno,
short coord_despy;			// según factor de escalado:
							// spr_zoom = 4 ->	coord_despx = 0, coord_despy = 0
							// spr_zoom = 2 ->	coord_despx = 0 o 256
							//				 	coord_despy = 0 o 192
							// spr_zoom = 1 ->	coord_despx = 0, 128, 256 o 384
							//				 	coord_despy = 0,	96, 192, 288
short nido_x, nido_y;		// coordenadas iniciales del nido

short marcas[2][MM_FILS][MM_COLS];	// 2 matrices de marcas (0 -> marcas de nido
									// a comida, 1 -> marcas de comida a nido)

typedef struct
{
	short cos_mod;			// coseno de angulo por módulo de vector
	short sin_mod;			// seno de angulo por módulo de vector
} t_vect;

t_vect	avance[NUM_DIRS];	// vector de avance (vx, vy) para cada dirección

typedef struct
{
	int pb_pa;			// parámetros de una matriz de transformación afín
	int pd_pc;			// compactados en dos enteros de 32 bits
} t_trans;

t_trans	rot_esc[3][NUM_DIRS];	// matriz de transformaciones de rot./escalado,
				// para los 3 factores de escalado y las NUM_DIRS direcciones

typedef struct
{
	short	tipo;			// -1 -> desactivada, 0 -> negra, 1 -> roja,
							//  2 -> negra con comida, 3 -> roja con comida
	short	i_anim;			// índice de animación (0..2)
	short	s_anim;			// sentido de animación (-1, +1)
	short	px;				// posición x (0..1024 * INT_FRAC - 1)
	short	py;				// posición y (0..768 * INT_FRAC - 1)
	short	id_ang;			// identificador angulo (0..NUM_DIRS-1)
	short	est_giro;		// estado de giro (0= izq, 1= desactivado, 2= der)
	short	cnt_giro;		// contador de pasos de giro
	short	contador;		// contador de ciclos
	short	inicio;			// límite de ciclos para el inicio
	short	num_pasos;		// número de pasos que ha realizado la hormiga
} t_hormiga;

t_hormiga ants[NUM_ANTS];	// atributos de movimiento para cada hormiga

							// valores de comida, según índice de baldosa
							// (índices 4 y 5 no corresponden a bandosas de
							// comida, por lo que se debe replicar valor del
							// índice 3 sobre el índice 5, para "conectar" los
							// valores del vector)
const short v_comida[] = { -70, -56, -46, -37, 0, -37, -29, -22, -16, -11,
							-7, -4, -1};

short cont_hormigas = 0;	// contador de hormigas
int cont_comida = 0;		// contador de comida

u16 *baseBGmap2_main;		// dirección inicial mapa de baldosas fondo 2,
							// en procesador gráfico principal
u16 *baseBitmap2_sub;		// dirección inicial bitmap en fondo 2,
							// en procesador gráfico secundario



/* pintar_marcas(): actualiza el color del píxel correspondiente a las coordena-
   das que se pasan por parámetro en la imagen bitmap del fondo 2 del procesador
   gráfico secundario, según el nivel de feromonas actual, si hay obstáculo, si
   es nido o si hay comida
   Parámetros:
		mx: 	posición x (columna), de 0 a MM_COLS-1
		my:		posición y (fila), de 0 a MM_FILS-1
		tipo:	tipo de visualización
					0 -> nivel de feromonas
					1 -> obstáculo
					2 -> nido
					3 -> comida
*/
void pintar_marcas(short mx, short my, int tipo)
{
	short azul = 0, verde = 0, rojo = 0;
	unsigned short color;
	
	switch (tipo)
	{
		case 0:		// convertir rango de nivel de feromonas [0..127] a rango de
					// intensidades de canal de color [0..31]
				verde = (marcas[0][my][mx] / 4) & 0x1F;
				azul = (marcas[1][my][mx] / 4) & 0x1F;
							// compactar bits, con bit alfa dactivado
							// (no transparente) y bits del canal rojo a 0
				break;
		case 1:		// código de color de obstáculo
				rojo = 31; azul = 31;		// color magenta
				break;
		case 2:		// código de color de nido
				verde = 31;					// color verde
				break;
		case 3:		// código de color de comida (-69 -> 31 : -220 -> 100)
				rojo = ((marcas[1][my][mx] * 100) / -220) & 0x1F;
				verde = rojo;				// amarillo (intensidad variable)
				break;
	}
	color = (1 << 15) | (azul << 10) | (verde << 5) | rojo;
	baseBitmap2_sub[my*MM_COLS + mx] = color;
	if (tipo > 0)
	{			// marcas de obstáculo, nido y comida ocupan 4 posiciones
		baseBitmap2_sub[my*MM_COLS + mx+1] = color;
		baseBitmap2_sub[(my+1)*MM_COLS + mx] = color;
		baseBitmap2_sub[(my+1)*MM_COLS + mx+1] = color;
	}
}


/* buscar_nido(): determina la posición inicial de las baldosas que codifican el
   nido; si no lo encuentra, se supone que el nido estará en el centro del
   espacio de juego.
*/
void buscar_nido()
{
	short x, y;				// coordenadas de recorrido del terreno
	int encontrado = 0;		// booleano que indica si se ha encontrado el nido
	
	y = 0;
	do						// recorrido de filas
	{	x = 0;
		do					// recorrido de columnas
		{					// detectar la primera baldosa con el código de nido
			encontrado = (baseBGmap2_main[y*MB_COLS + x] == B_NIDO);
			x++;				// siguiente columna
		} while ((encontrado == 0) && (x < MB_COLS));
		y++;					// siguiente fila
	} while ((encontrado == 0) && (y < MB_FILS));
	
	if (encontrado == 0)	// si no hay baldosas de nido,
	{ 	x = MB_COLS/2;		// suponer que se encuentra en la mitad del mapa
		y = MB_FILS/2;
							// fijar 4 posiciones centrales con baldosas de nido
		baseBGmap2_main[(y-1)*MB_COLS + (x-1)] = B_NIDO;
		baseBGmap2_main[(y-1)*MB_COLS + x] = B_NIDO;
		baseBGmap2_main[y*MB_COLS + (x-1)] = B_NIDO;
		baseBGmap2_main[y*MB_COLS + x] = B_NIDO;
	}
	nido_x = x*16;		// hay que pasar de coordenadas de baldosas (64x48)
	nido_y = y*16;		// a coordenadas de sprites (1024x768)
}


/* fijar_4_marcas(): permite fijar el mismo valor en 4 posiciones vecinas de una
   matriz de marcas, en las posiciones (px, py), (px+1, py), (px, py+1) y
   (px+1, py+1), donde (px) es el índice de columna y (py) es el índice de fila
   Parámetros:
		im: 	identificador del matriz de marcas a modificar (0 o 1)
		px: 	posición x (columna), de 0 a MM_COLS-2
		py:		posición y (fila), de 0 a MM_FILS-2
		val:	valor a fijar
*/
void fijar_4_marcas(int im, short px, short py, short val)
{
	marcas[im][py][px] = val;
	marcas[im][py][px + 1] = val;
	marcas[im][py + 1][px] = val;
	marcas[im][py + 1][px + 1] = val;
}


/* inicializar_marcas(): detecta las baldosas que codifican el obstáculo y
   registra dichas posiciones en los mapas de marcas (con valor M_OBST).
   También inicializa las posiciones de comida en la primera matriz de marcas,
   con valores entre -1 y M_OBST+1, según el tamaño de las baldosas de comida.
   Parámetros:
		reset: booleano que indica si hay que resetear las marcas de caminos
*/
void inicializar_marcas(int reset)
{
	short x, y, ib;		// coordenadas de recorrido del terreno + índice baldosa
	int i;				// índice de matrices de marcas (0 o 1)
	
	for (i = 0; i < 2; i++)			// poner a cero todas las posiciones de los
		for (y = 0; y < MM_FILS; y++)	// dos mapas de marcas, excepto si no
			for (x = 0; x < MM_COLS; x++)	// hay que hacer reset (=0), en cuyo
											// caso solo se pondrán a cero los
											// obstáculos, la comida y la
				if (reset || (marcas[i][y][x] < 0))		// posición del nido
				{
					marcas[i][y][x] = 0;
					baseBitmap2_sub[y*MM_COLS + x] = 0;	// desactivar bit alfa
				} 										// (pixel transparente)
	
	for (y = 0; y < MB_FILS; y++)		// recorrido de filas
		for (x = 0; x < MB_COLS; x++)	// recorrido de columnas
		{
			ib = baseBGmap2_main[y*MB_COLS + x];
			if (ib == B_OBST)
			{
				for (i = 0; i < 2; i++)		  // para las dos matrices de marcas
				{			// cada baldosa de obstáculo bloquea 4 posiciones en
					fijar_4_marcas(i, x*2, y*2, M_OBST);	// el mapa de marcas
				}
				pintar_marcas(x*2, y*2, 1);
			}
			else if (ib == B_NIDO)
				{		  // marcar posiciones de nido con valor M_NIDO, solo en
					fijar_4_marcas(0, x*2, y*2, M_NIDO);   // matriz de marcas 0
					pintar_marcas(x*2, y*2, 2);
				}
			else if (ib != 0)	// marcar valores de comida con valor anterior
				{		// al correspondiente a la baldosa de comida detectada
						// para incrementar hasta el límite del siguiente nivel
					fijar_4_marcas(1, x*2, y*2, v_comida[ib-1]+1); // de comida,
					pintar_marcas(x*2, y*2, 3);	   // solo en matriz de marcas 1
				}									
		}
}


/* reducir_marcas(): reduce los niveles de feromonas de los dos mapas de marcas,
   cada LIM_REDU * limite_mov número de vertical blancs, utilizando la variable
   global cont_redu para contabilizar dichos vertical blancs.
*/
void reducir_marcas()
{
	short azul, verde;
	short x, y;				// coordenadas de recorrido del terreno
	int i;					// índices de matriz de marcas
	
	cont_redu++;				// incrementar contador de ciclos para reducción
	if (cont_redu > LIM_REDU * limite_mov)		// si llega al límite
	{
		cont_redu = 0;
		for (i = 0; i < 2; i++)
		{
			for (y = 0; y < MM_FILS; y++)
				for (x = 0; x < MM_COLS; x++)
					if (marcas[i][y][x] > 0)	// si hay marcas de feromona
						marcas[i][y][x]--;		// reducirlas en una unidad
		}
		for (y = 0; y < MM_FILS; y++)
			for (x = 0; x < MM_COLS; x++)			// si hay marcas de feromona
				if ((marcas[0][y][x] > 0) || (marcas[1][y][x] > 0))
				{
						// convertir rango de nivel de feromonas [0..127] a
						// rango de intensidades de canal de color [0..31]
					verde = (marcas[0][y][x] / 4) & 0x1F;
					azul = (marcas[1][y][x] / 4) & 0x1F;
				// compactar bits, con bit alfa dactivado (no transparente)
				// y bits del canal de rojo a 0
					baseBitmap2_sub[y*MM_COLS + x] = (1 << 15) | (azul << 10)
															   | (verde << 5);
				}
				else	// si no hay marcas de feromonas, ni hay nido
						// ni obstáculo ni comida, desactivar bit alfa
					if ((marcas[0][y][x] == 0) && (marcas[1][y][x] == 0))	
						baseBitmap2_sub[y*MM_COLS + x] = 0;
	}
}


/* transferir_rotesc() transfiere las NUM_DIRS matrices de transformación afín
   desde la variable global rot_esc[] a la variable global de información de
   sprites oam_data y después a los registros de Entrada/Salida físicos OAM,
   según el factor de escalado fijado en la variable global spr_zoom.
*/
void transferir_rotesc()
{
	int i;		// i es índice de fila de la matriz rot_esc[3][NUM_DIRS]
	int j;		// j es índice de grupo de rotación_escalado, según dirección
	
		// calcular índice de fila de rot_esc[i][NUM_DIRS], según spr_zoom
		//	spr_zoom = 4 -> i = 2
		//	spr_zoom = 2 -> i = 1
		//	spr_zoom = 1 -> i = 0
	i = (spr_zoom == 4 ? 2 : (spr_zoom == 2 ? 1 : 0));
		// copiar los valores de todas las direcciones en las posiciones
		// correspondientesd el oam lógico, con la llamada a la función
		// SPR_fijarRotacionEscalado()
	for (j = 0; j < NUM_DIRS; j++)
		SPR_fijarRotacionEscalado(j, rot_esc[i][j].pb_pa, rot_esc[i][j].pd_pc);
		
	swiWaitForVBlank();
	SPR_actualizarSprites(OAM, 0, (1 << NUM_DIRS) - 1);	// transferir todos los
									// grupos de rotación/escalado a OAM físico
									// (procesador gráfico 2D principal)
}


/* inicializar_movimiento(): desactiva todas las hormigas y genera todos los
   parámetros de rotación/escalado para el vector de avance y las matrices de
   transformación afín para todas las direcciones posibles.
*/
void inicializar_movimiento()
{
	int id, ang, j;
	short pa, pb, pc, pd;
	
		// desactivar todas las hormigas
	for (id = 0; id < NUM_ANTS; id++)
	{
		ants[id].tipo = -1;
		ants[id].contador = 0;
		ants[id].id_ang = rand() % NUM_DIRS;	// dirección inicial aleatoria
		ants[id].inicio = (rand() % (NUM_ANTS * FAC_SALIDA)) + 4;	// límite 
		SPR_ocultarSprite(id);								// para activación
	}

		// fijar todos los factores de rotación/escalado
	for (id = 0; id < NUM_DIRS; id++)
	{
			// obtener ángulo en rango de libnds [-2^31..2^31 - 1]
		ang = degreesToAngle(id*360/NUM_DIRS);
			// Lerp retorna seno/coseno en formato 0.18.14
		pa = (cosLerp(ang) / 16) & 0xFFFF;		// pasar a formato 0.8.8
		pb = (sinLerp(ang) / 16) & 0xFFFF;
			// multiplicamos sin/cos por 3 para aumentar el avance de la hormiga
			// multiplicamos por INT_FRAC para escalar al rango fraccionario
			// en el que se mueven las hormigas, dividido por 256 para
			// anular los decimales que no se pueden tener en cuenta
		avance[id].cos_mod = (3 * pa * INT_FRAC) / 256;
		avance[id].sin_mod = (3 * pb * INT_FRAC) / 256;
		
		pd = pa;	// definir matriz de rotación básica ( cos(a)  sin(a))
		pc = -pb;	//									 (-sin(a)  cos(a))
			// almacenar los valores de rotación básica, compactados y
			// multiplicados para los tres factores de escalado (1, 2, 4)
		for (j = 0; j < 3; j++)
		{						// compactar y almacenar
			rot_esc[j][id].pb_pa = ((int) pb << 16) | (pa & 0xFFFF);
			rot_esc[j][id].pd_pc = ((int) pd << 16) | (pc & 0xFFFF);
				// multiplicar por 2, para reducir el tamaño del sprite a cada
			pa *= 2; pb *= 2; pc *= 2; pd *= 2;		// nuevo tamaño de escalado
		}
	}
	transferir_rotesc();
}


/* posicionar_hormiga(int id): transformar las coordenadas de la hormiga (id),
   desde el espacio de movimiento (1024x768) a coordenadas de pantalla (256x192)
   Parámetros:
		id: identificador de hormiga [0..NUM_ANTS - 1]
*/ 
void posicionar_hormiga(int id)
{
	int pos_x, pos_y;
	
		// transformar coordenadas de espacio de movimiento (1024x768) a
		// coordenadas de pantalla (256x192): dividir por INT_FRAC para eliminar
		// decimales, restar las coordenadas iniciales para ajustar el
		// desplazamiento del espacio, pero hay que multiplicarlas por 2 porque
		// el espacio de los fondos es de (512x384), luego hay que dividir por
		// spr_zoom para reducir el factor de escalado al del espacio de los
		// sprites (256x192); por último, restar 32 por desplazamiento del punto
		// central de cada sprite: 32x32 píxeles, que doblados son 64x64 píxeles
	pos_x = (((int) ants[id].px / INT_FRAC) - coord_despx * 2) / spr_zoom - 32;
	pos_y = (((int) ants[id].py / INT_FRAC) - coord_despy * 2) / spr_zoom - 32;
		// limitar valores máximos para evitar desbordamiento o wrap-around de
		// las coordenadas
	if (pos_x > 256) pos_x = 256;		// 256 es primera coord superior fuera
	if (pos_x < -63) pos_x = -63;		// de rango [0..255]
	if (pos_y > 192) pos_y = 192;		// 192 es primera coord superior fuera
	if (pos_y < -63) pos_y = -63;		// de rango [0..191];
										// 		-63 corresponde a 256-63 = 193
	SPR_moverSprite(id, pos_x, pos_y);
}


/* inicializar_hormiga(): inicializa todos los parámetros del vector ants[] para
   la hormiga cuyo índice se pasa por parámetro, además de crear el sprite
   correspondiente, transformarlo y moverlo a su posición
   Parámetros:
		id: identificador de hormiga [0..NUM_ANTS - 1]
*/
void inicializar_hormiga(int id)
{
	ants[id].tipo = (id < NUM_ANTS / 10 ? 1 : 0);
					// tipo de hormiga roja para id < 10% del máximo de hormigas
					// tipo de hormiga negra para el resto
	ants[id].i_anim = 0;				// imagen inicial 0
	ants[id].s_anim = 1;				// sentido de cambio de imagen positivo
	ants[id].px = nido_x * INT_FRAC;	// posición inicial en centro del nido
	ants[id].py = nido_y * INT_FRAC;
	ants[id].id_ang = rand() % NUM_DIRS;	// dirección inicial aleatoria
	ants[id].est_giro = 1;				// estado de giro desactivado
	ants[id].num_pasos = 0;				// reiniciar contador de pasos
		// activar sprite (id) con tamaño cuadrado (0), 32x32 píxeles (2),
		// índice de baldosa según tipo de hormiga (tipo * 3 * 16): cada tipo
		// tiene 3 imágenes y cada imagen contiene 16 baldosas
	SPR_crearSprite(id, 0, 2, ants[id].tipo * 3 * 16);
		// activar rotación/escalado con grupo de transformación según
		// índice de ángulo (id_ang), con tamaño doblado (1)
	SPR_activarRotacionEscalado(id, ants[id].id_ang, 1);
		// fijar posición inicial, según factor de escalado y desplazamiento
	posicionar_hormiga(id);
		// actualizar contador de hormigas activas
	cont_hormigas++;
	printf("\x1b[8;0H hormigas = %d", cont_hormigas);
}


/* desactivar_hormiga(): resetea los parámetros del vector ants[] para indicar
   que la hormiga cuyo índice se pasa por parámetro está desactivada, es decir,
   dentro del nido, además de borrar el sprite correspondiente y actualizar el
   contador de hormigas activas
   Parámetros:
		id: identificador de hormiga [0..NUM_ANTS - 1]
*/
void desactivar_hormiga(int id)
{
	ants[id].tipo = -1;		// indicar que la hormiga está desactivada
	ants[id].contador = 0;
	ants[id].inicio = (rand() % (NUM_ANTS * FAC_SALIDA)) + 4;
	SPR_ocultarSprite(id);		// la hormiga desaparece de pantalla
	cont_hormigas--;
	printf("\x1b[8;0H hormigas = %d ", cont_hormigas);
}


/* asignar_probabilidades(): determina la probabilidad relativa de cada
   dirección, según los niveles de feromonas detectados sobre las mismas
   direcciones
   Parámetros:
		prob[]:	vector de 3 posiciones con niveles de feromonas
	Resultado:
		prob[]: números de fracciones de probabilidad en cada dirección
		total:	número total de fracciones
*/
short asignar_probabilidades(short prob[])
{
	int i, j, k;
	short temp;
	short v_prob[3];				// valores de trabajo
	short id_prob[] = {0, 1, 2};	// índices de probabilidad originales
	
	if ((prob[0] == prob[1]) && (prob[1] == prob[2]))	// caso trivial
	{
		prob[0] = 1;
		prob[1] = 10;		// priorizar dirección central
		prob[2] = 1;
	}
	else
	{
		v_prob[0] = prob[0];			// copiar niveles de feromonas
		v_prob[1] = prob[1];
		v_prob[2] = prob[2];
		for (i = 0; i < 2; i++)			// ordenar vector por máximo
			for (j = i+1; j < 3; j++)
				if (v_prob[j] > v_prob[i])	// hay que hacer un intercambio
				{							// de los niveles de feromonas
					temp = v_prob[i]; v_prob[i] = v_prob[j]; v_prob[j] = temp;
							   // y de sus índices de dirección correspondientes
					temp = id_prob[i]; id_prob[i] = id_prob[j];
															  id_prob[j] = temp;
				}
		k = 20;					// k = número de fracciones máximo para
		prob[id_prob[0]] = k;	// dirección con más peso
			
		if (v_prob[1] != 0)		// si la segunda dirección de más peso permite
		{						// movimiento, asignar probabilidad alta o 1
								//según llegue o no al nivel de feromonas máximo
			prob[id_prob[1]] = (v_prob[1] == v_prob[0] ? k : 1);
		}
		if (v_prob[2] != 0)			// ídem última dirección
		{
			prob[id_prob[2]] = (v_prob[2] == v_prob[0] ? k : 1);
		}
		
		temp = prob[0] + prob[1] + prob[2];		// probabilidad total
		if ((temp > k+2) && (prob[1] == k))		// en caso de más de 2 dir. con
		{										// máxima probabilidad y dir.
			if (prob[0] == k) prob[0] = 3;		// central tiene máxima prob.,
			if (prob[2] == k) prob[2] = 3;		// rebajar probabilidad lateral 
		}
	}
	return(prob[0] + prob[1] + prob[2]);
}



/* mover_hormiga(id): calcula la nueva posición y ángulo de movimiento de la
   hormiga cuyo identificador se pasa por parámetro, teniendo en cuenta su
   posición actual y su ángulo actual, evitando salir de su espacio de
   movimiento
*/
void mover_hormiga(int id)
{
	int i, j, k;
	short mx, my, ib, ib_sig;		// coordenadas en mapa de marcas 
	short px[3], py[3];				// posibles posiciones de avance (3)
	short id_ang[3];				// identificadores de direcciones de avance
	short num_prob;					// número de posibles direcciones de avance
	short prob[3];					// probabilidad de cada dirección de avance
	short prob_total = 0;			// acumulador de la probabilidad total
	short nivel;					// variable para calcular nivel de feromonas
	
	id_ang[1] = ants[id].id_ang;	// obtener dirección de avance actual,
									// dirección a la izquierda (+3 índices)
	id_ang[0] = (id_ang[1] + 3) % NUM_DIRS;
									// dirección a la derecha (-3 índices)
	id_ang[2] = id_ang[1] - 3; if (id_ang[2] < 0) id_ang[2] += NUM_DIRS;
	
	num_prob = 0;
	for (i = 0; i < 3; i++)		// para las 3 posibles direcciones de avance
	{							// obtener coordenadas de 5 posiciones de avance
		px[i] = ants[id].px + 5 * avance[id_ang[i]].cos_mod;
		py[i] = ants[id].py + 5 * avance[id_ang[i]].sin_mod;
		mx = px[i] / (8*INT_FRAC);			// junto con sus coordenadas en mapa
		my = py[i] / (8*INT_FRAC);			// de marcas
							// analizar si la hipotética posición está en bordes
		if ((px[i] < 0) || (px[i] > (CS_COLS-1)*INT_FRAC)
							|| (py[i] < 0) || (py[i] > (CS_FILS-1)*INT_FRAC)
								// o si está tocando un obstáculo del laberinto
								// (dividir coordenadas por 8 para pasar del
								// espacio de movimiento de los sprites 1024x768
								// al espacio de marcas 128x96)
				|| (marcas[0][my][mx] == M_OBST))
			prob[i] = 0;	// en caso afirmativo, no hay posibilidad de avance
		else				// en caso negativo,
		{					// si busca comida, mirar en marcas de comida (k=1)
							// si busca nido, mirar en marcas de nido (k=0)
			k = (ants[id].tipo < 2 ? 1 : 0);
						// prob[i] registra nivel de feromonas (positivo),
						// o el valor 256 si detecta comida o nido (negativo)
			prob[i] = (marcas[k][my][mx] >= 0 ? marcas[k][my][mx] : 256);
				
			num_prob++;		// contabilizar numero de posibles movimientos
		} 
	}

	if (num_prob > 0)		// si hay alguna posibilidad de movimiento
		prob_total = asignar_probabilidades(prob);

	if (num_prob == 0)		// si no puede avanzar hacia ningúna posición
	{
		if (ants[id].est_giro == 1)		// si no se encuentra en estado de giro
		{						// generar bit aleatorio (0 -> 50%, 1 -> 50%)
			ants[id].est_giro = (rand() % 2) * 2;	// estado de giro = 0 o 2
			ants[id].cnt_giro = 0;					// empieza a girar
		}
			// según el valor del estado de giro, desviar 2 direcciones a la
			// izquierda (est_giro = 0) o a la derecha (est_giro = 2)
		if (ants[id].est_giro == 0)
			ants[id].id_ang = (id_ang[1] + 2) % NUM_DIRS;
		else
		{	ants[id].id_ang = id_ang[1] - 2;
			if (ants[id].id_ang < 0) ants[id].id_ang += NUM_DIRS;
		}
		ants[id].cnt_giro++;
		if (ants[id].cnt_giro == NUM_DIRS/2)  // si ya ha dado una vuelta entera								
			desactivar_hormiga(id);			  // sin salir del giro, desativarla
		else
			if (ants[id].id_ang != id_ang[1])	// si ha habido cambio de
						// dirección de avance, actualizar rotación del sprite
				SPR_activarRotacionEscalado(id, ants[id].id_ang, 1);
	}
	else
	{	
				// si anteriormente estaba en una situación sin posibilidad de
				// avance, resetear el estado de giro a desactivado (=1)
		if (ants[id].est_giro != 1)	ants[id].est_giro = 1;
			
		ants[id].num_pasos++;		// actualizar número de pasos
			// calcular nivel de feromonas, complementario al número de pasos
			// realizado, de manera que cuanto más cerca del punto de partida
			// (nido o comida) más alto será el nivel de feromonas
		nivel = ((LIM_PASOS - ants[id].num_pasos) * 127) / LIM_PASOS;
			// el nivel resultante tiene que estar escalado entre 1 y 127 
		if (nivel < 1) nivel = 1;
			
			// generar valor aleatorio dentro del rango total de probabilidad
		j = (rand() % prob_total) + 1;
		i = 0;
		k = prob[0];		// k es probabilidad acumulada
		while (j > k)		// mientras valor aleatorio supera prob. acumulada
		{
			i++;
			k += prob[i];		// acumular siguiente probabilidad
		}
		
		k = id_ang[1];			// k toma por valor el ángulo de avance actual
								// si i == 0, pasar a una dirección a la izq.
		if (i == 0) k = (k + 1) % NUM_DIRS;
		else if (i == 2)		// si i == 2, pasar a una dirección a la derecha
				k = (k > 0 ? k - 1 : NUM_DIRS - 1);
		ants[id].id_ang = k;	// fijar dirección seleccionada
		ants[id].px = ants[id].px + avance[k].cos_mod;	// fijar nuevas coord.
		ants[id].py = ants[id].py + avance[k].sin_mod;
		
		if (ants[id].px < 0) ants[id].px = 0;		// restringir límites del
		if (ants[id].px > CS_COLS * INT_FRAC - 1)	// espacio de coordenadas
			ants[id].px = CS_COLS * INT_FRAC - 1;	// del movimiento de las
		if (ants[id].py < 0) ants[id].py = 0; 		// hormigas
		if (ants[id].py > CS_FILS * INT_FRAC - 1)
			ants[id].py = CS_FILS * INT_FRAC - 1;
			
		if (ants[id].id_ang != id_ang[1])	// si ha habido cambio de
				// dirección de avance, actualizar rotación del sprite
			SPR_activarRotacionEscalado(id, ants[id].id_ang, 1);
			
				// convertir coordenadas de movimiento hormigas a coordenadas
				// de mapa de marcas (/8*INT_FRAC)
		mx = ants[id].px / (8*INT_FRAC);
		my = ants[id].py / (8*INT_FRAC);
			
		if (ants[id].tipo < 2)		// procesar avance hacia la comida
		{
			if ((marcas[0][my][mx] >= 0) && (marcas[0][my][mx] < 127))
			{		// fijar el nivel de la hormiga si supera el nivel actual
				if (nivel > marcas[0][my][mx])		// del mapa de marcas,
				{	marcas[0][my][mx] = nivel;		// para conseguir marcar el
					pintar_marcas(mx, my, 0);		// mejor recorrido posible
				}
			}
								// si en la nueva posición hay comida
			if ((marcas[1][my][mx] < 0) && (marcas[1][my][mx] > M_OBST))
			{
				ants[id].tipo += 2;		// cambiar a tipo de hormiga con comida
				ants[id].num_pasos = 0;	// asignar nuevos pasos hacia el nido
										// dirección de avance opuesta
				ants[id].id_ang = (ants[id].id_ang + NUM_DIRS/2) % NUM_DIRS;
					
				mx &= 0xFFFFFFFE;		// poner a 0 el bit de menor peso para
				my &= 0xFFFFFFFE;		// obtener coordenadas múltiples de 2
												// reducir el índice de comida
				fijar_4_marcas(1, mx, my, marcas[1][my][mx]+3);
					
							// obtener código de baldosa de comida, convirtiendo
							// espacio coordenadas	de (128x96) a (64x48)
				ib = *(baseBGmap2_main + (my*MB_COLS + mx)/2);
				if (marcas[1][my][mx] > v_comida[ib])
				{								// actualizar baldosa de comida
					ib_sig = ib + 1;	 // calcular siguiente baldosa de comida
					if (ib_sig == 4) ib_sig = 6;  // saltarse las baldosas 4 y 5
					if (ib_sig > 12) ib_sig = 0;  // identificador baldosa vacía
							// escribir mapa de baldosas (dividir coord. por 2)
					*(baseBGmap2_main + (my*MB_COLS + mx)/2) = ib_sig;
					if (ib_sig == 0)	// si supera la baldosa con menos comida		
						fijar_4_marcas(1, mx, my, 0); // elimnar marca de comida
				}
				pintar_marcas(mx, my, 3);
			}
		}
		else 		// procesar avance hacia el nido
		{
			if ((marcas[1][my][mx] >= 0) && (marcas[1][my][mx] < 127))
			{		// fijar el nivel de la hormiga si supera el nivel actual
				if (nivel > marcas[1][my][mx])		// del mapa de marcas,
				{	marcas[1][my][mx] = nivel;		// para conseguir marcar el
					pintar_marcas(mx, my, 0);		// mejor recorrido posible
				}
			}
								// si en la nueva posición hay nido
			if (marcas[0][my][mx] == M_NIDO)
			{
				desactivar_hormiga(id);
				cont_comida++;
				printf("\x1b[9;0H comida = %d", cont_comida);
			}
		}
	}
}


/* mover_sprites(): realiza todas las operaciones necesarias para mover las
   hormigas o crear nuevas hormigas (salir del nido)
*/
void mover_sprites()
{
	short id;
	
	for (id = 0; id < NUM_ANTS; id++)	// para todas las hormigas
	{
		if (ants[id].tipo == -1)		// si es una hormica inactiva
		{
			ants[id].contador++;		// aumenta contador para estableceer
			if (ants[id].contador >= ants[id].inicio)	// cuándo se debe crear
			{ 											// de nuevo la hormiga
				inicializar_hormiga(id);
				ants[id].contador = 0;
			}
		}
		else
		{							// aumenta contador para establecer cuándo
			ants[id].contador++; 	// se debe realizar el movimiento
			if (ants[id].contador >= limite_mov)
			{
				ants[id].contador = 0;
					// aumenta índice de animación, según signo del sentido
					// de animación (+1 o -1)
				ants[id].i_anim = ants[id].i_anim + ants[id].s_anim;
					// corregir índice de animación y sentido si ha superado
					// el límite en cualquiera de los dos sentidos
				if ((ants[id].i_anim < 0) || (ants[id].i_anim > 2))
				{	// debido a que los índices de animación son 3 (0, 1, 2),
					// al cambiar el sentido siempre llegamos al índice 1
					ants[id].i_anim = 1;
					ants[id].s_anim = -ants[id].s_anim;
				}
					// actualizar avance según dirección de movimiento actual
				mover_hormiga(id);
					// actualizar imagen de animación, según tipo más índice
					// de animación
				SPR_fijarBaldosa(id, (ants[id].tipo*3 + ants[id].i_anim) * 16);
					// actualizar posición según factor de escalado y
					// desplazamiento
				posicionar_hormiga(id);
			}
		}
	}
}


/* actualizar_sprites(): transfiere los atributos de todos los sprites NUM_ANTS,
   desde la variable global oam_data a los registros de Entrada/Salida de OAM,
   sin transferir los parámetres de las matrices de transformación afín.
*/ 
void actualizar_sprites()
{
	SPR_actualizarSprites(OAM, NUM_ANTS, 0);
}

