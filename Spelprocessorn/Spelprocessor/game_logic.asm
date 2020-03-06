
.org $600


.equ Checks_Needed_for_a_win = $03

Check_for_end_of_game:
	push r16
	rcall Check_for_full_map
	pop r16
	clr r0
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

	
	rcall Right_Diagonal_Check
	lds r16,Win
	cpi r16,1
	breq Check_Winner

	
	rcall Left_Diagonal_Check
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
	clr r18
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
	push r20
	push r21
	clr r21
	rcall Load_X_Pointer
	brts Horizontal_Player_2
Horizontal_Player_1:
	lds r16,P1X
	lds r17,P1Y
	ldi r18,1
	rcall CALCULATE_POS
	
	lds r20,P1Y
	rjmp Right
Horizontal_Player_2:
	lds r16,P2X
	lds r17,P2Y
	ldi r18,2
	rcall CALCULATE_POS


Right:
	cpi r16,7
	breq Check_Left
	inc r16
	inc XL
	ld r19,X
	cp r19,r18
	brne Check_Left
	inc r21

	cpi r21,Checks_Needed_for_a_win
	brne Right

	rjmp Horizontal_Check_Done

Check_Left:
	brts Horizontal_Player_2_2

Horizontal_Player1_2:
	lds r16,P1X
	lds r17,P1Y
	rcall Load_X_Pointer
	rcall CALCULATE_POS
	rjmp Left

Horizontal_Player_2_2:
	lds r16,P2X
	lds r17,P2Y
	rcall Load_X_Pointer
	rcall CALCULATE_POS
Left:
	cpi r16,0
	breq Horizontal_No_Win
	dec r16

	dec XL
	ld r19,X
	cp r19,r18
	brne Horizontal_No_Win
	inc r21

	cpi r21,Checks_Needed_for_a_win
	brne Left
	rjmp Horizontal_Check_Done
	
Horizontal_Check_Done:
	ldi r16,$01
	rjmp Horizontal_Done

Horizontal_No_Win:
	clr r16

Horizontal_Done:
	sts Win,r16
	pop r21
	pop r20
	pop r18
	pop r17
	pop r16	
	ret





Check_Vertical:
	push r16
	push r17
	push r18
	push r20
	push r21
	clr r21
	rcall Load_X_Pointer
	brts Vertical_Player_2
Vertical_Player_1:
	lds r16,P1X
	lds r17,P1Y
	ldi r18,1
	rcall CALCULATE_POS
	lds r20,P1Y
	rjmp Up

Vertical_Player_2:
	lds r16,P2X
	lds r20,P2Y
	ldi r18,2
	rcall CALCULATE_POS
	lds r20,P2Y

Up:
	cpi r20,0
	breq Check_Down
	dec r20

	ldi r19,8
	sub XL,r19
	sbc XH,r0
	ld r19,X
	cp r19,r18
	brne Check_Down
	inc r21

	cpi r21,Checks_Needed_for_a_win
	brne Up
	rjmp Vertical_Check_Done

Check_Down:
	brts Vertical_Player_2_2	
Vertical_Player1_2:
	lds r16,P1X
	lds r17,P1Y
	rcall Load_X_Pointer
	rcall CALCULATE_POS
	rjmp Down

Vertical_Player_2_2:
	lds r16,P2X
	lds r17,P2Y
	rcall Load_X_Pointer
	rcall CALCULATE_POS

Down:
	cpi r17,7
	breq Vertical_No_Win
	inc r17

	ldi r16,8
	add XL,r16
	adc XH,r0
	ld r16,X
	cp r16,r18
	brne Vertical_No_Win
	inc r21

	cpi r21,Checks_Needed_for_a_win
	brne Down
	rjmp Vertical_Check_Done
	

Vertical_Check_Done:
	ldi r16,$01
	rjmp Vertical_Done

Vertical_No_Win:
	clr r16

Vertical_Done:
	sts Win,r16
	pop r21
	pop r20
	pop r18
	pop r17
	pop r16	
	ret



Right_Diagonal_Check:
	push r16
	push r17
	push r18
	push r20
	push r21
	push r22
	clr r21
	rcall Load_X_Pointer
	brts Right_Diagonal_Player_2
Right_Diagonal_Player_1:
	lds r16,P1X
	lds r17,P1Y
	ldi r18,1
	rcall CALCULATE_POS
	rjmp Up_Right
Right_Diagonal_Player_2:
	lds r16,P2X
	lds r17,P2Y
	ldi r18,2
	rcall CALCULATE_POS

	rjmp Up_Right

Up_Right:
	cpi r17,0
	breq Check_Down_Left
	cpi r16,7
	breq Check_Down_Left
	dec r17
	inc r16

	ldi r20,8
	sub XL,r20
	sbc XH,r0
	inc XL
	ld r20,X
	cp r20,r18
	brne Check_Down_Left
	inc r21

	cpi r21,Checks_Needed_for_a_win
	brne Up_Right
	rjmp Right_Diagonal_Check_Done

Check_Down_Left:
	brts Right_Diagonal_Player_2_2
	
Right_Diagonal_Player1_2:
	lds r16,P1X
	lds r17,P1Y
	rcall Load_X_Pointer
	rcall CALCULATE_POS
	rjmp Down_Left

Right_Diagonal_Player_2_2:
	lds r16,P2X
	lds r17,P2Y
	rcall Load_X_Pointer
	rcall CALCULATE_POS

Down_Left:
	cpi r17,7
	breq Right_Diagonal_No_Win
	cpi r16,0
	breq Right_Diagonal_No_Win
	inc r17
	dec r16

	breq Right_Diagonal_No_Win
	ldi r20,8
	add XL,r20
	adc XH,r0
	dec XL
	ld r20,X
	cp r20,r18
	brne Right_Diagonal_No_Win
	inc r21

	cpi r21,Checks_Needed_for_a_win
	brne Down_Left

Right_Diagonal_Check_Done:
	ldi r16,$01
	rjmp Right_Diagonal_Done

Right_Diagonal_No_Win:
	clr r16

Right_Diagonal_Done:
	sts Win,r16
	pop r22
	pop r21
	pop r20
	pop r18
	pop r17
	pop r16	
	ret



Left_Diagonal_Check:
	push r16
	push r17
	push r18
	push r20
	push r21
	clr r21
	rcall Load_X_Pointer
	brts Left_Diagonal_Player_2
Left_Diagonal_Player_1:
	lds r16,P1X
	lds r17,P1Y
	ldi r18,1
	rcall CALCULATE_POS
	rjmp Up_Left
Left_Diagonal_Player_2:
	lds r16,P2X
	lds r17,P2Y
	ldi r18,2
	rcall CALCULATE_POS

Up_Left:
	cpi r17,0
	breq Check_Down_Right
	cpi r16,0
	breq Check_Down_Right
	dec r17
	dec r16

	ldi r20,8
	sub XL,r20
	sbc XH,r0
	dec XL
	ld r20,X
	cp r20,r18
	brne Check_Down_Right
	inc r21

	cpi r21,Checks_Needed_for_a_win
	brne Up_Left
	rjmp Left_Diagonal_Check_Done

Check_Down_Right:
	brts Left_Diagonal_Player_2_2
	
Left_Diagonal_Player1_2:
	lds r16,P1X
	lds r17,P1Y
	rcall Load_X_Pointer
	rcall CALCULATE_POS
	rjmp Down_Right

Left_Diagonal_Player_2_2:
	lds r16,P2X
	lds r17,P2Y
	rcall Load_X_Pointer
	rcall CALCULATE_POS

Down_Right:
	cpi r17,7
	breq Left_Diagonal_No_Win
	cpi r16,7
	breq Left_Diagonal_No_Win
	inc r17
	inc r16


	ldi r20,8
	add XL,r20
	adc XH,r0
	inc XL
	ld r20,X
	cp r20,r18
	brne Left_Diagonal_No_Win
	inc r21

	cpi r21,Checks_Needed_for_a_win
	brne Down_Right

Left_Diagonal_Check_Done:
	ldi r16,$01
	rjmp Left_Diagonal_Done

Left_Diagonal_No_Win:
	clr r16

Left_Diagonal_Done:
	sts Win,r16
	pop r21
	pop r20
	pop r18
	pop r17
	pop r16	
	ret

