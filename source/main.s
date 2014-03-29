.section .init
.globl _start
_start:
	b main

.section .text
main:
	mov sp, #0x8000	@setup stack pointer to grow downward from 0x8000
	mov r0, #16	@GPIO pin 16
	mov r1, #0	@clear operation
	push {lr}
	bl set_gpio
	pop {lr}
loop$:
	b loop$

