; Address of HDMA table
!HdmaDataTable = $1853	; Must be in bank $7F (or whatever is set in !WaveTableBase)

; HDMA set up
!AffectedLayer = 2		; The layer which the HDMA affects.
!Scroll = 0				; 0 for horizontal waves, 1 for vertical waves
!Channel = 3			; The HDMA channel for the waves

; Waves set up
!Speed = $0040			; How fast the wave should move (value is internally divided by 256)
!Wavelength = $20		; How many scanlines until the waves repeat.
!Amplitude = $02		; How far the waves move. Set to $80 for inverted waves
!LayerHook = 3			; The layer where.
!WavesStart = $0104		; When should the waves appear (relative to the layer)
!Alternate = 0			; Set this to 1 so the waves alternate each scanline.

init:
	%InitWave(bgof2reg(!AffectedLayer, !Scroll), !Channel, Waves_HDMAPtrs)

main:
	LDA $9D
	ORA $13D4|!addr
	BEQ .Okay
RTL

.Okay:
	%RunWave(!Speed)
	%RangedWaves(!Wavelength, !Amplitude, !AffectedLayer, !Scroll, !LayerHook, !WavesStart, !Alternate*$80, !HdmaDataTable, 224)
RTL
