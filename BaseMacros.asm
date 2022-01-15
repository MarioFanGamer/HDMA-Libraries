; Converts the layer and direction into the corresponding register
function bgof2reg(layer, dir) = (((layer-1)&3)<<1)+(dir&1)+$D

; Converts the layer and direction into the corresponding address
function bgof2addr(layer, dir) = ((((layer-1)&3)<<1)+(dir&1))*2+$1A
