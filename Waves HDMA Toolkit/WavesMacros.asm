!WaveTableBase = $7F0000
!WaveOffset = $13E6|!addr

; Converts the layer and direction into the corresponding register
function bgof2reg(layer, dir) = (((layer-1)&3)<<1)+(dir&1)+$D
; Converts the layer and direction into the corresponding address
function bgof2addr(layer, dir) = ((((layer-1)&3)<<1)+(dir&1))*2+$1A

; Call this in the level init code.
macro InitWave(reg, channel, table_src)
	PHP						; Preserve processor flags
	SEP #$10				; XY = 8-bit
	REP #$20				; A = 16-bit
	LDA.w #<table_src>		; Get pointer table address
	STA $00					;
	LDY.b #<table_src>>>16	; Get pointer table bank.
	LDX.b #<channel><<4		; HDMA channel
	LDA.w #<reg><<8			; Register
	JSL Waves_InitHdma		;
	PLP						; Restore processor flags
endmacro

macro InitWaveOffset(value)
if <value>
	LDA.b #<value>
	STA !WaveOffset
	LDA.b #<value>>>8
	STA !WaveOffset+1
else
	STZ !WaveOffset
endif
endmacro

; Increments !WaveOffset by a certain offset
macro RunWave(offset)
	PHP						; Preserve register size
	REP #$20				; A = 16-bit
if <offset> == 1			;
	INC !WaveOffset			; Just increment offset if 1
else						;
	LDA.w #<offset>			; Otherwise use CLC : ADC
	CLC : ADC !WaveOffset	;
	STA !WaveOffset			;
endif						;
	PLP						; Restore register size
endmacro

; Adds the wave offset with the background position and
; stores the result to MULT A which is the initial angle.
macro WaveStoreOffset(layer)
	LDA !WaveOffset			; Rounding stuff
	ASL						;
	LDA !WaveOffset+1		; Get wave offset, add with layer
if <layer>
	ADC.b bgof2addr(<layer>,1)
endif
	STA $4202				; Store to MULT A (initial angle)
endmacro


; Calls the routine Waves_CalculateWaves.
; wavelength, amplitude, angle_offset, hdma_data and height are constants,
; start_pos and bg_offset are RAM addresses
; Note that setting start_pos, bg_offset, hdma_data and height
; to 0 implies that they're set beforehand (in other words: They're dynamic).
; These values are stored in $4202, X, $08, $0C and $0E, respectively.
macro CallWave(wavelength, amplitude, start_pos, bg_offset, angle_offset, hdma_data, height)
	PHP						; Preserve processor flags
	SEP #$10				; XY = 8-bit
	REP #$20				; A = 16-bit
	LDA.w #<wavelength>*2	; Store the double of the wavelength
	STA $00					;
	LDA.w #$10000/<wavelength>
	STA $05					; Delta X
	CLC : ADC #$0080		; Round delta
	XBA						;
if <start_pos>				;
	LDY <start_pos>			; Get starting offset
	STY $4202				;
endif						;
	TAY						; Get only low byte
	STY $4203				;
if <amplitude>				;
	LDX.b #<amplitude>		;
endif						;
if <bg_offset>				;
	LDA.b <bg_offset>		;
	STA $08					;
endif						;
	LDY #$00				;
	STY $02					; Starting angle (low byte)
if <wavelength> == 1		;
	LDY #$01				; I mean, the wavelength can be 0 in this case.
endif						;
	STY $07					; Delta X (high byte)
	LDA.w #<angle_offset>	;
	CLC : ADC $06			;
	STA $06					;
	LDA $4216				; delta * $100 * <start_pos>
	AND #$00FF				;
	STA $03					; Starting angle
if <hdma_data> 				; Only set data (this is done so if it's been set beforehand)
	LDA.w #<hdma_data>		;
	STA $0C					;
endif						;
if <height> 				;
	LDA.w #<height>*2		;
	STA $0E					;
endif						;
	JSL Waves_CalculateWaves;
	PLP						;
endmacro


; Handles the waves at a ranged area with the bottom part being affected by waves.
; The starting height of the waves is dependent by wave_edge which can be controlled
; by a certain layer (bg_offset) unless bg_offset is set to 0 in which case it's relative
; to the screen.
; All of the inputs are constants with almost none of them being able to be disable aside
; from the aforementioned bg_offset.
; It then calls CallWave which in turn calls Waves_CalculateWaves.
macro RangedWaves(wavelength, amplitude, bg_offset, dir, layer_dep, wave_edge, angle_offset, hdma_data, height)
	PHP						;
	LDA !WaveOffset			; Rounding stuff.
	ASL						;
	LDA !WaveOffset+1		; Get wave offset, add with layer.
	ADC.b bgof2addr(<bg_offset>,1)
	STA $0A					; Preserve offset.
	REP #$30				; AXY = 16-bit
	LDX #<hdma_data>		; Load start of HDMA table
	LDA.b bgof2addr(<bg_offset>, <dir>)
	STA $08					; Preserve position for later
if <layer_dep>				;
	LDA.w #<height>*2		; Store height
	STA $0E					;
	LDA.w #<wave_edge>		; Get height of no-waves
	SEC : SBC.b bgof2addr(<layer_dep>,1)
	BEQ ?WavesOnly			; If the edge is above the screen: Draw only waves.
	BMI ?WavesOnly			; ($00 may never be smaller than 1.)
	STA $00					; Preserve range.
else						;
	LDA.w #<wave_edge>		; Get wave height
	TAY						; Set also for loop count
endif						;
	CLC : ADC $0A			; Add with offset.
	STA $0A					;
if <layer_dep>				;
	LDY #$0001				; Draw waves.
	LDA $00					; Range must not exceed total height.
	CMP.w #<height>			;
	BCC ?WithinScreen		;
	DEY						; Don't draw waves.
	LDA.w #<height>			;
	STA $00					;
?WithinScreen:				;
	PHY						;
	TAY						; Set loop count
endif						;
	LDA $08					; Preserve position for later
?NoWavesLoop:				;
	STA !WaveTableBase,x	;
	INX #2					;
	DEY						;
	BNE ?NoWavesLoop		;
if <layer_dep>				;
	PLY						; Restore draw waves flag
	DEY						; Draw waves?
	BNE ?Finished			;
	LDA.w #<height>			; Calculate height of affected area
	SEC : SBC $00			;
	ASL						; Double it (byte count)
else						; Otherwise calculate it in Asar
	LDA.w #(<height>-<wave_edge>)*2 
endif						;
	STA $0E					;
?WavesOnly:					;
	STX $0C					; Store start of HDMA table
	%CallWave(<wavelength>, <amplitude>, $0A, 0, <angle_offset>, 0, 0)
?Finished:					;
	PLP						;
endmacro
