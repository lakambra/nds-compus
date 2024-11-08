/*---------------------------------------------------------------------------------

	$Id: practgraf_4.c, 2017-08-05 Santiago Romani $

	Programa de prácticas para probar la carga y visualización de dos fondos gráficos,
	uno como bitmap y el otro como mapa de baldosas superpuesto al bitmap, a escoger
	entre tres posibles mapas.
	
---------------------------------------------------------------------------------*/
#include <nds.h>		// declaración funciones de libnds (videoSetMode, bgInit, etc.)
#include <stdio.h>		// declaración funciones de entrada/salida estándar (printf)
#include <soil.h>		// declaraciones gráficas imagen bitmap
#include <laberintos.h>	// declaraciones gráficas mapas de baldosas

/* variables globales */
int bg2A, bg3A;			// identificadores fondos del procesador gráfico A (principal)
int lab_actual = 1;		// identificador del laberinto actual
	// vector con direcciones de los mapas de baldosas comprimidos (en mem. principal)
void * dirLabs[] = {(void *) laberinto1Map, (void *) laberinto2Map, (void *) laberinto3Map};


/* función de inicialización del procesador gráfico principal (A) */
void initGraficosA(void)
{
	int i;
	u8 *baseTiles;
	
	// inicializar el modo del procesador gráfico principal
	videoSetMode(MODE_5_2D);
	
	// asignar los bancos de memoria gráfica A y B para albergar la información de fondos
	vramSetBankA(??_i_??);
	vramSetBankB(??_j_??);
	
	// inicializar fondo 2 para gestionar el mapa de baldosas
	bg2A = bgInit(2, BgType_ExRotation, BgSize_ER_512x512, 1, 0);
	// inicializar fondo 3 para gestionar el bitmap
	bg3A = bgInit(3, BgType_Bmp8, BgSize_B8_512x512, ??_k_??, 0);
	
	// copiar la paleta de colores del fondo bitmapt en la memoria de paletas
	dmaCopy(soilPal, BG_PALETTE, sizeof(soilPal));
	
	// añadir los colores adicionales para las baldosas
	*(BG_PALETTE + 241) = 0x7C1F;		// magenta (obstáculo)
	*(BG_PALETTE + 242) = 0x03FF;		// amarillo (comida)
	*(BG_PALETTE + 243) = 0x27E0;		// verde (nido)

	baseTiles = (u8 *) laberintosSharedTiles;
	// transformar índices de baldosas de [1..3] a [241..243]
	for (i = 0; i < laberintosSharedTilesLen; i++)		// para todos los píxeles de baldosas
	{
		if (baseTiles[i] > 0)		// si índice de color superior a 0 (color transparente)
			baseTiles[i] += 240;		// añadir desplazamiento
	}

	// copiar los píxeles de las baldosas en la memoria gráfica
	dmaCopy(laberintosSharedTiles, (void *) 0x06000000, sizeof(laberintosSharedTiles));

	// descomprimir el mapa de baldosas del primer laberinto sobre la memoria gráfica
	decompress(laberinto1Map, (void *) 0x06000800, LZ77Vram);
	
	// descomprimir el bitmap sobre la memoria gráfica
	decompress(soilBitmap, (void *) ??_l_??, LZ77Vram);
}


/* función de inicialización del procesador gráfico secundario (B) */
void initGraficosB(void)
{
	// inicializar procesador gráfico secundario para escribir con printf()
	consoleDemoInit();

	printf("Practica Graficos 4:\n\tcargar bitmap + mapa bald.");
	printf("\x1b[5;1HLab. actual: %d", lab_actual);
	printf("\x1b[7;1HScroll: sx = 0  sy = 0");
	printf("\x1b[9;1HEscalado: escala = 0100");
}


int main(void)
{
	int keys = 0;				// estado de los botones
	int sx = 0, sy = 0;			// desplazamiento actual de fondos
	int scale = 1 << 8;			// escala actual de fondos (1.0 en formato de coma fija 0.20.8)
		
	initGraficosA();
	initGraficosB();
		
	do				/* bucle principal del programa */
	{
		scanKeys();
		keys = keysHeld();		// capturar botones pulsados
			
		/* procesado de scroll */
		if (keys & KEY_UP) sy--;
		if (keys & KEY_DOWN) sy++;
		if (keys & KEY_LEFT) sx--;
		if (keys & KEY_RIGHT) sx++;
		if (keys & (KEY_UP | KEY_DOWN | KEY_LEFT | KEY_RIGHT))
		{
			// llamar a una función libnds para desplazar los fondos 2 y 3
			// ??_h_??
			printf("\x1b[7;1HScroll: sx = %d  sy = %d   ", sx, sy);
			bgUpdate();
		}
		
		/* procesado de cambio de laberinto */
		if (keys & KEY_A)
		{
			lab_actual++;				// actualizar laberinto actual
			if (lab_actual > 3) lab_actual = 1;
			printf("\x1b[5;1HLab. actual: %d", lab_actual);
			// decomprimir las posiciones del nuevo mapa actual
			// ??_m_??
		}
		
		/* procesado de zoom */
		if (keys & KEY_B)
		{
			scale <<= 1;				// actualizar factor de escala (*2)
			if (scale > (1<<9)) scale >>= 3;
			// actualizar el factor de escalado de los fondos 2 y 3
			// ??_n_??
			printf("\x1b[9;1HEscalado: escala = %04X", scale);
			bgUpdate();
		}
		
		/* esperar a que se suelten los botones A y B */
 		while (keys & (KEY_A | KEY_B))
		{
			swiWaitForVBlank();
			scanKeys();
			keys = keysHeld();
		}
		swiWaitForVBlank();		// sincronización con la visualización
								// (relajar uso del procesador)
	} while (1);
	return 0;
}

}

dor)
	} while (1);
	return 0;
}

