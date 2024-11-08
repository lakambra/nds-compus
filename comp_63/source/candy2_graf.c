/*------------------------------------------------------------------------------

	$ candy2_graf.c $

	Funciones de inicialización de gráficos (ver "candy2_main.c")

	Analista-programador: santiago.romani@urv.cat
	Programador tarea 2A: joel.lacambra@estudiants.urv.cat
	Programador tarea 2B: marc.fonseca@estudiants.urv.cat
	Programador tarea 2C: genis.martinez@estudiants.urv.cat
	Programador tarea 2D: uuu.uuu@estudiants.urv.cat

------------------------------------------------------------------------------*/
#include <nds.h>
#include <candy2_incl.h>
#include <Graphics_data.h>
#include <Sprites_sopo.h>


/* variables globales */
int n_sprites = 0;					// número total de sprites creados
elemento vect_elem[ROWS*COLUMNS];	// vector de elementos
gelatina mat_gel[ROWS][COLUMNS];	// matriz de gelatinas



// TAREA 2Ab
/* genera_sprites(): inicializar los sprites con prioridad 1, creando la
	estructura de datos y las entradas OAM de los sprites correspondiente a la
	representación de los elementos de las casillas de la matriz que se pasa
	por parámetro (independientemente de los códigos de gelatinas).*/
void genera_sprites(char mat[][COLUMNS])
{
	int i, j;
	
	n_sprites = 0;
	
	SPR_ocultarSprites(128);								// ocultem tots els sprites
		
	for (i = 0; i < ROWS * COLUMNS; i++)
	{
		vect_elem[i].ii = -1;								// recorrem el vector per desactivar els elements (-1)
	}
	
	for (i = 0; i < ROWS * COLUMNS; i++)
	{
		SPR_fijarPrioridad(i, 1);							// 	inicialitzem els sprites amb prioritat 1		
	}
	
	
	for (i = 0; i < ROWS; i++)								// recorrem la matriu de joc 
	{
		for (j = 0; j < COLUMNS; j++)
		{
			if ((mat[i][j] >= 1 && mat[i][j] <= 6) || (mat[i][j] >= 9 && mat[i][j] <= 14) || (mat[i][j] >= 17 && mat[i][j] <= 22)) 
			{
				crea_elemento(mat[i][j] & 0x07, i, j);			// independetment de la gelatina, creem un element amb el codi elemental
				n_sprites++;								// actualitzem la variable global del nombre de sprites
			}
		}
	}
	
	swiWaitForVBlank();										// esperar per actualitzar la pantalla
	SPR_actualizarSprites(OAM, 128);							// actualitzem el control de atributs
}



// TAREA 2Bb
/* genera_mapa2(*mat): generar un mapa de baldosas como un tablero ajedrezado
	de metabaldosas de 32x32 píxeles (4x4 baldosas), en las posiciones de la
	matriz donde haya que visualizar elementos con o sin gelatina, bloques
	sólidos o espacios vacíos sin elementos, excluyendo solo los huecos.*/
void genera_mapa2(char mat[][COLUMNS])
{
	int i, j;
	// Bucle para recorrer la matriz 
	for (i = 0; i < ROWS; i++)
	{
		for (j = 0; j < COLUMNS; j++)
		{
			if (mat[i][j] == 15) // Si es un hueco vacio, lo ponemos transparente
			{
				fija_metabaldosa((u16 *) 0x06000800, i, j, 19);
			}
			else
			{
				if ((i+j)%2 == 0) // En los pares ponemos un color azul claro
				{
					fija_metabaldosa((u16 *) 0x06000800, i, j, 17);
				}
				else // En los impares ponemos un color azul oscuro
				{
					fija_metabaldosa((u16 *) 0x06000800, i, j, 18);
				}
			}
		}
	}
}



// TAREA 2Cb
/* genera_mapa1(*mat): generar un mapa de baldosas correspondiente a la
	representación de las casillas de la matriz que se pasa por parámetro,
	utilizando metabaldosas de 32x32 píxeles (4x4 baldosas), visualizando
	las gelatinas simples y dobles y los bloques sólidos con las metabaldosas
	correspondientes, (para las gelatinas, basta con utilizar la primera
	metabaldosa de la animación); además, hay que inicializar la matriz de
	control de la animación de las gelatinas mat_gel[][COLUMNS]. */
void genera_mapa1(char mat[][COLUMNS])
{
	int i,j;
	for (i=0; i<ROWS; i++)
	{
		for (j=0; j<COLUMNS; j++)
		{
			if (mat[i][j]==15 || (mat[i][j]!=7 && mat[i][j]<7)){ //ni bloque solido ni gelatina	
				fija_metabaldosa((u16 *) 0x06000000, i, j, 19);
			}
			if (mat[i][j]==7){ //bloque solido	
				fija_metabaldosa((u16 *) 0x06000000, i, j, 16);
			}
			if ((mat[i][j]>8 && mat[i][j]<15) || (mat[i][j]>16 && mat[i][j]<23)){ //gelatina	
				int random = 8;
				random = mod_random(random); //numero aleatorio entre 0-7
				if ((mat[i][j]>16 && mat[i][j]<23)){ //gelatina doble
				random = random+8;
				}
				fija_metabaldosa((u16 *) 0x06000000, i, j, random);
				int campo = 10; 
				campo = mod_random(campo)+1; //numero aleatorio entre 1-10
				mat_gel[i][j].ii=campo;
				mat_gel[i][j].im=random;
			}
			else mat_gel[i][j].ii=-1; //no gelatina
		}
	}
}



// TAREA 2Db
/* ajusta_imagen3(int ibg): rotar 90 grados a la derecha la imagen del fondo
	cuyo identificador se pasa por parámetro (fondo 3 del procesador gráfico
	principal), y desplazarla para que se visualice en vertical a partir del
	primer píxel de la pantalla. */
void ajusta_imagen3(int ibg)
{


}




// TAREAS 2Aa,2Ba,2Ca,2Da
/* init_grafA(): inicializaciones generales del procesador gráfico principal,
				reserva de bancos de memoria y carga de información gráfica,
				generando el fondo 3 y fijando la transparencia entre fondos.*/
void init_grafA()
{
	int bg1A, bg2A, bg3A;

	videoSetMode(MODE_3_2D | DISPLAY_SPR_1D_LAYOUT | DISPLAY_SPR_ACTIVE);
	
// Tarea 2Aa:
	// reservar banco F para sprites, a partir de 0x06400000
	vramSetBankF(VRAM_F_MAIN_SPRITE_0x06400000);
	
// Tareas 2Ba y 2Ca:
	// reservar banco E para fondos 1 y 2, a partir de 0x06000000
	vramSetBankE(VRAM_E_MAIN_BG);		// Inicializar vram en banco E para bg en 0x06000000

// Tarea 2Da:
	// reservar bancos A y B para fondo 3, a partir de 0x06020000




// Tarea 2Aa:
	// cargar las baldosas de la variable SpritesTiles[] a partir de la
	// dirección virtual de memoria gráfica para sprites, y cargar los colores
	// de paleta asociados contenidos en la variable SpritesPal[]
	dmaCopy(SpritesTiles, SPRITE_GFX, sizeof(SpritesTiles));		// carreguem la variable SpriteTiles en SPRITE_GFX = 0x06400000
	dmaCopy(SpritesPal, SPRITE_PALETTE, sizeof(SpritesPal)); 		// carreguem la variable SpritesPal en SPRITE_PALETTE = 0x05000200

// Tarea 2Ba:
	// inicializar el fondo 2 con prioridad 2
	bg2A = bgInit (2, BgType_Text8bpp, BgSize_T_256x256, 1, 1);			// Inicialitzar fondo 2 con texo 8bpp con tamaño 32x32 en el map 5 y tile 0
	bgSetPriority (bg2A, 2);											// Establecer prioridad 2



// Tarea 2Ca:
	//inicializar el fondo 1 con prioridad 0
	bg1A = bgInit(1, BgType_Text8bpp, BgSize_T_256x256, 0, 1); 			//Inicialitzar fondo 1 "text" (bg1) 8bpp 32x32
	bgSetPriority(bg1A, 0);	


// Tareas 2Ba y 2Ca:
	// descomprimir (y cargar) las baldosas de la variable BaldosasTiles[] a
	// partir de la dirección de memoria correspondiente a los gráficos de
	// las baldosas para los fondos 1 y 2, cargar los colores de paleta
	// correspondientes contenidos en la variable BaldosasPal[]
	
	// 0: direccion baldosas, 1: bgGETGfxPtr(fondo que queremos), 2: LZ77Vram
	decompress(BaldosasTiles, bgGetGfxPtr(bg2A), LZ77Vram);				// Descomprimir y cargar baldosas fondo 2
	decompress(BaldosasTiles, bgGetGfxPtr(bg1A), LZ77Vram);			//cargar baldosas
	// 0: direccion paleta, 1: direccion inicial paleta principal, 2: tamaño del parametro 0
	dmaCopy(BaldosasPal, BG_PALETTE, sizeof(BaldosasPal));				// Cargar colores de paleta
	


	
// Tarea 2Da:
	// inicializar el fondo 3 con prioridad 3


	// descomprimir (y cargar) la imagen de la variable FondoBitmap[] a partir
	// de la dirección virtual de vídeo reservada para dicha imagen



	// fijar display A en pantalla inferior (táctil)
	lcdMainOnBottom();

	/* transparencia fondos:
		//	bit 1 = 1 		-> 	BG1 1st target pixel
		//	bit 2 = 1 		-> 	BG2 1st target pixel
		//	bits 7..6 = 01	->	Alpha Blending
		//	bit 11 = 1		->	BG3 2nd target pixel
		//	bit 12 = 1		->	OBJ 2nd target pixel
	*/
	*((u16 *) 0x04000050) = 0x1846;	// 0001100001000110
	/* factor de "blending" (mezcla):
		//	bits  4..0 = 01001	-> EVA coefficient (1st target)
		//	bits 12..8 = 00111	-> EVB coefficient (2nd target)
	*/
	*((u16 *) 0x04000052) = 0x0709;
}

