.globl get_gpio_addr
.globl set_gpio_func
.globl set_gpio

get_gpio_addr:
	ldr r0, =0x20200000
	mov pc, lr

@Set GPIO function select. This function expects r0 as argument for pin number
@and r1 as argument for pin function (0 for input, 1 for output)
set_gpio_func:
	@check input for correctness
	cmp r0, #53
	cmpls r1, #7
	movhi pc, lr
	mov r2, r0	@save gpio pin in r2
	push {lr}	
	bl get_gpio_addr @r0 contains base address of GPIO after this
	pop {lr}
	@each GPIO function select register is a bank of GPIO pins, calculate offset
	@of GPIO function select register
offset_loop$:
	cmp r2, #9
	subhi r2, #10
	addhi r0, #4
	bhi offset_loop$
	@to get the right offset within the register, we must (r1 << (r2 * 3))
	add r2, r2, lsl #1 @r2 + (r2 << 1) = r2 * 3
	lsl r1, r2
	@masking using  r1 | ~(111b << r2)
	mov r3, #7
	mvn r3, r3, lsl r2
	orr r1, r3
	@gpio_reg = gpio_reg & r1
	ldr r2, [r0]
	and r1, r2
	str r2, [r0]
	mov pc, lr	

@This function set or clear GPIO output pin depending on the value passed
@r0 is the GPIO pin
@r1 is the value for the GPIO pin, non-zero to set, 0 to clear
set_gpio:
	pin_num .req r0
	pin_val .req r1
	@check gpio pin is correct
	cmp pin_num, #53
	movhi pc, lr
	@ensure that pin number and pin value is preserved across function call
	push {r4}
	push {r5}
	mov r4, pin_num
	mov r5, pin_val
	.unreq pin_num
	.unreq pin_val
	pin_num .req r4
	pin_val .req r5
	push {lr}
	mov r1, #1	@ensure that GPIO pin is set as output pin
	bl set_gpio_func
	bl get_gpio_addr
	pop {lr}
	gpio_bank .req r0
	@select the right bank of register depending on clear or set operation
	cmp pin_val, #0
	addeq gpio_bank, #0x28	@output clear register
	addne gpio_bank, #0x1c	@output set register
	@calculate offset for the bank based on 4 * (pin_num >> 5) = (pin_num >> 5) << 2
	mov r1, pin_num, lsr #5
	add gpio_bank, r1, lsl #2
	@to set the right bit, mask out the least significant 5 bits and left shift
	lsl pin_num, #27
	lsr pin_num, #27
	mov r1, #1
	lsl r1, pin_num
	str r1, [gpio_bank]
	.unreq pin_num
	.unreq pin_val
	.unreq gpio_bank
	pop {r5}
	pop {r4}
	mov pc, lr
