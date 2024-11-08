/*------------------------------------------------------------------------------

	$Id: movimiento.h 2017-08-09 Santiago Romani $

	declaración de funciones externas del módulo "movimiento.c"

------------------------------------------------------------------------------*/

extern short limite_mov;
extern short spr_zoom;
extern short coord_despx;
extern short coord_despy;
extern int cont_comida;
extern u16 *baseBGmap2_main;
extern u16 *baseBitmap2_sub;

extern void buscar_nido();
extern void inicializar_marcas(int reset);
extern void transferir_rotesc();
extern void inicializar_movimiento();
extern void mover_sprites();
extern void reducir_marcas();
extern void actualizar_sprites();
