/*------------------------------------------------------------------------------

	$Id: practgraf_5.c, 2017-08-18 Santiago Romani $

	Programa de pr�cticas para probar la carga y visualizaci�n de dos fondos
	gr�ficos, uno como bitmap y el otro como mapa de baldosas superpuesto al
	bitmap, a escoger entre tres posibles mapas.
	
------------------------------------------------------------------------------*/
#include <nds.h>		// decl. funciones libnds (videoSetMode, bgInit, etc.)
#include <stdio.h>		// decl. funciones de entrada/salida est�ndar (printf)
#include <time.h>		// decl. funciones de tiempo (time)
#include <soil.h>		// declaraciones gr�ficas imagen bitmap
#include <laberintos.h>	// declaraciones gr�ficas mapas de baldosas
#include <antwalk.h>	// declaraciones gr�ficas sprites
#include <text.h>		// declaraciones gr�ficas fuente de letras
#include <soilmini.h>	// declaraciones gr�ficas imagen reducida del suelo
						// (bitmap 16bpp)
#include <movimiento.h>	// declaraci�n funciones de movimiento de sprites


/* variables globales */
int bg2A, bg3A;			// identificadores fondos del procesador gr�fico A
int lab_actual = 1;		// identificador del laberinto actual
						// vector con direcciones de los mapas de baldosas
void * const dirLabs[] = {  (void *) laberinto1Map, 	// comprimidos (en mem.
							(void *) laberinto2Map,		// principal)
							(void *) laberinto3Map};

PrintConsole *console;	// definici�n de datos para gestionar la salida de texto
						// (con printf) sobre el proc. gr�fico secundario; tiene
						// que ser global para que persista durante toda la
						// ejecuci�n del programa

/* funci�n de inicializaci�n del procesador gr�fico principal (A) */
void initGraficosA(void)
{
	int i;
	u8 *baseTiles;
	
	// inicializar el modo del procesador gr�fico principal
	videoSetMode(MODE_5_2D | DISPLAY_SPR_1D_LAYOUT | DISPLAY_SPR_ACTIVE);
	
	// asignar los bancos de memoria gr�fica A y B para albergar la informaci�n
	vramSetBankA(VRAM_A_MAIN_BG_0x06000000);			// de fondos
	vramSetBankB(VRAM_B_MAIN_BG_0x06020000);
	
	// asigna el banco F para albergar la informaci�n gr�fica de los sprites
	vramSetBankF(??_o_??);

	// inicializar fondos 2 para gestionar mapa de baldosas
	bg2A = bgInit(2, BgType_ExRotation, BgSize_ER_512x512, 1, 0);
	// inicializar fondos 3 para gestionar el bitmap
	bg3A = bgInit(3, BgType_Bmp8, BgSize_B8_512x512, 1, 0);

	baseBGmap2_main = bgGetMapPtr(bg2A); // memoriza direcci�n base mapa fondo 2
	
	// copiar la paleta de colores del fondo bitmapt en la memoria de paletas
	dmaCopy(soilPal, BG_PALETTE, sizeof(soilPal));
	
	// a�adir los colores adicionales para las baldosas
	*(BG_PALETTE + 241) = 0x7C1F;		// magenta (obst�culo)
	*(BG_PALETTE + 242) = 0x03FF;		// amarillo (comida)
	*(BG_PALETTE + 243) = 0x27E0;		// verde (nido)

	baseTiles = (u8 *) laberintosSharedTiles;
	// transformar �ndices de baldosas de [1..3] a [241..243] para todos los
	for (i = 0; i < laberintosSharedTilesLen; i++)		// p�xeles de baldosas
	{
		if (baseTiles[i] > 0)		// si �ndice de color superior a 0 (color
			baseTiles[i] += 240;		// transparente), a�adir desplazamiento
	}

	// copiar los p�xeles de las baldosas en la memoria gr�fica
	dmaCopy(laberintosSharedTiles, bgGetGfxPtr(bg2A),
												sizeof(laberintosSharedTiles));

	// descomprimir el mapa de baldosas del primer laberinto sobre la memoria
	decompress(laberinto1Map, baseBGmap2_main, LZ77Vram); 			// gr�fica
	
	// descomprimir el bitmap sobre la memoria gr�fica
	decompress(soilBitmap, bgGetGfxPtr(bg3A), LZ77Vram);

	// copiar la paleta de colores de los sprites en la memoria de paletas
	dmaCopy(antwalkPal, (void *) ??_p_??, sizeof(antwalkPal));
	
	// copiar los p�xeles de las baldosas de los sprites en la memoria gr�fica
	decompress(antwalkTiles, (void *) ??_q_??, LZ77Vram);
}


/* funci�n de inicializaci�n del procesador gr�fico secundario (B) */
void initGraficosB(void)
{	
	int bg2B, bg3B;	// identificadores de n�mero fondo
	
	// inicializar procesador gr�fico secundario para escribir con printf()
	videoSetModeSub(MODE_5_2D);
	vramSetBankC(VRAM_C_SUB_BG_0x06200000);

	// inicializar fondos 2 para representar matrices de marcas
	bg2B = bgInitSub(2, BgType_Bmp16, BgSize_B16_128x128, 1, 0);
	// inicializar fondos 3 para gestionar el bitmap
	bg3B = bgInitSub(3, BgType_Bmp16, BgSize_B16_128x128, 3, 0);
	
	baseBitmap2_sub = bgGetGfxPtr(bg2B); 	// memoriza dir. base bitmap fondo 2
	
	// descomprimir el bitmap sobre la memoria gr�fica
	decompress(soilminiBitmap, bgGetGfxPtr(bg3B), LZ77Vram);
	
	// desplazar fondos 2 y 3 a la esquina inferior derecha
	bgSetScroll(bg2B, -127, -95);
	bgSetScroll(bg3B, -127, -95);
	bgUpdate();
	
	//inicializar el fondo 0 como fondo de texto
	console = consoleInit(0, 0, BgType_Text8bpp, BgSize_T_256x256, 3, 0,
																false, false);

	ConsoleFont font;
	font.gfx = (u16*) textTiles;
	font.pal = (u16*) textPal;
	font.numChars = 95;
	font.numColors =  textPalLen / 2;
	font.bpp = 8;
	font.asciiOffset = 32;
	font.convertSingleColor = false;

	consoleSetFont(console, &font);

	printf("Practica Graficos 5:\n\tcargar bitmap + mapa bald.");
	printf("\n\t+ sprites (con baldosas)");
	printf("\x1b[4;0H (A) lab_actual = %d", lab_actual);
	printf("\x1b[5;0H (B) limite_mov = %d", limite_mov);
	printf("\x1b[6;0H (X) spr_zoom = %d", spr_zoom);
	printf("\x1b[7;0H (dir) dx = 0 , dy = 0\n");
	printf("\x1b[8;0H hormigas = 0"); 
	printf("\x1b[9;0H comida = 0");
}


int main(void)
{
	int keys = 0;				// estado de los botones
	int dx = 0, dy = 0;			// desplazamiento actual de fondos
	int update_desp = 0;
	int scale = 1 << 8;			// escala 1.0 en formato de coma fija 0.20.8
	
	spr_zoom = scale >> 7;		// zoom sprites = zoom fondos * 2
	coord_despx = 0;
	coord_despy = 0;			// coordenadas desplazamiento del terreno
		
	initGraficosA();			// inicializar gr�ficos
	initGraficosB();
		
	srand((unsigned) time(NULL));	// inicializar semilla de n�meros aleatorios
		
	buscar_nido();				// determinar posici�n inicial del nido
	inicializar_movimiento();
	inicializar_marcas(1);
		
	do				/* bucle principal del programa */
	{
		scanKeys();
		keys = keysHeld();		// capturar botones pulsados
			
		/* procesado de cambio de laberinto */
		if (keys & KEY_A)
		{
			lab_actual++;				// actualizar laberinto actual
			if (lab_actual > 3) lab_actual = 1;
			printf("\x1b[4;0H (A) lab_actual = %d", lab_actual);
						// decomprimir las posiciones del nuevo mapa actual
			decompress(dirLabs[lab_actual-1], (void *) baseBGmap2_main,
																	  LZ77Vram);
						// determinar posici�n inicial del nido
			buscar_nido();
			inicializar_marcas(0);
			cont_comida = 0;
			printf("\x1b[9;0H comida = 0     ");
		}
			
		/* procesado de cambio de velocidad */
		if (keys & KEY_B)
		{
			limite_mov >>= 1;			// aumentar velocidad por 2
			if (limite_mov == 0) limite_mov = 4;
			printf("\x1b[5;0H (B) limite_mov = %d", limite_mov);
		}
			
		/* procesado de desplazamiento del terreno */
		if (spr_zoom < 4)		// (si no estamos viendo todo el terreno)
		{
			if ((keys & KEY_UP) && (dy > 0))
			{	dy--; update_desp = 1; }
			if ((keys & KEY_DOWN) && (dy < (5 - 2*spr_zoom)))
			{	dy++; update_desp = 1; }
					// l�mite superior dy o dx = (5 - 2*spr_zoom)
					// si spr_zoom = 2 -> despl. max = 1
					// si spr_zoom = 1 -> despl. max = 3
			if ((keys & KEY_LEFT) && (dx > 0))
			{	dx--; update_desp = 1; }
			if ((keys & KEY_RIGHT) && (dx < (5 - 2*spr_zoom)))
			{	dx++; update_desp = 1; }
		}
		
		/* procesado de zoom */
		if (keys & KEY_X)
		{
			scale <<= 1;				// actualizar factor de escala (*2)
			if (scale > (1<<9)) scale >>= 3; // 0.5 -> 1 -> 2 -> 0.5 -> ...
			bgSetScale(bg2A, scale, scale);
			bgSetScale(bg3A, scale, scale);
			spr_zoom = scale >> 7;		// zoom sprites = zoom fondos * 2
			transferir_rotesc();
			printf("\x1b[6;0H (X) spr_zoom = %d", spr_zoom);
			if (dx >= (5 - 2*spr_zoom))
			{ dx /= 2; update_desp = 1; }	// reajustar despl. m�ximo
			if (dy >= (5 - 2*spr_zoom))
			{ dy /= 2; update_desp = 1; }
			bgUpdate();
		}
		
		/* actualizar coordenadas de inicio de terreno */
		if (update_desp)
		{
			update_desp = 0;
				// spr_zoom = 4 -> coord_despx = 0, coord_despy = 0
				// spr_zoom = 2 -> coord_desp = despl * dim_real * 1
				// spr_zoom = 1 -> coord_desp = despl * dim_real * 2
				// despl = dx o dy; dim_real = 256 o 192
			coord_despx = dx * 256 * spr_zoom / 2;
			coord_despy = dy * 192 * spr_zoom / 2;
			// llamar a funci�n libnds para desplazar fondos
			bgSetScroll(bg2A, coord_despx, coord_despy);
			bgSetScroll(bg3A, coord_despx, coord_despy);
			printf("\x1b[7;0H (dir) dx = %d , dy = %d", dx, dy);
			bgUpdate();
		}
			
		mover_sprites();
		swiWaitForVBlank();		// sincronizaci�n con la visualizaci�n
		reducir_marcas();
		actualizar_sprites();
		
			// detecci�n de pulsaci�n de alg�n interruptor de cambio de estado
		if (keys & (KEY_A | KEY_B | KEY_UP | KEY_DOWN | KEY_RIGHT | KEY_LEFT
																	   | KEY_X))
			do
			{
				mover_sprites();			// continuar el movimiento de los
				swiWaitForVBlank();			// objetos del programa
				reducir_marcas();
				actualizar_sprites();
				scanKeys();					// esperar a que se suelten los
				keys = keysHeld();			// interruptores
			} while (keys & (KEY_A | KEY_B | KEY_UP | KEY_DOWN | KEY_RIGHT
														   | KEY_LEFT | KEY_X));
	} while (1);
	return 0;
}

(1);
	return 0;
}

