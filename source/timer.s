.globl get_curr_timestamp
.globl delay

@get current timestamp from system timer which increments at 1MHz
@timestamp will be stored in r0 (least significant) and r1 (most significant)
get_curr_timestamp:
	ldr r2, =0x20003000
	ldrd r0, r1, [r2, #4] 
	mov pc, lr

@delay in seconds. r0 stores the second
@this function is subject to wraparound bug
delay:
	@compute the timestamp
	push {r4}
	push {r5}
	mov r4, r0
	ldr r5, =1000000
	umull r4, r5, r4, r5
	push {lr}
	bl get_curr_timestamp
	pop {lr}
	adds r4, r0
	adc r5, r1
busy_loop$:
	push {lr}
	bl get_curr_timestamp
	pop {lr}
	@ break from loop if (r1 > r5) or ((r1 == r5) and (r0 >= r4))
	cmp r5, r1
	cmpeq r4, r0
	bhi busy_loop$
	pop {r5}
	pop {r4}
	mov pc, lr
