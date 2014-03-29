.section .init
.globl _start
_start:
	b main

.section .text
main:
	mov sp, #0x8000	@setup stack pointer to grow downward from 0x8000
	mov r4, #0
loop$:
	mvn r4, r4	@toggle itself
	mov r0, #16	@GPIO pin 16
	mov r1, r4	@clear or set
	push {lr}
	bl set_gpio
	pop {lr}
	push {lr}
	mov r0, #1	@delay for 1 second
	bl delay
	pop {lr}
	b loop$

