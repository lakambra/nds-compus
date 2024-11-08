/*--------------------------------------------------------------------------
|   Definitions and prototypes of global functions and routines for the
|	MasterMind project
| --------------------------------------------------------------------------*/

#ifndef MASTERMIND_H
#define MASTERMIND_H

#define MAX_LENGHT	7	// definition of constans for limiting
#define MIN_LENGHT	3	// the configuration parameters
#define INI_LENGHT	5
#define MAX_NUMSYM	10
#define MIN_NUMSYM	2
#define INI_NUMSYM	6
#define MAX_TRIALS	16
#define MIN_TRIALS	8
#define INI_TRIALS	12

#define BLACK_COL	15	// screen column for showing the black count
#define GUESS_COL	6	// screen column for showing the guessed sequence
#define BASE_CHAR	65	// first symbol character: 65 -> 'A'


/* Global C-language functions contained in mm_suport.c */
extern void initial_config(unsigned short *l, unsigned short *n,
															unsigned short *m);
extern void sel_guess(unsigned short t, unsigned short max_t, char *seq,
										unsigned short len, unsigned short ns);


/* Global ARM assembly routine contained in mm_check.s */

/* MM_check():  given a secret sequence and a guessed sequence of n positions,
				where each position can hold any of m symbols,
				returns (by value) the number of "black" matches and also
				returns (by reference) the number of "white" matches.
				The "black" result indicates matches in the same position
				within the sequence, whereas the "white" result indicates
				matches in different position; black matches are counted
				first, so those coincident simbols will not be taken into
				account in the counting of the white matches.
				For example, given the following input:
					secret	= "CADHD"
					guessed	= "AACCD"
				the output will be:
					black = 2  , due to 'A' in second pos. and 'D' in last pos.
					white = 1  , due to 'C' in third pos. in guessed sequence,
									(but in first pos. in secret sequence)
				Note that the 'A' in first pos. in guessed seq. will NOT count
				as white with respect the 'A' in second pos. of secret sequence,
				because it has already been used as a black match.
				Besides, the 'D' in third pos. in secret seq. will NEITHER count
				as white with respect to the 'D' in last pos. of guessed seq.,
				because it has also been used in a black match.
				Finally, the 'C' in first pos. of secret seq. will NOT be used
				to count as two whites with respect the two 'C's in the guessed
				seq., since each match can only be counted once in the overall
				match count, i.e., blacks + whites allways will be less or equal
				to the lenght of the sequences.
*/
extern unsigned short MM_check(char secret[], char guessed[],
								unsigned short lenght, unsigned short *whites);

#endif /* MASTERMIND_H */
