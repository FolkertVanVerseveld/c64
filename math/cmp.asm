// Assembler: KickAssembler 4.4
// source: http://www.6502.org/tutorials/compare_beyond.html

.var num1 = $60
.var num1l = $60
.var num1m = $61
.var num1h = $62
.var num2 = $63
.var num2l = $63
.var num2m = $64
.var num2h = $65

// branch if num1 <= num2

	lda num1
	cmp num2
	bcc !label+
	beq !label+
	brk // num1 > num2
!label:
	brk // num1 <= num2

// branch if num2 >= num1
// this is equivalent to num1 <= num2 but faster and shorter

	lda num2
	cmp num1
	bcs !label+
	brk // num1 < num2
!label:
	brk // num2 >= num1

// 4.1 COMPARING ONE BYTE AT A TIME

// Example 4.1.1: a 16-bit unsigned comparison which branches to LABEL2 if NUM1 < NUM2

	lda num1h
	cmp num2h
	bcc !label2+ // if num1h < num2h then num1 < num2
	bne !label1+ // if num1h <> num2h then num1 > num2
	lda num1l
	cmp num2l
	bcc !label2+ // if num1l < num2l then num1 < num2
!label1:
	brk // num1 >= num2
!label2:
	brk // num1 < num2

// Example 4.1.2: a 16-bit unsigned comparison which branches to LABEL2 if NUM1 >= NUM2

	lda num1h  // compare high bytes
	cmp num2h
	bcc !label1+ // if num1h < num2h then num1 < num2
	bne !label2+ // if num1h <> num2h then num1 > num2 (so num1 >= num2)
	lda num1l  // compare low bytes
	cmp num2l
	bcs !label2+ // if num1l >= num2l then num1 >= num2
!label1:
	brk // num1 < num2
!label2:
	brk // num1 >= num2

// Example 4.1.3: a 24-bit unsigned comparison which branches to LABEL2 if NUM1 < NUM2

	lda num1h  // compare high bytes
	cmp num2h
	bcc !label2+ // if num1h < num2h then num1 < num2
	bne !label1+ // if num1h <> num2h then num1 > num2 (so num1 >= num2)
	lda num1m  // compare middle bytes
	cmp num2m
	bcc !label2+ // if num1m < num2m then num1 < num2
	bne !label1+ // if num1m <> num2m then num1 > num2 (so num1 >= num2)
	lda num1l  // compare low bytes
	cmp num2l
	bcc !label2+ // if num1l < num2l then num1 < num2
!label1:
	brk // num1 >= num2
!label2:
	brk // num1 < num2

// Example 4.1.4: a 24-bit unsigned comparison which branches to LABEL2 if NUM1 >= NUM2

	lda num1h  // compare high bytes
	cmp num2h
	bcc !label1+ // if num1h < num2h then num1 < num2
	bne !label2+ // if num1h <> num2h then num1 > num2 (so num1 >= num2)
	lda num1m  // compare middle bytes
	cmp num2m
	bcc !label1+ // if num1m < num2m then num1 < num2
	bne !label2+ // if num1m <> num2m then num1 > num2 (so num1 >= num2)
	lda num1l  // compare low bytes
	cmp num2l
	bcs !label2+ // if num1l >= num2l then num1 >= num2
!label1:
	brk
!label2:
	brk
