/*
 * assembly.s
 *
 */
 
 @ DO NOT EDIT
	.syntax unified
    .text
    .global ASM_Main
    .thumb_func

@ DO NOT EDIT
vectors:
	.word 0x20002000
	.word ASM_Main + 1

@ DO NOT EDIT label ASM_Main
ASM_Main:

	@ Some code is given below for you to start with
	LDR R0, RCC_BASE  		@ Enable clock for GPIOA and B by setting bit 17 and 18 in RCC_AHBENR
	LDR R1, [R0, #0x14]
	LDR R2, AHBENR_GPIOAB	@ AHBENR_GPIOAB is defined under LITERALS at the end of the code
	ORRS R1, R1, R2
	STR R1, [R0, #0x14]

	LDR R0, GPIOA_BASE		@ Enable pull-up resistors for pushbuttons
	MOVS R1, #0b01010101
	STR R1, [R0, #0x0C]
	LDR R1, GPIOB_BASE  	@ Set pins connected to LEDs to outputs
	LDR R2, MODER_OUTPUT
	STR R2, [R1, #0]
	MOVS R2, #0         	@ NOTE: R2 will be dedicated to holding the value on the LEDs

@ TODO: Add code, labels and logic for button checks and LED patterns

main_loop:

    LDR R3, GPIOA_BASE 		@ Get address of GPIO A and read into R3
    LDR R4, [R3, #0x10]     @ Reads Input Data Register (IDR) to R4

// Task 2
@ When SW0 is pressed, increment by 2
    LSLS R7, R4, #31        @ Reads shifted R4 to R7 to retrieve button 0 state
    BNE no_SW0
    MOVS R5, #2 			@ Sets R5 to value 2 (used R5 as the register for storing the increments)
no_SW0:

// Task 4
@ When SW2 is pressed, set pattern to 0xAA
    LSLS R7, R4, #29        @ Reads shifted R4 to R7 to retrieve button 2 state
    BNE no_SW2
    MOVS R2, #0xAA			@ Sets LED register R2 to pattern 0xAA
    B write_leds			@ Goes straight to writing the LEDs
no_SW2:

write_leds:
	STR R2, [R1, #0x14]
	B main_loop

@ LITERALS; DO NOT EDIT
	.align
RCC_BASE: 			.word 0x40021000
AHBENR_GPIOAB: 		.word 0b1100000000000000000
GPIOA_BASE:  		.word 0x48000000
GPIOB_BASE:  		.word 0x48000400
MODER_OUTPUT: 		.word 0x5555

@ TODO: Add your own values for these delays
LONG_DELAY_CNT: 	.word 800000     @ ~0.7s
SHORT_DELAY_CNT: 	.word 300000     @ ~0.3s
