/*
 * Spelprocessor.asm
 *
 *  Created: 2020-02-04 09:29:40
 *   Author: lincl896
 */ 

 // Main filen
.include "Joystick_driver.asm"

.equ VMEM_SIZE = 64


.dseg
.org SRAM_START
P1X: .byte	1; Player 1 X position
P1Y: .byte	1; Player 1 Y position
P2X: .byte	1; Player 2 X position
P2Y: .byte	1; Player 2 Y position

VMEM: .byte VMEM_SIZE

.cseg

Setup:





	

Hardware_Init:





	






Main:
	
	rcall Player_Input;

	rjmp Main


Player_Input:




	ret


