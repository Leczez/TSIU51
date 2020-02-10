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

ldi r16,HIGH(RAMEND)
out SPH,r16
ldi r16,LOW(RAMEND)
out SPL,r16

	

Hardware_Init:

	rcall Joystick_Init



	sei
Main:
	
	rcall Player_Input;
	rcall Delay
	rjmp Main


Player_Input:

	brts Player2	
	rcall Input_P1
	rjmp Input_done
Player2:
	rcall Input_P2
Input_done:
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



Interrupt0:





	reti


Interrupt1:


	reti