/*---------------------------------------------------------------------------
|   Support C-language functions for the MasterMind project (text version)
|----------------------------------------------------------------------------
|	Author: Santiago Romani (DEIM, URV)
|	Date:   Oct/2020 
| ---------------------------------------------------------------------------*/

#include <nds.h>		// headers of libnds9 functions: consoleDemoInit(),
						//		swiWaitForVBlank(), scanKeys(), etc.
#include <stdio.h>		// headers of libc input/output functions: printf()
#include <stdlib.h>		// headers of libc random functions: srand()
#include <string.h>		// headers of libc string functions: strlen()
#include <time.h>		// headers of libc time functions: time()

#include "mastermind.h"	// project definitions and function prototypes
#include "copyscreen.h"	// headers of libcompus functions: copy_screenB2A()


/* sel_value(): given an asking message, a row number (first screen row is 0),
				maximum and minimum values, an ANSI color code and the address
				of the involved variable to change (preloaded with a value
				between min and max), this function allows the user to change
				the value with the UP and DOWN buttons, and make the selection
				with the SELECT button.
*/
void sel_value(char *message, unsigned short row, unsigned short color,
					unsigned short max, unsigned short min,
					unsigned short *current)
{
	unsigned char update;			// boolean for updating value
	unsigned short column = strlen(message) + 1;
	
	printf("\x1b[%d;%dH%s", row, 0, message);
	printf("\x1b[%d;%dH\x1b[%dm%2d\x1b[39m", row, column, color, *current);
	do								// process UP / DOWN buttons
	{	update = 0;					// assume there is no press
		swiWaitForVBlank();			// release the ARM9 for 1/60 of second
		scanKeys();
		if ((keysDown() & KEY_UP) && (*current < max))
		{
			(*current)++;			// update content of the referenced variable
			update = 1;				// mark for updating the screen
		}
		if ((keysDown() & KEY_DOWN) && (*current > min))
		{
			(*current)--;
			update = 1;
		}
		if (update)					// update the screen 
			printf("\x1b[%d;%dH\x1b[%dm%2d\x1b[39m", row, column, color,
																	*current);
	} while (!(keysDown() & KEY_SELECT));
}


/* initial_config() initializes the B screen for printf() usage and ask the
				the user for the configuration values of lenght (l) of the
				sequences, number of symbols (n) and number of trials (m);
				all these parameters must be passed by reference (pointers).
				Before returning, this function also copies the content of
				screen B into screen A and randomizes the seed value for the
				generation of next random values.
*/
void initial_config(unsigned short *pl, unsigned short *pn, unsigned short *pm)
{
	unsigned short i;
	
	consoleDemoInit();	// initialize graphics processor B for printfs (bottom)

	for (i = 0; i < 32; i++)				// creates a multicolored box of '*'
		printf("\x1b[%dm*", (41 + (i % 6)));
	for (i = 1; i <= 5; i++)
		printf("\x1b[%dm*                              *",(41 + ((i+2) % 6)));
	for (i = 0; i < 32; i++)
		printf("\x1b[%dm*", (41 + ((i+2) % 6)));
	printf("\x1b[2;11H\x1b[39mMaster Mind");
	printf("\x1b[4;10H(DEIM - URV)");
	printf("\x1b[7;0HUse UP / DOWN to change values,\n");
	printf(" SELECT to accept the value:\n\n");
	
	sel_value("  Number of positions?", 10, 43, MAX_LENGHT, MIN_LENGHT, pl);
	sel_value("  Number of symbols?", 12, 45, MAX_NUMSYM, MIN_NUMSYM, pn);
	sel_value("  Maximum trials?", 14, 46, MAX_TRIALS, MIN_TRIALS, pm);

	printf("\n\n\nTo make your guess, use:\n");
	printf("LEFT / RIGHT to change position,");
	printf("UP / DOWN to change any symbol,\n");
	printf("SELECT to try it.\n\n\n");
	printf("Press START to go for the game.");
	do
	{	swiWaitForVBlank();
		scanKeys();				// KEY_Y is a trick for avoiding randomization
	} while (!(keysDown() & (KEY_START | KEY_Y)));
	printf("\x1b[23;0H                               ");
	
	copy_screenB2A();		// show configuration in A screen (top)
	
	setBackdropColorSub(RGB15(20, 20, 20));		// set gray background in B
	if (keysDown() & KEY_START)		// in case of KEY_START, randomize the
		srand(time(NULL));				// random seed with current real time
}


/* ANSI_color():	returns a code for setting the symbol color according to
				libnds implementation of SGR color codes */
unsigned short ANSI_color(char symbol)
{
	unsigned short result = 39;		// default white color
	unsigned char sym_ind = symbol - BASE_CHAR;
	
	if ((sym_ind >= 0) && (sym_ind < 6))	// for first six indexes,
		result = 41 + sym_ind;					// 6 bright colors [41..46]
	else if ((sym_ind >= 6) && (sym_ind < 12))	// for second six indexes,
			result = 31 + sym_ind - 6;				// 6 dark colors [31..36]
	return(result);
}


/* sel_guess(): given a number of trial, the maximum number of trials,
				the start address of a sequence, its maximum lenght and
				the maximum number of symbols, allows the user to change the
				symbol in the current position with UP and DOWN buttons,
				change the position with LEFT and RIGHT buttons, and enter
				the guessed sequence with the SELECT button.
*/
void sel_guess(unsigned short t, unsigned short max_t, char *seq,
										unsigned short len, unsigned short ns)
{
	unsigned short pos = 0, new_pos;
	unsigned char current_symbol;
	unsigned char update;		// =1 -> update symbol, =2 -> update pos.
	unsigned short i;
	
	printf("\x1b[%d;%dH\x1b[35m%2d", (t+1), 0, (t+1));	// print trial number,
	if ((max_t - t) <= 3)		// warn the last 3 trials
		for (i = 0; i <= (3 - (max_t - t)); i++)
			printf("!");		// "!", "!!", "!!!" for the last three trials
	for (i = 0; i < len; i++)	// print initial guess as colored chars
		printf("\x1b[%d;%dH\x1b[%dm%c", (t+1), (GUESS_COL+i),
													ANSI_color(seq[i]), seq[i]);	
	printf("\x1b[%d;%dH\x1b[39m^", (t+2), GUESS_COL);	// print pos. pointer
	current_symbol = seq[0];							// grab initial symbol
	do
	{	update = 0;
		swiWaitForVBlank();		// release ARM9 for 1/60 of second
		scanKeys();				// capture buttons
		if ((keysDown() & KEY_UP) && (current_symbol < (BASE_CHAR + ns - 1)))
		{
			current_symbol++;
			update = 1;
		}
		if ((keysDown() & KEY_DOWN) && (current_symbol > BASE_CHAR))
		{
			current_symbol--;
			update = 1;
		}
		if ((keysDown() & KEY_RIGHT) && (pos < len-1))
		{
			new_pos = pos + 1;
			update = 2;
		}
		if ((keysDown() & KEY_LEFT) && (pos > 0))
		{
			new_pos = pos - 1;
			update = 2;
		}
		if (update == 1)
			printf("\x1b[%d;%dH\x1b[%dm%c", (t+1), (GUESS_COL+pos),
								ANSI_color(current_symbol), current_symbol);
		else if (update == 2)
		{
			printf("\x1b[%d;%dH ", (t+2), (GUESS_COL+pos));
			seq[pos] = current_symbol;			// update referenced vector
			pos = new_pos;						// update current position
			printf("\x1b[%d;%dH\x1b[39m^", (t+2), (GUESS_COL+pos));
			current_symbol = seq[pos];			// load symbol in new pos.
		}	
	} while (!(keysDown() & KEY_SELECT));
	seq[pos] = current_symbol;					// ensure last symbol change
	printf("\x1b[%d;%dH\x1b[39m ", (t+2), (GUESS_COL+pos));	// erase last mark
}
