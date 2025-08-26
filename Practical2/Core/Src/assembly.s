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

@ Main loop with button checks and LED updates
main_loop:
// Task 5
@ When SW3 is held down, freeze pattern
    LDR R3, GPIOA_BASE 		@ Get address of GPIO A and read into R3
    LDR R4, [R3, #0x10]     @ Reads Input Data Register (IDR) to R4
	MOVS R7, #8 @ Mask for bit 3 (SW3)
	ANDS R7, R4 @ Test if bit 3 is set
	BEQ SW3_loop            @ Freeze if SW3 pressed

// Task 4
@ When SW2 is pressed, set pattern to 0xAA
    MOVS R7, #4 @ Mask for bit 2 (SW2)
	ANDS R7, R4 @ Test if bit 2 is set
    BNE no_SW2
    MOVS R2, #0xAA			@ Sets LED register R2 to pattern 0xAA
    B write_leds			@ Goes straight to writing the LEDs
no_SW2:

// Task 1
@ Write LEDs and apply delay (increment by 1 every 0.7s)
	STR R2, [R1, #0x14]     @ Write R2 to GPIOB_ODR

// Task 3
@ Check SW1 (0.3s vs 0.7s delay)
	MOVS R7, #2 @ Mask for bit 1 (SW1)
	ANDS R7, R4 @ Test if bit 1 is set
	BEQ delay_short
	BL delay_long           @ Default 0.7s delay
	B post_delay
delay_short:
	LDR R3, SHORT_DELAY_CNT
delay_loop_short:
	SUBS R3, R3, #1
	BNE delay_loop_short
	B post_delay

delay_long:
	LDR R3, LONG_DELAY_CNT
delay_loop_long:
	SUBS R3, R3, #1
	BNE delay_loop_long
	BX LR

post_delay:


// Task 2
@ When SW0 is pressed, increment by 2
	MOVS R5, #1 @ Default increment by 1
    MOVS R7, #1 @ Mask for bit 0 (SW0)
	ANDS R7, R4 @ Test if bit 0 is set
    BNE no_SW0
    MOVS R5, #2        @ If pressed, increment by 2
no_SW0:
ADDS R2, R2, R5         @ Apply increment
B main_loop



SW3_loop:
	LDR R4, [R3, #0x10]     @ Re-read GPIOA_IDR
	LSLS R7, R4, #28        @ Test SW3
	BEQ SW3_loop            @ Stay frozen
	B main_loop

write_leds:
	STR R2, [R1, #0x14]     @ Write to LEDs
	B main_loop

@ LITERALS; DO NOT EDIT
	.align
RCC_BASE: 			.word 0x40021000
AHBENR_GPIOAB: 		.word 0b1100000000000000000
GPIOA_BASE:  		.word 0x48000000
GPIOB_BASE:  		.word 0x48000400
MODER_OUTPUT: 		.word 0x5555

@ TODO: Add your own values for these delays
@ Delay constants
LONG_DELAY_CNT: 	.word 0x1C71C7  @ ~0.7s at 8 MHz
SHORT_DELAY_CNT: 	.word 0x0C3500  @ ~0.3s at 8 MHz
