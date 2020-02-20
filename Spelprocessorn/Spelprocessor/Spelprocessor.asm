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
	ldi r16,(1<<ISC11)|(0<<ISC10)|(1<<ISC01)|(0<<ISC00)
	out MCUCR,r16
	ldi r16,(1<<INT0)|(1<<INT1)
	out GICR,r16

	ldi r16,$FF
	out PORTD,r16

	sei
Main:
	
	rcall Player_Input;
	rcall Delay
	rjmp Main

//Player 1 = t 0, Player 2 = t 1
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


//Player 1
Interrupt0:
	brts P1_DONE
	rcall Check_for_valid_choice_P1
	rcall Check_for_end_of_game
P1_DONE:

	reti

//Player 2
Interrupt1:
	brtc P2_DONE
	rcall Check_for_valid_choice_P2
	rcall Check_for_end_of_game
P2_DONE:


	reti




Check_for_end_of_game:





	ret


Check_for_valid_choice_P1:



	ret

Check_for_valid_choice_P2:


	ret