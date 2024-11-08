@; mastermind.s:  defines the MM_check() routine, wich performs the core check
@;				of the MasterMind game, where one player must discover a secret
@;				sequence of symbols by suggesting a guessed sequece and
@;				receiving two counts, the count of exact matches (same symbol in
@;				same position) and non-exact matches (same symbol in different
@;				position).

.text
	.align 2
	.arm

@; unsigned short MM_check(char secret[], char guessed[],
@;							unsigned short lenght, unsigned short *whites);
@;	Parameters:
@;		secret	-> R0 : address of a vector keeping the secret sequence
@;		guessed	-> R1 : address of a vector keeping the guessed sequence
@;		lenght	-> R2 : lenght of the sequences
@;		whites	-> R3 : address of a variable that will keep number of whites
@;	Result:
@;		R0 -> number of blacks
	.global MM_check
MM_check:
		push {r4-r5, lr}			@; save modified regs and return address
		
		mov r4, r0					@; save reference of secret seq. into R4
		bl check_blacks
		mov r5, r0					@; save num. of blacks into R5
		
		mov r0, r4					@; restore secret ref. into R0
		bl check_whites
		
		str r0, [r3]				@; return num. of whites by reference
		mov r0, r5					@; return num. of blacks by value
		
		pop {r4-r5, pc}



@; unsigned short check_blacks(char secret[], char guessed[],
@;												unsigned short lenght);
@;	Parameters:
@;		secret	-> R0 : address of a vector keeping the secret sequence
@;		guessed	-> R1 : address of a vector keeping the guessed sequence
@;		lenght	-> R2 : lenght of the sequences
@;	Result:
@;		R0 -> number of blacks
check_blacks:
		push {r3-r7, lr}			@; save modified regs and return address
		
		mov r3, #0					@; R3: num. of blacks
		mov r4, #0					@; R4: loop index (i)
		mov r5, #'@'				@; R5: mark for disabling matched symbols
	.Lblacks_fori:
		ldrb r6, [r0, r4]			@; R6: current symbol in secret sequence
		ldrb r7, [r1, r4]			@; R7: current symbol in guessed sequence
		cmp r6, r7
		bne .Lblacks_conti			@; skip next block when there isn't a match
		add r3, #1					@; count blacks
		strb r5, [r0, r4]
		strb r5, [r1, r4]			@; disable matched symbols
	.Lblacks_conti:
		add r4, #1
		cmp r4, r2
		blo .Lblacks_fori			@; close loop i
		
		mov r0, r3					@; return num. of blacks by value
		pop {r2-r7, pc}



@; unsigned short check_whites(char secret[], char guessed[],
@;								unsigned short lenght);
@;	Parameters:
@;		secret	-> R0 : address of a vector keeping the secret sequence
@;		guessed	-> R1 : address of a vector keeping the guessed sequence
@;		lenght	-> R2 : lenght of the sequences
@;	Result:
@;		R0 -> number of whites
@;	Precondition:
@;		black matches must be previously disabled, with an "strange" symbol
@;		(such as '@') on each match, both in secret and guessed sequences.
check_whites:
		push {r3-r8, lr}			@; save modified regs and return address
		
		mov r3, #0					@; R3: num. of whites
		mov r4, #0					@; R4: loop index (i)
		mov r6, #'@'				@; R6: mark for disabling matched symbols
	.Lwhites_fori:
		ldrb r7, [r1, r4]			@; R7: current symbol in guessed sequence
		cmp r7, r6					@; check if it is not disabled
		beq .Lwhites_conti
		
		mov r5, #0					@; R5: inner loop index (j)
	.Lwhites_forj:
		ldrb r8, [r0, r5]			@; R8: current symbol in secret sequence
		cmp r8, r7					@; check if there is a match
		bne .Lwhites_contj
		add r3, #1					@; count whites
		strb r6, [r0, r5]
		strb r6, [r1, r4]			@; disable matched symbols
		
	.Lwhites_contj:
		add r5, #1
		cmp r5, r2
		blo .Lwhites_forj			@; close loop j
		
	.Lwhites_conti:
		add r4, #1
		cmp r4, r2
		blo .Lwhites_fori			@; close loop i
		
		mov r0, r3					@; return num. of whites by value
		pop {r3-r8, pc}

.end
