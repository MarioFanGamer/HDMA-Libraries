; A test file which displays both a scrollable gradient and vertical waves on layer 1 and 2.
; To be inserted as a level.

!FreeRAM_GradBank = $7F		;\
!FreeRAM_RedGreen = $1343	; | Just to note: These all belong together. That means, these addresses aren't supposed to be converted if you use SA-1
!FreeRAM_Blue = $16A3		;/

!Layer = 1			; The layer in which the HDMA is rooted.
!Offset = $0000		; How much is the table shifted
!ScrollFactor = 0	; The division is exponential, using 2 as its base.

; Address of HDMA table
!HdmaDataTable = $1853	; Must be in bank $7F (or whatever is set in !WaveTableBase)

; HDMA set up
!AffectedLayer1 = 1		; The layer which the HDMA affects.
!Scroll1 = 1				; 0 for horizontal waves, 1 for vertical waves
!Channel1 = 5			; The HDMA channel for the waves

; HDMA set up
!AffectedLayer2 = 2		; The layer which the HDMA affects.
!Scroll2 = 1				; 0 for horizontal waves, 1 for vertical waves
!Channel2 = 6			; The HDMA channel for the waves

; Waves set up
!Speed = $0040			; How fast the wave should move (value is internally divided by 256)
!Wavelength = $20		; How many scanlines until the waves repeat.
!Amplitude = $02		; How far the waves move. Set to $80 for inverted waves
!Alternate = 0			; Set this to 1 so the waves alternate each scanline.


!DataTable1 = !HdmaDataTable	; Data of first table
!DataTable2 = !DataTable1+448	; Data of second table

init:
   LDA #$17    ;\  BG1, BG2, BG3, OBJ on main screen (TM)
   STA $212C   ; | 
   LDA #$00    ; | 0 on main screen should use windowing. (TMW)
   STA $212E   ;/  
   LDA #$00    ;\  0 on sub screen (TS)
   STA $212D   ; | 
   LDA #$00    ; | 0 on sub screen should use windowing. (TSW)
   STA $212F   ;/  
   LDA #$37    ; BG1, BG2, BG3, OBJ, Backdrop for color math
   STA $40     ;/  mirror of $2131

	REP #$10
	LDX.w #Gradient
	STX $00
	LDA.b #Gradient>>16
	STA $02

	LDA.b #!FreeRAM_GradBank
	LDX.w #!FreeRAM_RedGreen
	LDY.w #!FreeRAM_Blue

	JSL ScrollHDMA_init

	%InitWave(bgof2reg(!AffectedLayer1, !Scroll1), !Channel1, Waves_HDMAPtrs)
	%InitWave(bgof2reg(!AffectedLayer2, !Scroll2), !Channel2, HDMAPtrs2)

main:
	LDA $9D
	ORA $13D4|!addr
	BEQ .Okay
RTL

.Okay:
	%RunWave(!Speed)
	WDM
	%WaveStoreOffset(!AffectedLayer1)
	%CallWave(!Wavelength, !Amplitude, 0, bgof2addr(!AffectedLayer1, !Scroll1), !Alternate*$80, !DataTable1, 224)
	WDM
	%WaveStoreOffset(!AffectedLayer2)
	%CallWave(!Wavelength, !Amplitude, 0, bgof2addr(!AffectedLayer2, !Scroll2), !Alternate*$80, !DataTable2, 224)
RTL

nmi:
	REP #$20

	LDA #!FreeRAM_RedGreen
	STA $00
	LDA #!FreeRAM_Blue
	STA $02

	LDA $1C+((!Layer-1)<<2)
	SEC : SBC.w #!Offset
	LSR #!ScrollFactor
	JML ScrollHDMA_main

Gradient:
db $80,$20,$40,$80
db $4C,$20,$40,$80
db $05,$21,$40,$80
db $05,$22,$40,$80
db $04,$23,$41,$80
db $05,$24,$41,$80
db $05,$25,$41,$80
db $05,$26,$41,$80
db $05,$27,$41,$80
db $04,$28,$42,$80
db $05,$29,$42,$80
db $05,$2A,$42,$81
db $05,$2B,$42,$81
db $05,$2C,$42,$81
db $01,$2D,$42,$81
db $03,$2D,$43,$81
db $05,$2E,$43,$81
db $05,$2F,$43,$81
db $05,$30,$43,$81
db $05,$31,$43,$81
db $01,$32,$43,$81
db $04,$32,$44,$81
db $04,$33,$44,$81
db $06,$34,$44,$81
db $04,$34,$45,$81
db $02,$35,$45,$81
db $07,$35,$46,$81
db $03,$35,$47,$81
db $03,$36,$47,$81
db $06,$36,$48,$81
db $04,$36,$49,$81
db $03,$37,$49,$81
db $06,$37,$4A,$81
db $04,$37,$4B,$81
db $02,$38,$4B,$81
db $06,$38,$4C,$81
db $05,$38,$4D,$81
db $02,$39,$4D,$81
db $06,$39,$4E,$81
db $04,$39,$4F,$81
db $02,$3A,$4F,$81
db $06,$3A,$50,$81
db $05,$3A,$51,$81
db $02,$3B,$51,$81
db $04,$3B,$52,$81
db $02,$3B,$52,$82
db $05,$3B,$53,$82
db $01,$3C,$53,$82
db $07,$3C,$54,$82
db $05,$3C,$55,$82
db $01,$3D,$55,$82
db $06,$3D,$56,$82
db $06,$3D,$57,$82
db $07,$3E,$58,$82
db $05,$3E,$59,$82
db $00

HDMAPtrs2:
db $F0 : dw !DataTable2
db $F0 : dw !DataTable2+$E0
db $00
