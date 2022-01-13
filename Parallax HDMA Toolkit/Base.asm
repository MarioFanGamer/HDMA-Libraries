!ParallaxLayer = 2		; Which layer is affected by the HDMA

!DisableHdmaAtGoal = 1	; HDMA and IRQ don't mix very well

init:
	LDA bgof2reg(!ParallaxLayer, 0)
	JSL ParallaxToolkit_init

main:
	if !DisableHdmaAtGoal
		LDA $1493|!addr
		BEQ +
		LDA #$20
		TRB $0D9F|!addr
	RTL
	
	+
	endif

	REP #$20
	LDA $14
	AND #$00FF
	ASL
	STA $08
	LDA $1A
	STA $0A
	LDA bgof2addr(!ParallaxLayer, 0)
	STA $0C

if !sa1
	SEP #$20
	%invoke_sa1(sa1)
RTL

sa1:
endif
	REP #$20
	LDA.w #ScrollVal
	LDX.b #ScrollVal>>16
	JSL ParallaxToolkit_main
RTL

; The format of the table is specified in the readme
ScrollVal:
; db $aa : dw $bbbb,$cccc
