; Default addresses for scrollable HDMA gradients.
!ScrollDefBank = $7F		; The bank of the HDMA data tables
!ScrollDefRedGreen = $1343	; The address for the red-green table
!ScrollDefBlue = $1943		; The address for the blue table

; Initialises the gradient by decompressing it and sets up HDMA table.
; gradient_ptr is the address of the compressed HDMA table.
macro ScrollHdmaInit(gradient_ptr)
	PHP							; Preserve register sizes
	REP #$10					; XY = 16-bit
	LDX.w #<gradient_ptr>		; Get address of gradient
	STX $00						;
	LDA.b #<gradient_ptr>>>16	; Get bank of gradient
	STA $02						;
								;
	LDA.b #!ScrollDefBank		; Load bank of data tables
	LDX.w #!ScrollDefRedGreen	; Load address of red-green table
	LDY.w #!ScrollDefBlue		; Load address of blue table
								;
	JSL ScrollHDMA_init			; Decompress and set up HDMA!
	PLP							; Restore register sizes
endmacro


; Calls the main code of the HDMA table
macro ScrollHdmaMain(layer, offset, factor)
	PHP							; Preserve register sizes
	REP #$20					; A = 16-bit
								;
	LDA #!ScrollDefRedGreen		; Get address of red-green table
	STA $00						;
	LDA #!ScrollDefBlue			; Get address of blue table
	STA $02						;
								;
if <layer>						;
	LDA bgof2addr(<layer>, 0)	; Get layer offset
	CLC : ADC.w #<offset>		; Add it with offset
	if <factor> > 0				;
		LSR #<factor>			; Shift by N bytes
	elseif < 0					;
		ASL #-<factor>			; Shift by N bytes
	endif						;
else							;
	LDA.w #<offset>				; Get direct offset.
endif							;
	JSL ScrollHDMA_main			; Change pointers
	PLP							; Restore register sizes
endmacro


; Mostly the same as above with the difference that the speed
; can be divided by any value and not just powers of two.
macro ScrollHdmaDiv(layer, offset, divisor)
	PHP							; Preserve register sizes
	REP #$20					; A = 16-bit
								;
	LDA bgof2addr(<layer>, 0)	; Get layer offset
	CLC : ADC.w #<offset>		; Add it with offset
	STA $4204					; Dividend
	LDX.b #<divisor>			; Now divide it by a value!
	STX $4206					;
								;
	LDA.w #!ScrollDefRedGreen	; Get address of red-green table (+ 3 cycles)
	STA $00						; (+ 4 cycles)
	LDA.w #!ScrollDefBlue		; Get address of blue table (+ 3 cycles)
	STA $02						; (+ 4 cycles)
								;
	LDA $4214					; Get new offset! (+ 3 cycles)
	JSL ScrollHDMA_main			; Change pointers
	PLP							; Restore register sizes
endmacro
