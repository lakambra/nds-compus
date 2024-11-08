/*-----------------------------------------------------------------------
|   Description: MasterMind game for NDS (text version)
|------------------------------------------------------------------------
|	Author: Santiago Romani (DEIM, URV)
|	Date:   Oct/2020 
| -----------------------------------------------------------------------*/

#include <nds.h>		// headers of libnds functions:
						//		swiWaitForVBlank(), scanKeys(), etc.)
#include <stdio.h>		// headers of libc input/output functions: printf()
#include <stdlib.h>		// headers of libc random functions: rand()

#include "mastermind.h"	// project definitions and function prototypes


int main(void)
{
	char secret[8];							// vector for secret sequence
	char guessed[8];						// vector for guessed sequence
	unsigned short lenght = INI_LENGHT;		// lenght of sequences
	unsigned short num_sym = INI_NUMSYM;	// number of symbols
	unsigned short max_trials = INI_TRIALS;	// maximum number of trials
	unsigned short num_trial;				// current number of trials
	unsigned short rb, rw;					// obtained results (black, white)
	unsigned short nwins = 0, nloses = 0;	// counters of wins and loses
	unsigned short i;						// loop index
	
	initial_config(&lenght, &num_sym, &max_trials);
	do
	{
		for (i = 0; i < lenght; i++)	// create the secret sequence
		{								// and the initial guessed sequence
			secret[i] = BASE_CHAR + (rand() % num_sym);	
			guessed[i] = BASE_CHAR;
		}
		secret[i] = 0; guessed[i] = 0;	// add end_of_string marks
		
		printf("\x1b[2J");				// clear screen
		printf("\x1b[35mTrial\t\x1b[36mGuess");
		printf("\x1b[0;%dH\x1b[30m%c\t\x1b[39m%c", BLACK_COL, 'B', 'W');
		
		num_trial = 0;
		do
		{	sel_guess(num_trial, max_trials, guessed, lenght, num_sym);
			rb = MM_check(secret, guessed, lenght, &rw);
			printf("\x1b[%d;%dH\x1b[30m%d\t\x1b[39m%d", (num_trial+1),
														BLACK_COL, rb, rw);
			num_trial++;
		} while ((rb < lenght) && (num_trial < max_trials));
		
		if (rb == lenght)		// all symbols matched in position
		{	nwins++;
			printf("\n\nYou WIN! (wins:%d, loses:%d)", nwins, nloses);
		}
		else					// run out of trials 
		{	nloses++;
			printf("\n\nYou LOSE! (wins:%d, loses:%d)", nwins, nloses);
			printf("\nSecret code was: %s", secret);
		}
		
		printf("\n\nAnother try? (A: yes, B: no)");
		do
		{	swiWaitForVBlank();
			scanKeys();
		} while (!(keysDown() & (KEY_A | KEY_B)));
	} while (keysDown() & KEY_A);
	
	printf("\n\nEnd of program.");
	while (1) swiWaitForVBlank();		// endless loop
	return(0);							// never returns, actually
}
