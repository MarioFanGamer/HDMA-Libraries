;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; HDMA Waves
;
; A simple code which enables waves. Can be horizontal
; or vertical
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;The base address of the data tables.
; Preferably bank bytes only because it would mess up the copying of data tables.
!WaveTableBase = $7F0000

; The default address for the HDMA data table
; It should be as large as 448 bytes
!DefHDMATable = $1853

; A define to enable SA-1 boosting so the code runs on SA-1.
; Make sure you change freeRAM so it uses BW-RAM i.e. banks $40 and $41
!EnableSA1Boosting = 0


; Just make sure it only gets truly enabled if you really use SA-1
; No need to edit it.
!EnableSA1Boosting #= !EnableSA1Boosting*!sa1

; Init code
; This one sets up HDMA for the waves.
; Input:
;   A: PPU register to affect
;	X: Channel of HDMA
;	Y: Bank of HDMA pointer table
;	$00: Address of HDMA pointer table
InitHdma:
	ORA #$0042			; One register, write twice
	STA $4300,x			;
	LDA $00				; Address of HDMA Table
	STA $4302,x			;
	SEP #$20			; A = 8-bit
	TYA					; Bank of HDMA table
	STA $4304,x			;
	LDA.b #!WaveTableBase>>16
	STA $4307,x			; Pointer bank byte (one reason why it's hardcoded)
	TXA					;
	LSR #4				; Divide channel number by 16.
	TAX					;
	LDA.l .BitFlags,x	;
	TSB $0D9F|!addr		;
RTL						;

.BitFlags:
db $01,$02,$04,$08,$10,$20,$40,$80

HDMAPtrs:
db $F0 : dw !DefHDMATable
db $F0 : dw !DefHDMATable+$E0


InitData:
RTL

; The calculation of a wave is the following formula:
; 
; Input:
; A (16-bit): The HDMA table
; X (8-bit): The amplitude
;
; $00: Wavelength * 2 (16-bit, should be smaller than 0x1C0, even numbers only)
; $02: Starting angle (24-bit, lowest byte = subangle)
; $05: Delta X pos (24-bit, lowest byte = subangle)
; $08: Layer offset
; $0C: Pointer of HDMA table
; $0E: Amount of data * 2
;
; Other scratch RAM:
; $8A: End of table
; $8C: Amplitude
CalculateWaves:
	STX $8A					; Store amplitude
if !EnableSA1Boosting
	SEP #$30
	%invoke_sa1(.sa1)
RTL

.sa1:
	REP #$30
	STZ $2250
endif
	LDA $0E					; Failsafe to write only as many bytes as possible
	CMP $00					; Basically: If the wavelength is larger than the height,
	BCS .Bigger				; use the height for the loop count
	STA $00					;
.Bigger:					;
	PHB						; Set data bank to current bank
	PHK						;
	PLB						;
	REP #$10				;
	LDX $0C					; Load pointer of HDMA table
	ASL $02					; Double starting position.
	LDA $04					; Double starting position (high byte)
	ROL						; and delta low byte
	AND #$FEFF				; Clear low bit of delta
	STA $04					;
	ROL $06					; Double rest of delta.
	LDY #$0000				; Initialise loop
.Loop:						;
	PHY						; Preserve loop count
	LDY $03					;
	LDA SineTable,y			; Get sine
if !EnableSA1Boosting		;
	STA $2251				; Multiplicand A
	LDA $8A					; Amplitude
	AND #$00FF				; Low byte only
	STA $2253				; Multiplicand B
	SEP #$20				; A = 8-bit
	LDA $05					; Add delta (subangle)
	CLC : ADC $02			;
	STA $05					;
	REP #$20				; A = 16-bit
	LDA $2307				; Get offset
else						;
	SEP #$20				; A = 8-bit
	STA $211B				; Multiplicand A
	XBA						;
	STA $211B				;
	LDA $8A					; Amplitude
	STA $211C				; Multiplicand B
	LDA $05					; Add delta (subangle)
	CLC : ADC $02			;
	STA $02					;
	REP #$20				; A = 16-bit
	LDA $2135				; Get offset
endif						;
	CLC : ADC $08			; Add with layer offset
	STA !WaveTableBase,x	; Y = !WaveTableBase
	TYA						; Get next angle
	ADC $06					; (Carry over from last calculation)
	AND #$01FE				;
	STA $03					;
	PLY						; Restore loop count
	INX #2					;
	INY #2					; Next value
	CPY $00					;
	BNE .Loop				;

	LDA $0E					; A is the data length - 1
	CLC : SBC $00			; (Which is height - wavelength - 1)
	BMI .LoopFinished		; Of course, if negative then there isn't anything to copy.
	TXY						; Y is the destination
	LDX $0C					; X is the source
	MVN !WaveTableBase>>16,!WaveTableBase>>16
.LoopFinished:
	PLB
RTL


SineTable:
dw $0000,$FFFA,$FFF3,$FFED
dw $FFE7,$FFE1,$FFDA,$FFD4
dw $FFCE,$FFC8,$FFC2,$FFBC
dw $FFB6,$FFB0,$FFAA,$FFA4
dw $FF9E,$FF98,$FF93,$FF8D
dw $FF87,$FF82,$FF7C,$FF77
dw $FF72,$FF6D,$FF68,$FF63
dw $FF5E,$FF59,$FF54,$FF4F
dw $FF4B,$FF47,$FF42,$FF3E
dw $FF3A,$FF36,$FF32,$FF2F
dw $FF2B,$FF28,$FF24,$FF21
dw $FF1E,$FF1B,$FF19,$FF16
dw $FF13,$FF11,$FF0F,$FF0D
dw $FF0B,$FF09,$FF08,$FF06
dw $FF05,$FF04,$FF03,$FF02
dw $FF01,$FF01,$FF00,$FF00
dw $FF00,$FF00,$FF00,$FF01
dw $FF01,$FF02,$FF03,$FF04
dw $FF05,$FF06,$FF08,$FF09
dw $FF0B,$FF0D,$FF0F,$FF11
dw $FF13,$FF16,$FF19,$FF1B
dw $FF1E,$FF21,$FF24,$FF28
dw $FF2B,$FF2F,$FF32,$FF36
dw $FF3A,$FF3E,$FF42,$FF47
dw $FF4B,$FF4F,$FF54,$FF59
dw $FF5E,$FF63,$FF68,$FF6D
dw $FF72,$FF77,$FF7C,$FF82
dw $FF87,$FF8D,$FF93,$FF98
dw $FF9E,$FFA4,$FFAA,$FFB0
dw $FFB6,$FFBC,$FFC2,$FFC8
dw $FFCE,$FFD4,$FFDA,$FFE1
dw $FFE7,$FFED,$FFF3,$FFFA
dw $0000,$0006,$000D,$0013
dw $0019,$001F,$0026,$002C
dw $0032,$0038,$003E,$0044
dw $004A,$0050,$0056,$005C
dw $0062,$0068,$006D,$0073
dw $0079,$007E,$0084,$0089
dw $008E,$0093,$0098,$009D
dw $00A2,$00A7,$00AC,$00B1
dw $00B5,$00B9,$00BE,$00C2
dw $00C6,$00CA,$00CE,$00D1
dw $00D5,$00D8,$00DC,$00DF
dw $00E2,$00E5,$00E7,$00EA
dw $00ED,$00EF,$00F1,$00F3
dw $00F5,$00F7,$00F8,$00FA
dw $00FB,$00FC,$00FD,$00FE
dw $00FF,$00FF,$0100,$0100
dw $0100,$0100,$0100,$00FF
dw $00FF,$00FE,$00FD,$00FC
dw $00FB,$00FA,$00F8,$00F7
dw $00F5,$00F3,$00F1,$00EF
dw $00ED,$00EA,$00E7,$00E5
dw $00E2,$00DF,$00DC,$00D8
dw $00D5,$00D1,$00CE,$00CA
dw $00C6,$00C2,$00BE,$00B9
dw $00B5,$00B1,$00AC,$00A7
dw $00A2,$009D,$0098,$0093
dw $008E,$0089,$0084,$007E
dw $0079,$0073,$006D,$0068
dw $0062,$005C,$0056,$0050
dw $004A,$0044,$003E,$0038
dw $0032,$002C,$0026,$001F
dw $0019,$0013,$000D,$0006

