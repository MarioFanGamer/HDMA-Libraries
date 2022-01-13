!ScrollLayer = 1		; The layer in which the HDMA is rooted.
!ScrollOffset = $0000	; How much is the table shifted
!ScrollFactor = 0		; The division is exponential, using 2 as its base.

init:
	%ScrollHdmaInit(Gradient)

main:
	%ScrollHdmaMain(!ScrollLayer, !ScrollOffset, !ScrollFactor)
RTL

Gradient:
; Insert your gradient here
