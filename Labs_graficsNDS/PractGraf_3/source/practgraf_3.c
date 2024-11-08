/*---------------------------------------------------------------------------------

	$Id: practgraf_3.c, 2017-07-31 Santiago Romani $

	Programa de pr�cticas para probar la carga y visualizaci�n de un fondo gr�fico
	compuesto por baldosas, dise�ado con Tiled y convertido en variables globales
	con Grit.
	
---------------------------------------------------------------------------------*/
#include <nds.h>		// declaraci�n funciones de libnds (videoSetMode, bgInit, etc.)
#include <stdio.h>		// declaraci�n funciones de entrada/salida est�ndar (printf)
#include <prueba1.h>	// declaraci�n variables globales con contenido gr�fico

/* variables globales */
int bg2A;				// identificador fondo 2 del procesador gr�fico A (principal)

/* funci�n de inicializaci�n del procesador gr�fico principal (A) */
void initGraficosA(void)
{
	// inicializar el modo del procesador gr�fico principal
	videoSetMode(??_a_??);
	
	// asignar el banco de memoria gr�fica D para albergar la informaci�n de fondos
	vramSetBankD(??_b_??);
	
	// inicializar el fondo 2
	bg2A = bgInit(2, BgType_ExRotation, BgSize_ER_512x512, ??_c_??, ??_d_??);
	
	// copiar la paleta de colores en la memoria de paleta
	dmaCopy(prueba1Pal, (void *) ??_e_??, sizeof(prueba1Pal));

	// copiar los p�xeles de las baldosas en la memoria gr�fica
	dmaCopy(prueba1Tiles, (void *) ??_f_??, sizeof(prueba1Tiles));

	//copiar el mapa de baldosas en la memoria gr�fica
	dmaCopy(prueba1Map, (void *) ??_g_??, sizeof(prueba1Map));
}


/* funci�n de inicializaci�n del procesador gr�fico secundario (B) */
void initGraficosB(void)
{
	// inicializar procesador gr�fico secundario para escribir con printf()
	consoleDemoInit();

	printf("Practica Graficos 3:\n\tcargar un fondo de baldosas.");
	printf("\x1b[7;1HScroll: sx = 0  sy = 0");
}


int main(void)
{
	int keys = 0;				// estado de los botones
	int sx = 0, sy = 0;			// desplazamiento actual del fondo 2
		
	initGraficosA();
	initGraficosB();
		
	do				/* bucle principal del programa */
	{
		scanKeys();
		keys = keysHeld();		// capturar botones pulsados
			
		/* procesado de scroll del fondo 2 */
		if (keys & KEY_UP) sy--;
		if (keys & KEY_DOWN) sy++;
		if (keys & KEY_LEFT) sx--;
		if (keys & KEY_RIGHT) sx++;
		if (keys & (KEY_UP | KEY_DOWN | KEY_LEFT | KEY_RIGHT))
		{
			// llamar a una funci�n libnds para desplazar el fondo 2
			// ??_h_?? 
			printf("\x1b[7;1HScroll: sx = %d  sy = %d   ", sx, sy);
			bgUpdate();
		}
		swiWaitForVBlank();		// sincronizaci�n con la visualizaci�n
								// (relajar uso del procesador)
	} while (1);
	return 0;
}

