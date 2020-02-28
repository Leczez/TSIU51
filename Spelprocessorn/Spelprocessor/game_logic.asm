



.org $600




Check_for_end_of_game:
	push r16
	rcall Check_for_full_map
	pop r16
	cpi r16,1 ; om banan är full
	breq Clear_Board

Check_Win:
	rcall Check_Horizontal
	lds r16,Win
	cpi r16,1
	breq Check_Winner

	rcall Check_Vertical
	lds r16,Win
	cpi r16,1
	breq Check_Winner

	lds r16,Win
	cpi r16,1
	breq Check_Winner
	rjmp Check_Done

Check_Winner:
	brts Player2_Wins

Player1_Wins:
	lds r16,Player1_Score
	inc r16
	sts Player1_Score,r16
	rjmp Clear_Board

Player2_Wins:
	lds r16,Player2_Score
	inc r16
	sts Player2_Score,r16

Clear_Board:
	ldi r17,$04
	sts Command_Byte,r17
	lds r17,Player1_Score
	sts Argument1_Byte,r17
	lds r17,Player2_Score
	sts Argument2_Byte,r17

	clr r16
	sts P1X,r16
	sts P1Y,r16
	sts P2X,r16
	sts P2Y,r16

	sts Win,r16

	clr r17
	rcall Load_X_Pointer
Clear_Loop:
	st X+,r16
	inc r17
	cpi r17,VMEM_SIZE
	brne Clear_Loop
	
	rcall Send_Data

Check_Done:
	

	ret


Check_for_full_map:
	push r16
	push r18 ;loop count
	in ZH,SPH
	in ZL,SPL
	rcall Load_X_Pointer
	; 1 if the map is full, 0 if there is still space.
Loop:
	ld r16,X+
	cpi r16,0
	breq Not_full
	cpi r18,VMEM_SIZE
	inc r18
	brne Loop
	ldi r16,1
	rjmp Loop_done
Not_full:
	clr r16
Loop_done:
	adiw Z,5
	st Z,r16
	pop r18
	pop r16
	
	ret




Check_Horizontal:
	push r16
	push r17
	push r18
	rcall Load_X_Pointer
	brts Horizontal_Player_2
Horizontal_Player_1:
	lds r16,P1X
	lds r17,P1Y
	ldi r18,1
	rcall CALCULATE_POS
	clr r17
	rjmp Right
Horizontal_Player_2:
	lds r16,P2X
	lds r17,P2Y
	ldi r18,2
	rcall CALCULATE_POS
	clr r17
	rjmp Right

Right:
	cpi XL,7
	breq Left
	inc XL
	ld r16,X
	cp r16,r18
	brne Left
	inc r17

	cpi r17,$03
	brne Right
	cpi r17,$03
	breq Horizontal_Check_Done
	brts Horizontal_Player_2_2
Horizontal_Player1_2:
	lds r16,P1X
	lds r17,P1Y
	rcall CALCULATE_POS
	rjmp Left

Horizontal_Player_2_2:

	lds r16,P2X
	lds r17,P2Y
	rcall CALCULATE_POS
Left:
	cpi XL,0
	breq Horizontal_No_Win
	dec XL
	ld r16,X
	cp r16,r18
	brne Horizontal_No_Win
	inc r17

	cpi r17,$03
	brne Left
	cpi r17,$03
	breq Horizontal_Check_Done
	rjmp Horizontal_No_Win

Horizontal_Check_Done:
	brts Horizontal_Player_2_Wins

Horizontal_Player_1_Wins:
	ldi r16,$01
	rjmp Horizontal_Done

Horizontal_Player_2_Wins:
	ldi r16,$02
	rjmp Horizontal_Done

Horizontal_No_Win:
	clr r16

Horizontal_Done:
	sts Win,r16
	pop r18
	pop r17
	pop r16	
	ret





Check_Vertical:
	push r16
	push r17
	push r18
	rcall Load_X_Pointer
	brts Vertical_Player_2
Vertical_Player_1:
	lds r16,P1X
	lds r17,P1Y
	ldi r18,1
	rcall CALCULATE_POS
	clr r17
	rjmp Up
Vertical_Player_2:
	lds r16,P2X
	lds r17,P2Y
	ldi r18,2
	rcall CALCULATE_POS
	clr r17
	rjmp Up

Up:
	cpi XH,0
	breq Down
	dec XH
	ld r16,X
	cp r16,r18
	brne Down
	inc r17

	cpi r17,$03
	brne Up
	cpi r17,$03
	breq Vertical_Check_Done
	
Vertical_Player1_2:
	lds r16,P1X
	lds r17,P1Y
	rcall CALCULATE_POS
	rjmp Down

Vertical_Player_2_2:

	lds r16,P2X
	lds r17,P2Y
	rcall CALCULATE_POS

Down:
	cpi XH,7
	breq Vertical_No_Win
	inc XH
	ld r16,X
	cp r16,r18
	brne Vertical_No_Win
	inc r17

	cpi r17,$03
	brne Down
	cpi r17,$03
	breq Vertical_Check_Done
	rjmp Vertical_No_Win

Vertical_Check_Done:
	brts Vertical_Player_2_Wins

Vertical_Player_1_Wins:
	ldi r16,$01
	rjmp Vertical_Done

Vertical_Player_2_Wins:
	ldi r16,$02
	rjmp Vertical_Done

Vertical_No_Win:
	clr r16

Vertical_Done:
	sts Win,r16
	pop r18
	pop r17
	pop r16	
	ret