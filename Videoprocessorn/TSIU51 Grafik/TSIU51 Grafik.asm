/*
 * TSIU51_Grafik.asm
 *
 *  Created: 2020-02-10 10:32:08
 *   Author: linny471
 */ 
 .org 0x00
	jmp START

 .org 0x014
	jmp GET_BYTE


 .dseg
 .org 0x300
 VIDEO_MEM: .byte 64 ;1-64 corresponds to the 64 diods on DAmatrix
 MEM_POS: .byte 1 ;Current position in VIDEO_MEM
 SEND_BUFF: .byte 1 ;SPI send-buffer


 .cseg


START:
	ldi r16,high(RAMEND)
	out SPH,r16

	ldi r16,low(RAMEND)
	out SPL,r16	

	call INIT

INIT_MEM:
;//Clear memory pointer and SPI buffer
	clr r16
	sts MEM_POS, r16
	sts SEND_BUFF, r16

MAIN:
	
	lds r16,SEND_BUFF
	out SPDR, r16

WAIT:
	jmp WAIT





INIT:
;//SPI initalization
	ldi r16, 0xB0
	out DDRB, r16

	ldi r16,(1<<SPE | 1<<MSTR | 1<<SPIE | 1<<SPR0 | 1<<SPR1)
	out SPCR, r16

	sei
	ret


GET_BYTE:
;//Reads current video memory position value and stores it in SEND_BUFF
	push r16
	in r16, SREG
	push r16

	ldi ZH, high(VIDEO_MEM)
	ldi ZL, low(VIDEO_MEM)

	lds r16, MEM_POS
	add ZL, r16

	ld r16, Z
	sts SEND_BUFF, r16

	pop r16
	out SREG, r16
	pop r16
	reti
	


DELAY:
; Delay 2 000 cycles
; 2ms at 1.0 MHz

    ldi  r18, 3
    ldi  r19, 152
L1: dec  r19
    brne L1
    dec  r18
    brne L1
    nop

	ret