/*
 * Display.asm
 *
 *  Created: 2020-02-21 09:47:27
 *   Author: linny471
 */ 

 .def loop_counter = r17

.org 0x00
	jmp START

.org 0x014
	jmp SEND 

.dseg
	.org 0x300
	SEND_BYTE: .byte 4
	SEND_BUFF: .byte 1
	LOOP: .byte 1


.cseg
START:
	ldi r16,high(RAMEND)
	out SPH,r16

	ldi r16,low(RAMEND)
	out SPL,r16	

	call INIT

MEMORY_INIT:
	clr r16
	sts LOOP, r16
	;ldi r16, 0x01
	sts SEND_BUFF, r16
	sts SEND_BYTE + 1, r16
	sts SEND_BYTE + 2, r16
	sts SEND_BYTE + 3, r16

RESET_PTR:
	ldi ZH, high(SEND_BYTE +1)
	ldi ZL, low(SEND_BYTE +1)
	clr r16
	sts LOOP, r16

MAIN:
	clt
	lds r16, LOOP
	cpi r16, 0x03
	breq RESET_PTR

	ldi XL, low(SEND_BUFF)
	ldi XH, high(SEND_BUFF)
	ld r16, X
	out SPDR, r16

	WAIT:
		brts MAIN
		jmp WAIT



SEND:
	push r16
	in r16, SREG
	push r16
	
	ld r16, Z++
	sts SEND_BUFF, r16

	lds r16, LOOP
	inc r16
	sts LOOP, r16

	pop r16
	out SREG, r16
	pop r16
	set
	reti

DELAY:
; Delay 999 cycles
; 999us 0 0/1 ns
; at 1.0 MHz

    ldi  r18, 2
    ldi  r19, 75

L1: dec  r19
    brne L1
    dec  r18
    brne L1
    nop
	ret

INIT:
;//SPI initalization
	ldi r16, 0xB0
	out DDRB, r16

	ldi r16,(1<<SPE | 1<<MSTR | 1<<SPIE | 1<<SPR0)
	out SPCR, r16
	ldi r16,(1<<SPI2X)
	;out SPSR, r16

	sei
	ret