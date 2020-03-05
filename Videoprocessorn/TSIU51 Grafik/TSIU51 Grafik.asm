.include "UART.asm"

.equ RED = 0x02
.equ GREEN = 0x01
.equ BLUE = 0x00

.equ GAMEDELAY_H = 100
.equ GAMEDELAY_L = 0

.org 0x00
	rjmp START
/*
.org 0x014
	rjmp LOAD_DATA 
*/

.org 0x016
	rjmp RECEIVE


.dseg
	.org 0x300

	SEND_BYTE: .byte 4
	SEND_BUFF: .byte 1
	LOOP: .byte 1

	ROWS: .byte 24 ;rgb, rgb, rgb...
	INDEX: .byte 1 ;register with shifting 0
	ROW_POS: .byte 1 ;ROW_POS*3 = next row of rgb

	NEXT_INSTRUCTION: .byte 3 ;UART bytes
	CURR_INS_BYTE: .byte 1 ;keeps track of bytes in instruction


	NEW_X_CORD: .byte 1
	NEW_Y_CORD: .byte 1
	ON_OFF: .byte 1 ;1=ON, 0=OFF
	COLOR: .byte 1 ; 0=blue..2=red
	NEW_Y_CORD_CONV: .byte 1 ;Y cord after CONVERT_CORDS call


	OLD_X_CORD_P1: .byte 1
	OLD_Y_CORD_P1: .byte 1

	OLD_X_CORD_P2: .byte 1
	OLD_Y_CORD_P2: .byte 1

	ROWS_PROTECT: .byte 24 ;


.cseg
LOOKUP: .db 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x00



START:
	ldi r16,high(RAMEND)
	out SPH,r16

	ldi r16,low(RAMEND)
	out SPL,r16	

	rcall INIT
	rcall UART_INIT
	rcall MEMORY_INIT


/*
		ldi r16, 0x00
		sts NEW_X_CORD, r16

		ldi r16, 0x00
		sts NEW_Y_CORD, r16

		ldi r16, 0x00
		sts COLOR, r16
		ldi r16, 0x01
		sts ON_OFF,r16
		rcall MEMORY_WRITE
*/


;////////////////////

MAIN:
	rcall MEMORY_READ
	rcall SEND
	rcall INDEX_SHIFT
	rcall CHECK_NEXT_INS
	rcall DELAY
	rjmp MAIN

;///////////////////////////


SEND:
;//Sends byte to spi and rcalls LOAD_DATA 4x, then resets SEND_BYTE pointer
	ldi ZH, high(SEND_BYTE)
	ldi ZL, low(SEND_BYTE)

SEND_LOOP:
	lds r16, LOOP
	cpi r16, 0x04
	breq RESET_PTR 
	rcall LOAD_DATA
	lds r16, SEND_BUFF
	out SPDR, r16 ;SEND DATA

	WAIT:
	;//Checks if shifting of byte to display is done
		sbis SPSR,SPIF 
		rjmp WAIT
		rjmp SEND_LOOP

	RESET_PTR:
		rcall PULL_LATCH
		ldi ZH, high(SEND_BYTE)
		ldi ZL, low(SEND_BYTE)
		clr r16
		sts LOOP, r16
	
	ret




MEMORY_READ:
;//Reads ROWS in sram and stores in right order in SEND_BYTE
	rcall Load_Rows

	lds r16, ROW_POS 
	cpi r16, 24
	brne ADD_POS
	clr r16

	ADD_POS:
		add XL, r16

		
		NOT_END:
			ld r18, X++
			sts SEND_BYTE, r18
	
			ld r18, X++
			sts SEND_BYTE+1, r18
	
			ld r18, X
			sts SEND_BYTE+2, r18	
	

	;rcall NEXT_POS ;increases register by three
	ldi r17,0x03
	add r16,r17
	sts ROW_POS, r16

	ret


NEXT_POS:
	clr r17
	NEXT_POS_LOOP:
		inc r16
		inc r17
		cpi r17, 0x03
		brne NEXT_POS_LOOP
	ret


INDEX_SHIFT:
	lds r16, INDEX
	cpi r16, 0x7f
	breq NO_SET_CARRY
	sec
	NO_SET_CARRY:
	rol r16
	sts INDEX, r16
	sts SEND_BYTE + 3, r16

	ret



CHECK_NEXT_INS:
	lds r16, CURR_INS_BYTE
	cpi r16, 0x03
	brne NO_VALID_INSTRUCT
	
	EXECUTE_INSTRUCTION:
	rcall EXEC_INS



	NO_VALID_INSTRUCT:
		ret


EXEC_INS:
	INS_TYPE_CHECK:
	lds r16, NEXT_INSTRUCTION
	
	cpi r16, 0x00
	breq P1_MOVE

	cpi r16, 0x01
	breq P2_MOVE

	cpi r16, 0x04
	;breq CLEAR_BOARD

	rjmp EXIT


	P1_MOVE:
		OLD_P1_OFF:
			lds r16, OLD_X_CORD_P1
			lds r17, OLD_Y_CORD_P1

			sts NEW_X_CORD, r16
			sts NEW_Y_CORD, r17

			ldi r16, RED
			sts COLOR, r16
			clr r16
			sts ON_OFF, r16

			rcall MEMORY_WRITE
	


		NEW_P1_ON:
			lds r16, NEXT_INSTRUCTION+1
			sts NEW_X_CORD, r16
			sts OLD_X_CORD_P1, r16

			lds r16, NEXT_INSTRUCTION+2
			sts NEW_Y_CORD, r16
			sts OLD_Y_CORD_P1, r16

			ldi r16, RED
			sts COLOR, r16
			ldi r16, 0x01
			sts ON_OFF, r16

			rcall MEMORY_WRITE


	rjmp EXIT



	P2_MOVE:
		OLD_P2_OFF:
			lds r16, OLD_X_CORD_P2
			lds r17, OLD_Y_CORD_P2

			sts NEW_X_CORD, r16
			sts NEW_Y_CORD, r17

			ldi r16, BLUE
			sts COLOR, r16
			clr r16
			sts ON_OFF, r16

			rcall MEMORY_WRITE
			

		NEW_P2_ON:
			lds r16, NEXT_INSTRUCTION+1
			sts NEW_X_CORD, r16
			sts OLD_X_CORD_P2, r16

			lds r16, NEXT_INSTRUCTION+2
			sts NEW_Y_CORD, r16
			sts OLD_Y_CORD_P2, r16

			ldi r16, BLUE
			sts COLOR, r16
			ldi r16, 0x01
			sts ON_OFF, r16

			rcall MEMORY_WRITE

		rjmp EXIT


	CLEAR_BOARD:
		rcall MEMORY_INIT
		rjmp EXIT


EXIT:
	ret



LOAD_DATA:
;//Loads next byte in SEND_BYTES into send buffer (SEND_BUFF)
	ld r16, Z++
	sts SEND_BUFF, r16

	lds r16, LOOP
	inc r16
	sts LOOP, r16

	ret

PULL_LATCH:
	sbi PORTB, 4 
	nop
	lpm
	lpm
	cbi PORTB, 4
	ret

Calculate_Position:
	push r18
	push r17
	push r16
	clr r16
	lds r18, NEW_X_CORD
	ldi r17,0x03
Calc_Loop:
	inc r16
	add XL,r17
	cp r16,r18
	brne Calc_Loop

Calc_Done:
	pop r16
	pop r17
	pop r18
	ret


MEMORY_WRITE:
;//Writes to ROWS in sram
	rcall CONVERT_CORDS

	rcall Load_Rows
	rcall Calculate_Position



		
	ON_OFF_CHECK:
		lds r16, ON_OFF
		cpi r16, 0x00
		breq TURN_OFF

	TURN_ON:
		lds r17, COLOR
		add XL, r17

		ld r16, X
		lds r17, NEW_Y_CORD_CONV

		or r16, r17
		st X, r16
		rjmp Memory_Write_Done

	TURN_OFF:
		lds r17, COLOR
		add XL, r17

		ld r16, X
		lds r17, NEW_Y_CORD_CONV

		eor r16, r17
		st X, r16

Memory_Write_Done:



	ret

	NEXT_X_POS:
	clr r17
	clr r16
	NEXT_X_POS_LOOP:
		inc r16
		inc r17
		cpi r17, 0x03
		brne NEXT_X_POS_LOOP
	ret

	

CONVERT_CORDS:
	lds r16, NEW_Y_CORD
	
	ldi ZH, high(LOOKUP*2)
	ldi ZL, low(LOOKUP*2)

	add ZL, r16
	lpm r16, Z

	sts NEW_Y_CORD_CONV, r16

	ret

	
Load_Rows:
	ldi XH,HIGH(ROWS)
	ldi XL,LOW(ROWS)
	ret
	



DELAY:
	ldi r23, GAMEDELAY_L
	ldi r24, GAMEDELAY_H

	DELAY_2:
		sbiw r24, 0x01
		brne DELAY_2
		ret




INIT:
;//SPI initalization
	ldi r16, 0xB0
	out DDRB, r16

	ldi r16,(1<<SPE | 1<<MSTR | 0<<SPIE | 0<<SPR0)
	out SPCR, r16



	ret


	MEMORY_INIT:
	ldi r16, 0b11111110
	sts INDEX, r16

	clr r16
	sts ROW_POS, r16
		
	CLEAR_MEM:
		clr r16
		clr r17
		ldi ZH,high(ROWS)
		ldi ZL,low(ROWS)
		CLR_LOOP:
			inc r17
			st Z+,r16
			cpi r17, 24
			brne CLR_LOOP


		clr r16
		sts ON_OFF, r16

	ret