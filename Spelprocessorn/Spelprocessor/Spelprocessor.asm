/*
 * Spelprocessor.asm
 *
 *  Created: 2020-02-04 09:29:40
 *   Author: lincl896
 */ 

 // Main filen

.include "Joystick_driver.asm"
.include "game_logic.asm"
.equ VMEM_SIZE = 64
.equ DELAY_HIGH = 200 ;100 blir bra
.equ DELAY_LOW = 0
.equ BEEP_LENGTH_H = $0f
.equ BEEP_LENGTH_L = $00

.dseg
.org SRAM_START
P1X: .byte	1; Player 1 X position
P1Y: .byte	1; Player 1 Y position
P2X: .byte	1; Player 2 X position
P2Y: .byte	1; Player 2 Y position

Start_Byte: .byte 1
Command_Byte: .byte 1
Argument1_byte: .byte 1
Argument2_byte: .byte 1

Player1_Score: .byte 1
Player2_Score: .byte 1

Win: .byte 1 ; Player1 =  1, Player2 = 2

DEBUG: .byte 5

VMEM: .byte VMEM_SIZE

.cseg
.org $0000
	rjmp Setup
.org INT0addr
	rjmp Interrupt0
.org INT1addr
	rjmp Interrupt1
Setup:

	ldi r16,HIGH(RAMEND)
	out SPH,r16
	ldi r16,LOW(RAMEND)
	out SPL,r16

	

Hardware_Init:

	rcall Joystick_Init
	ldi r16,(1<<ISC11)|(0<<ISC10)|(1<<ISC01)|(0<<ISC00)
	out MCUCR,r16
	ldi r16,(1<<INT0)|(1<<INT1)
	out GICR,r16

	ldi r16,0b11100000
	out DDRD,r16
	ldi r16,0b00011111
	out PORTD,r16

	ldi r16,0b00000001
	out DDRB,r16

Usart_Init:
	; Se sida 143 i databladet
	
	; Set baud rate
	clr r17
	ldi r16,$0c
	out UBRRH,r17
	out UBRRL,r16
	
	; Enable receiver and transmitter
	ldi r16,(1<<TXEN)
	out UCSRB,r16

	ldi r16,(1<<U2X)
	out UCSRA,r16

	
	; Set frame format: 8data, 1stop bit
	ldi r16,(1<<URSEL)|(3<<UCSZ0)
	out UCSRC,r16
	
	sei

SRAM_Init:
	; start byte config
	ldi r16,$ff
	sts Start_Byte,r16
	clr r16
	sts Player1_Score,r16
	sts Player2_Score,r16
	sts Win,r16
	; Clear board
	rcall Clear_Board

Main:	
	rcall Player_Input;
	rcall Delay
	rjmp Main

SendByte:
	; Se sida 144 i databladet
	
	; Wait for empty transmit buffer
	sbis UCSRA,UDRE
	rjmp SendByte
	
	; Put data (r16) into buffer, sends the data
	out UDR,r16
	
	ret

Send_Data:
	push r16
	lds r16,Start_Byte
	rcall SendByte		; Start of message

	lds r16,Command_Byte
	rcall SendByte		; message type: 0 if player selects, 1 if player 1 selects

	lds r16,Argument1_Byte
	rcall SendByte		; X-value

	lds r16,Argument2_Byte
	rcall SendByte		; Y-value
	pop r16
	ret

//Player 1 = t 0, Player 2 = t 1
Player_Input:
	cli
	push r17
	brts Player2
Player1:
	ldi r16,0b11000000
	out PORTA,r16
	ldi r16,0b11111111
	out PORTD,r16	

	rcall Input_P1
	ldi r17,$00
	rjmp Input_done
Player2:
	ldi r16,0b01111111
	out PORTD,r16
	ldi r16,0b11100000
	out PORTA,r16	

	rcall Input_P2
	ldi r17,$01
Input_done:
	rcall Send_Player_Choice
	rcall Send_Data
	pop r17
	sei
	ret


DELAY:
	ldi r25,DELAY_HIGH
	ldi r24,DELAY_LOW

DELAY2:
	sbiw r24,1
	brne DELAY2
	ret

Load_X_Pointer:
	ldi XH,HIGH(VMEM)
	ldi XL,LOW(VMEM)
	ret

Calculate_Pos:
	push r16
	push r17
	add XL,r16
	lsl r17
	lsl r17
	lsl r17
	adc XL,r17
	pop r17
	pop r16
	ret

//Player 1 joystick push button interrupt
Interrupt0:
	push r16
	push r17

	brts P1_DONE
	lds r16,P1X
	lds r17,P1Y

	rcall Load_X_Pointer
	rcall Calculate_Pos

	ld r17,X
	cpi r17,1
	breq P1_DONE
	cpi r17,2
	breq P1_DONE
	rcall BEEP
	ldi r17,1
	st X,r17
	ldi r17,2
	rcall Send_Player_Choice
	rcall Send_Data
	rcall Check_for_end_of_game
	set
P1_DONE:
	
	pop r17
	pop r16
	reti

//Player 2 joystick push button interrupt
Interrupt1:
	push r16
	push r17
	brtc P2_DONE
	lds r16,P2X
	lds r17,P2Y
	
	rcall Load_X_Pointer
	rcall CALCULATE_POS

	ld r17,X
	cpi r17,1
	breq P2_DONE
	cpi r17,2
	breq P2_DONE
	rcall BEEP
	ldi r17,2
	st X,r17
	ldi r17,3
	rcall Send_Player_Choice
	rcall Send_Data
	rcall Check_for_end_of_game
	clt
P2_DONE:
	
	pop r17
	pop r16
	reti

Send_Player_Choice:
	sts Command_Byte,r17
	brts Send_Player_2

Send_Player_1:
	lds r17,P1X
	sts Argument1_Byte,r17
	lds r17,P1Y
	sts Argument2_Byte,r17
	rjmp Send_Done

Send_Player_2:
	
	lds r17,P2X
	sts Argument1_Byte,r17
	lds r17,P2Y
	sts Argument2_Byte,r17

Send_Done:

	ret




BEEP:
	push r16
	push r17
	in r17,SREG

	ldi r16,0b00000001
	out PORTB,r16
	push r24
	push r25
	ldi r24,BEEP_LENGTH_L
	ldi r25,BEEP_LENGTH_H
	rcall DELAY2
	pop r25
	pop r24

BEEP_DONE:
	ldi r16,0b00000000
	out PORTB,r16
	out SREG,r17
	pop r17
	pop r16
	ret