; Address of HDMA table
!HdmaDataTable = $1853	; Must be in bank $7F (or whatever is set in !WaveTableBase)

; HDMA set up
!AffectedLayer = 1		; The layer which the HDMA affects.
!Scroll = 0				; 0 for horizontal waves, 1 for vertical waves
!Channel = 3			; The HDMA channel for the waves

; Waves set up
!Speed = $0033			; How fast the wave should move (value is internally divided by 256)
!Wavelength = $20		; How many scanlines until the waves repeat.
!Amplitude = $01		; How far the waves move. Set to $80 for inverted waves
!Alternate = 0			; Set this to 1 so the waves alternate each scanline.

init:
	%InitWave(bgof2reg(!AffectedLayer, !Scroll), !Channel, Waves_HDMAPtrs)

main:
	LDA $9D
	ORA $13D4|!addr
	BEQ HandleWaves
RTL

HandleWaves:
	%RunWave(!Speed)
	%WaveStoreOffset(!AffectedLayer)
	%CallWave(!Wavelength, !Amplitude, 0, bgof2addr(!AffectedLayer, !Scroll), !Alternate*$80, !HdmaDataTable, 224)
RTL
