/*------------------------------------------------------------------------------

	$Id: func_sprites.h $

	Declaraciones de funciones globales de 'func_sprites.s'

------------------------------------------------------------------------------*/

extern void SPR_actualizarSprites(u16* base, int lim_spr, int act_grp);
extern void SPR_crearSprite(int indice, int forma, int tam, int baldosa);
extern void SPR_mostrarSprite(int indice);
extern void SPR_ocultarSprite(int indice);
extern void SPR_ocultarSprites(int limite);
extern void SPR_moverSprite(int indice, int px, int py);
extern void SPR_fijarBaldosa(int indice, int id_baldosa);
extern void SPR_fijarPrioridad(int indice, int prioridad);
extern void SPR_activarRotacionEscalado(int indice, int grupo, int doblado);
extern void SPR_desactivarRotacionEscalado(int indice);
extern void SPR_fijarRotacionEscalado(int igrp, int pb_pa, int pd_pc);
