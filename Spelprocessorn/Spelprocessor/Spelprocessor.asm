/*
 * Spelprocessor.asm
 *
 *  Created: 2020-02-04 09:29:40
 *   Author: lincl896
 */ 

 // Main filen

.include "Joystick_driver.asm"
.equ VMEM_SIZE = 64
.equ DELAY_HIGH = 1
.equ DELAY_LOW = 30


.dseg
.org SRAM_START
P1X: .byte	1; Player 1 X position
P1Y: .byte	1; Player 1 Y position
P2X: .byte	1; Player 2 X position
P2Y: .byte	1; Player 2 Y position

VMEM: .byte VMEM_SIZE

.cseg
.org $0000
	rjmp Setup
.org INT0addr
	rjmp Interrupt0
.org INT1addr
	rjmp Interrupt1
Setup:

ldi r16, HIGH(RAMEND)
out SPH, r16
ldi r16, LOW(RAMEND)
out SPL, r16

	

Hardware_Init:

	rcall Joystick_Init
	ldi r16, (1<<ISC11)|(0<<ISC10)|(1<<ISC01)|(0<<ISC00)
	out MCUCR, r16
	ldi r16, (1<<INT0)|(1<<INT1)
	out GICR, r16

	ldi r16, $FF
	out PORTD, r16

Usart_Init:
	; Se sida 143 i databladet
	
	; Set baud rate
	out UBRRH, r17
	out UBRRL, r16
	
	; Enable receiver and transmitter
	ldi r16, (1<<TXEN)
	out UCSRB, r16
	
	; Set frame format: 8data, 1stop bit
	ldi r16, (1<<URSEL)|(3<<UCSZ0)
	out UCSRC, r16
	
	sei

Main:	
	rcall Player_Input;
	rcall Delay
	rjmp Main

SendByte:
	; Se sida 144 i databladet
	
	; Wait for empty transmit buffer
	sbis UCSRA, UDRE
	rjmp SendByte
	
	; Put data (r16) into buffer, sends the data
	out UDR, r16
	
	ret

Send_Player_Data:
	
	ldi r16, $FF
	rcall SendByte		; Start of message

	mov r16, r17
	rcall SendByte		; message type: 0 if player selects, 1 if player 1 selects

	mov r16, r18
	rcall SendByte		; X-value

	mov r16, r19
	rcall SendByte		; Y-value

	ret

//Player 1 = t 0, Player 2 = t 1
Player_Input:
	push r16
	push r17
	push r18
	push r19

	brts Player2	
	rcall Input_P1
	clr r17
	lds r18, P1X
	lds r19, P1Y
	rcall Send_Player_Data
	rjmp Input_done
Player2:
	rcall Input_P2
	ldi r17, $01
	lds r18, P2X
	lds r19, P2Y
	rcall Send_Player_Data
Input_done:
	pop r19
	pop r18
	pop r17
	pop r16
	ret


DELAY:
	push r24
	push r25
	ldi r25,DELAY_HIGH
	ldi r24,DELAY_LOW

DELAY2:
	sbiw r24,1
	brne DELAY2
	pop	r25
	pop	r24
	ret

Load_X_Pointer:
	ldi XH,HIGH(VMEM)
	ldi XL,LOW(VMEM)
	ret

Calculate_Pos:
	add XL,r16
	lsl r17
	lsl r17
	lsl r17
	adc XH,r17
	ret

//Player 1 joystick push button interrupt
Interrupt0:
	push r16
	push r17
	push r18

	brts P1_DONE
	lds r16, P1X
	lds r17, P1Y

	rcall Load_X_Pointer
	rcall Calculate_Pos

	ld r18,X
	cpi r18,1
	breq P1_DONE
	cpi r18,2
	breq P1_DONE
	ldi r16,1
	st X,r16
	rcall Check_for_end_of_game
P1_DONE:
	
	pop r18
	pop r17
	pop r16
	reti

//Player 2 joystick push button interrupt
Interrupt1:
	push r16
	push r17
	brtc P2_DONE
	lds r16, P2X
	lds r17, P2Y

	rcall Load_X_Pointer
	rcall CALCULATE_POS

	ld r18,X
	cpi r18,1
	breq P2_DONE
	cpi r18,2
	breq P2_DONE
	ldi r16,2
	st X,r16
	rcall Check_for_end_of_game
P2_DONE:

	pop r17
	pop r16
	reti




Check_for_end_of_game:





	ret
