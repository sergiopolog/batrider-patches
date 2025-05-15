	CPU 68000
	PADDING OFF
	ORG	$000000
	BINCLUDE "original_combined_batriderj.bin"


FREE_OFFSET = $80000


	ORG $100
	dc.l $01E6D1AF	; Updated hash for ROM0 with current changes in this patch
	dc.l $02644E52	; Updated hash for ROM1 with current changes in this patch


; In this instruction, original code calls to 'read-inputs' subroutine on each frame ('jsr $205c'), in order to load player inputs values into RAM
	ORG $3E6
	jsr test_quick_reset	; intercepts the execution of the 'read-inputs' subroutine. Instead, jump to our custom subroutine to test if a Quick Reset is requested



; After the upper part of the screen info text is copied into Text RAM, copy ours before next subroutine outputs it to video
	ORG $1096
	jsr rank_display
; This is the original code in batriderj, which copies data into Text RAM area:
; 0108a:	jsr  ($14,PC) ; ($10a0)		4eba 0014
; 0108e:	trap #$9 					4e49
; 01090:	jsr $7940					4eb9 0000 7940
; 01096:	jsr $12640  				4eb9 0001 2640
; 0109c:	trap #$4    				4e44
; 0109e:	rts							4e75
; ------------
; Subroutine at $7940 is intended to show "Score Info" at screen when that mode is enabled during gameplay (Start + B) and it should be executed before our custom code to write Rank info at screen.
; Our instruction 'jsr rank_display' is 3 words long (6 bytes), so it could be located in place of 'jsr $12640' instruction address, which is also 3 words long, replacing it.
; Then, we need to run that 'jsr $12640' instruction on our custom code in order keep the original behaviour of the game code.
; The next instructions, starting with 'trap #$4' at $109C, remain unchanged and on their original locations. They are executed after our custom subroutine returns to this point.




; Move first row of Scoring Info Mode one row below than original at screen, avoiding to collide with the Rank percentaje display location, which is placed in the same row
	ORG $79D8
	lea $200046.l,A2	; original instruction here set address $200048.l into A2. As Rank percentaje value is placed in the same row, move it one row below, i.e. 2 bytes before




; Replace 'STAGE EDIT' text with ' SHOW RANK'
	ORG $12B02
	dc.b $20	; ' ' character index
	dc.b $53	; 'S' character index
	dc.b $48	; 'H' character index
	dc.b $4F	; 'O' character index
	dc.b $57	; 'W' character index
	dc.b $20	; ' ' character index
	dc.b $52	; 'R' character index
	dc.b $41	; 'A' character index
	dc.b $4E	; 'N' character index
	dc.b $4B	; 'K' character index




; DISABLE 'STAGE EDIT' DIP Switch
; Original instruction here was 'or.b $20fa02.l,d0'.
; Just replace that OR operation to perform it against a $0 value in order to disable the original behavior of the STAGE EDIT Dip Switch and set it as 'no effect'
	ORG $1307A
	or.b #0,d0			; 'or.b #0,d0'  is 2-words long   and  'or.b $20fa02.l,d0' is 3-words long
	nop					; 'nop' is 1-word long



; Fix TEXT TEST: now palette code could be modified by pressing C button + Joystick directions (same that is done in Battle Bakraid)
	ORG $15B72
	jsr fix_text_test


; Modify subroutine to update Text Tile number on TEXT TEST in order to AVOID changing tile number if button 3 is pressed
	ORG $15BCA
	btst #$6,D0		; D0 contains the value of the player inputs. Checks if Button 3 is pressed (bit 6 is enabled), and if so...
	bne $15c06		; ... jump to the end of subroutine, avoiding changing the Tile number.
	btst #$0,D0
	beq $15bde
	addi.w #$10,$20f9e8
	btst #$1,D0
	beq $15bec
	subi.w #$10,$20f9e8
	btst #$3,D0
	beq $15bf8

; Modify subroutine for update Palette number on TEXT TEST in order to ONLY change palette code if button 3 is pressed
	ORG $15C16
	cmpi.b #$41,D0	; D0 contains the value of the player inputs. Only modify palette number if Button 3 is pressed ($41 has the bit 6 enabled)
	bne $15c26
	nop

	ORG $15C26
	cmpi.b #$42,D0
	bne $15c36
	nop

	ORG $15C36
	cmpi.b #$48,D0
	bne $15c44
	nop

	ORG $15C44
	cmpi.b #$44,D0
	bne $15c52
	nop




; On instructions starting from $178AE, it loads the pre-computed hash of ROM0 from address $100 into D0
; Then, it substracts the hash calculated from the contents of the ROM0 to it, saving the result again into D0. The calculated hash was stored on RAM address: $20E6FE
; If both, pre-computed hash taken from ROM, and the actual calculated hash match (substraction result is $0), then the ROM check is OK

; Same happens again for ROM1 at $178C2, taking the pre-computed hash of ROM1 from address $104, and the calculated hash for ROM1 was stored on RAM address: $20E702

; Calculated hashes from current changes in ROM0 and ROM1:
; - ROM0: $01E6D1AF
; - ROM1: $02644E52

; ----- UNCOMMENT THIS DURING PATCH DEVELOPMENT, IF THE HASHES FOR ROM0 AND ROM1 ARE STILL NOT ADJUSTED
; In this instruction, original code branches to 'ROM OK' subroutine after comparing the expected hash with the computed one got from program ROMs in the ROM/RAM check.
;	ORG $17A2C
;	bra $177CE	; instead of branching to 'ROM OK' subroutine only if comparation matches, branch in any case, bypassing the ROM check

; when the patch is complete, check which is the computed value of the two ROM hashes on instruction at $17A2C and put them on the address positions: $100 and $104 respectively





; Warning/Copyright screen text
	ORG $17F15
	dc.b $4A	; 'J' character index
	dc.b $41	; 'A' character index
	dc.b $4D	; 'M' character index
	dc.b $21	; '!' character index
	dc.b $00	; end of paragraph



; Replace 'STAGE EDIT' text with 'SHOW RANK '
	ORG $18956
	dc.b $53	; 'S' character index
	dc.b $48	; 'H' character index
	dc.b $4F	; 'O' character index
	dc.b $57	; 'W' character index
	dc.b $20	; ' ' character index
	dc.b $52	; 'R' character index
	dc.b $41	; 'A' character index
	dc.b $4E	; 'N' character index
	dc.b $4B	; 'K' character index
	dc.b $20	; ' ' character index




;-----------------------------------------------------------;
;															;
;				CUSTOM CODE STARTS HERE						;
;															;
;-----------------------------------------------------------;

	ORG FREE_OFFSET

test_quick_reset:
	jsr $205c				; Firstly, run the original 'read-inputs' subroutine (originally called on $3E6), in order to load player inputs values into proper RAM addresses

	move.b d1,-(sp)			; Second, save current values of D1, D3, D4 and D5 into stack, as we gonna use them in our custom code
	move.b d3,-(sp)
	move.b d4,-(sp)
	move.b d5,-(sp)

	move.b ($204062),d3		; check if P1 or P2 are active on this moment
	move.b ($2041D4),d4
	move.b d3,d5
	or.b d4,d5
	cmpi.b #$00,d5
	beq resume_game			; if none of them are currently active (i.e.: attract mode, title screen... etc), then resume the game
	
test_quick_reset_p1:
	cmpi.b #$00,d3			; if P1 is currently active, then check if ABC+Start from P1 is pressed
	beq test_quick_reset_p2
	move.b ($203490),d1
	andi.b #$F0,d1			
	cmpi.b #$F0,d1			; $F0 is the value on that RAM address when ABC+Start from P1 are pressed at the same time
	beq return_to_copyright

test_quick_reset_p2:
	cmpi.b #$00,d4			; if P2 is currently active, then check if ABC+Start from P2 is pressed
	beq resume_game
	move.b ($203491),d1
	andi.b #$F0,d1
	cmpi.b #$F0,d1	
	beq return_to_copyright

resume_game:
	move.b (sp)+,d5			; Restore original values of D1, D3, D4 and D5 (in the proper order) if the quick reset was not requested
	move.b (sp)+,d4
	move.b (sp)+,d3
	move.b (sp)+,d1
	rts
	
	
return_to_copyright:
	move.b #$00,($204062)	; Mark flags of P1 and P2 active game to $00, in order to avoid a reset-loop
	move.b #$00,($2041D4)
	move.b #$23,($500021) 	; fade-out sound command
	move.b #$1A,($500023) 	; don't care value but it's needed: song number
	move.w #$0000,($500026) ; clear sound IRQ
	
; 'Rank Base Multiplier' is recalculated every time the Warning/Copyright screen is shown based on which button is pressed when booting the game.
; So, here we need to simulate that the Start button was pressed at boot-up if the 'Rank Base Multiplier' value is $100, before jumping to copyright screen.
; This makes the recalculation of 'Rank Base Multiplier' in the upcoming Copyright screen keeps the $100 value, as it was before quick reset:
	move.w ($20F9CE),d1		; Save 'Rank Base Multiplier' value into D1
	cmpi.w #$100,d1			; Compare that value with $100
	bne test_freeplay		; If it's not equal to $100, we simply do nothing and jump to next step
	move.b #$80,($2034BB)	; But if it's equal, we put a $80 value into $2034BB RAM address, as that what's done when booting up the game with Start Button.


test_freeplay:
	move.l ($203400),d1		; Save 'Free Play' status value into D1
	cmpi.l #$FF0000FF,d1	; Compare that value with $FF0000FF, which is marking the board is booted with freeplay option enabled
	beq jump_to_copyright	; If it's equal to 'Free play' status vale, we simply do nothing and jump to copyright screen
	clr.l ($203400)			; If not, clear number of credits

jump_to_copyright:	
	move.b (sp)+,d5			; Extract values of D1, D3, D4 and D5 (in the proper order), just to pop them out from the stack and free the space
	move.b (sp)+,d4
	move.b (sp)+,d3
	move.b (sp)+,d1

	jmp $2D0				; jump to the very next instruction after ROM/RAM check (Warning/Copyright screen)

	
; When Freeplay is disabled, $203400.l:
;	- is initialized at boot to: 	0000 0000
;	- when entering credit is: 		1FFF FFFF
; 	- when pressing start is:  		0000 FF00
; 	- when continue screen is: 		0000 0000
; 	- when insert credit is:   		01FF 00FF
; 	- when start continue is:  		00FF 0000
;
; When Freeplay is enabled,  $203400.l:
;	- is initialized at boot to: 	FF00 00FF
;	- when forzing title screen is: FFFF 00FF
; 	- when pressing start is:  		FF00 00FF
; 	- when continue screen is: 		FF00 00FF
; 	- when insert credit is:   		FF00 00FF
; 	- when start continue is:  		FF00 00FF


	
fix_text_test:
	jsr $15c10	; this subroutine, which updates the palette code, is not called in original code of TEXT TEST
	jsr $15c5c
	dc.w $A01C
	rts




; Convert a number to base-10 ASCII and write it to Text RAM
; IN:
;  - d1: The number to display
;  - d0: The 'format code' to use for the digits
;  - a5: Start address of output string
; After return, a5 will point to the character AFTER the end of the displayed string
write_ascii_to_txt:
	clr.w d2
	clr.w d3
ascii_loop_start:
	divu #$A,d1
	addq.b #1,d2
	move.l d1,d3
	swap d3
	addi.b #$30,d3
	eor.w d0,d3
	move.w d3, -(sp)
	swap d1
	clr.w d1
	swap d1
	tst.w d1
	bne ascii_loop_start
	bra copy_loop_start
copy_loop_head:
	move.w (sp)+,d3
	move.w d3,(a5)
	lea $80(a5),a5
copy_loop_start:
	dbf d2,copy_loop_head
	rts

; Same as above routine but intended to write a base-16 (hex) number into Text RAM
write_asciihex_to_txt:
	clr.w d3
	clr.w d2
	clr.w d4
	tst.l d1
	beq value_is_zero
write_hex_start:
	move.b d1,d3
	and.b #$F,d3 
	addq.b #1,d2
	lsr.l #4,d1
write_hex_resume:
	cmp.b #$9,d3
	bgt add_hex
	addi.b #$30,d3
	bra after_hex
add_hex:
	addi.b #$37,d3
after_hex:
	or.w d0,d3
	move.w d3, -(sp)
	cmp.b #$8,d2
	bne write_hex_start 
purge_loop_head:
	move.w (sp)+,d3
	cmp.b #$30, d3
	bne purge_done
purge_loop_start:
	dbf d2,purge_loop_head
	rts
purge_done:
	move.w d3, -(sp)
	bra copy_loop_start
value_is_zero:
	moveq #$0,d3
	or.w d0,d3
	move.w d3,(a5)
	rts
digit_is_zero:
	btst #$F,d4
	beq write_hex_start
	bra write_hex_resume



; Writes a percentage value, using 2 decimals precision, into Text RAM
; IN:
;  - d7: The number to calculate the percentage and display it
;  - d0: The 'format code' to use for the digits
;  - a5: Start address of output string
; After return, a5 will point to the character AFTER the end of the displayed string
write_percentage_to_txt:
	move.l #$FF0000,d5		; $FF0000 is the min Rank ever, used for 'Training/Normal' courses on 'Easy' difficulty Dip Switch
	sub.l d7,d5				; Current rank in the game is stored at address ($20F9D0)
	divu #$687,d5			; $687 = ($FF0000 / 10000).  As this is a fixed value, simply hardcoded it here instead of performing the division on each frame
	swap d5
	clr.w d5
	swap d5					; on D5 is the exact percentage value, i.e.: integer + decimal parts
	
	move.w d5,d4			; Copy that value into D4, as we will need the full value later
	divu #100,d5			; Divide the exact percentage value by 100 (base-10) to get the integer part of the percentage (decimals are truncated)
	swap d5
	clr.w d5
	swap d5					; Now, on D5 is only the integer part of the percentage value
	move.w d5,d1			; Copy it also to D1 to write it to the Text RAM
	jsr write_ascii_to_txt	; write the integer part of the percentage


	move.w d0,d6			; write (manually) the decimal separator, right after the integer part, using palette index given on D0
	add.b #$2E,d6   		; '.' = $2E
	move.w d6,(a5)			; d6 = $C42E
	lea $80(a5),a5			; and move the cursor one position to the right
	
	mulu.w #100,d5			; restore the original magnitude of the integer part of percentage...
	sub.w d5,d4				; ... and substract it to the total percentage saved previously on D4. Now on D4 is only the decimal part of the percentage value

	cmpi.w #10,d4			; if decimal part is greater or equal to 10, then jump directly to display it on screen
	bge write_percentage_decimals

	move.w d0,d6			; if is lower than 10, then write a '0' character first, using palette index given on D0
	add.b #$30,d6   		; '0' = $30
	move.w d6,(a5)			; d6 = $C430 (example palette index)
	lea $80(a5),a5			; and move the cursor one position to the right


write_percentage_decimals:
	move.w d4,d1
	jsr write_ascii_to_txt	; write the decimal part of the percentage

	
	move.w d0,d6			; write (manually) the percentage symbol, right after the decimal part, using palette index given on D0
	add.b #$25,d6   		; '%' = $25
	move.w d6,(a5)			; d6 = $C425 (example palette index)
	lea $80(a5),a5			; and move the cursor one position to the right
	

	move.w d0,d6			; write (manually) a "blank space" character, right after the percentaje symbol, using palette index given on D0 (don't care)
	add.b #$20,d6   		; ' ' = $20
	move.w d6,(a5)			; d6 = $C420 (example palette index)
	lea $80(a5),a5			; and move the cursor one position to the right


	move.w d0,d6			; write (manually) another "blank space" character, right after the previous one, using palette index given on D0 (don't care)
	add.b #$20,d6   		; ' ' = $20
	move.w d6,(a5)			; d6 = $C420 (example palette index)
	lea $80(a5),a5			; and move the cursor one position to the right


	rts





;-----------------------------------------------------------;
;															;
;						RANK DISPLAY						;
;															;
;-----------------------------------------------------------;


rank_display:
; this is the overwritten instruction in original code that should be executed before our custom code
	jsr $12640



; Check if Dip Switch 2 of DSW3 is enabled: If Enabled, value of $FF is set at address: $20fa02
	move.b ($20fa02),d0
	cmpi.b #0,d0
	beq end_display			; If Switch 2 of DSW3 is disabled, then jump to end_display, preventing to write Rank Info into Text RAM


; Display overall Rank. Value is located at address $20F9D0.l
	lea ($200648),a5
	move.w #$C400,d0
	move.l ($20F9D0),d1
	jsr write_asciihex_to_txt
	

; Display per-rank Rank. Value is calculated as "Timer Rank" (located at address $20F9D4.l) + # of credits remaining (located at address $203400.b)
; As # of credits is an 8-bit number (byte), when 'Free-Play' option is enabled, the value is a negative number ($FF).
; We need to check if that number is negative and, in that case, exclude adding it to the "Timer Rank", as original code didn't use it to update the Rank every frame when 'Free Play' is enabled
	move.b ($203400),d1
	bpl add_credits
	move.b #$0,d1
	
add_credits:
	add.l ($20F9D4),d1
	lea ($200046),a5
	jsr write_ascii_to_txt

	clr.l d1


rank_percentage_display:
; Display current percentage Rank:
	lea ($200048),a5		; Start position of the screen cursor to display the percentage
	move.w #$C400,d0		; Palette index used: $C4 = Light Blue
	move.l ($20F9D0),d7		; Current rank in the game is stored at address ($20F9D0)
	jsr write_percentage_to_txt


rank_min_percentage_display:
; Display min percentage on the current game:
	lea ($200B48),a5		; Start position of the screen cursor to display the percentage
	move.w #$D000,d0		; Palette index used: $D0 = Yellow
	move.l ($20F9D8),d7		; Min. rank in the game is stored at address ($20F9D8)
	
	cmpi.l #$E58000,d7		; $E58000 is the rank value for 10.00%, so...
	ble min_percentage		; ... compare if current rank is greater or equal to that value, and in that case, jump to directly write the 2-digit percentage
	lea $80(a5),a5			; If not, move the cursor one position to the right, because integer part of the percentage is 1-digit only, in order to align it to the rightmost part of the screen
	
min_percentage:
; First display a ' ' character on the screen
	move.w d0,d6			; write (manually) a "blank space" character, using palette index given on D0
	add.b #$20,d6   		; ' ' = $20
	move.w d6,(a5)			; d6 = $D020 (example palette index)
	lea $80(a5),a5			; and move the cursor one position to the right

; Then, display a '>' character on the screen
	move.w d0,d6			; write (manually) the greater than symbol, using palette index given on D0
	add.b #$3E,d6   		; '>' = $3E
	move.w d6,(a5)			; d6 = $D03E (example palette index)
	lea $80(a5),a5			; and move the cursor one position to the right

; Then, calculate and display the min percentage rank:
	jsr write_percentage_to_txt



end_display:
	rts
