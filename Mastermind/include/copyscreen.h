/*--------------------------------------------------------------------
|   Prototypes of two routines for copying screens A to B or B to A
|	(available in libcompus.a)
| --------------------------------------------------------------------*/

#ifndef COPYSCREEN_H
#define COPYSCREEN_H

/* copy_screenA2B():	copies the content of screen A into screen B, assuming
		only background 0 is activated and in the shape of 32x32 8bpp tiles.				
*/
extern void copy_screenA2B();

/* copy_screenB2A():	copies the content of screen B into screen A, assuming
		only background 0 is activated and in the shape of 32x32 4bpp tiles.				
*/
extern void copy_screenB2A();

#endif /* COPYSCREEN_H */
