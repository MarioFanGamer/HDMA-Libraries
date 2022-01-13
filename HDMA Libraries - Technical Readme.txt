                      HDMA Libraries
	  Description of Defines, Macros and Functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Functions
----------------------------------------------------------

bgof2reg(layer, dir):
This function calculates, which BGOFS register is used
depending on the layer and direction.
- layer is unsurprisingly the background layer (1 - 4)
  which should be accessed.
- direction is the direction of the offset.
  0 is horizontal and 1 is vertical.

----------------------------------------------------------

bgof2addr(layer, dir):
Similar to the above but calculates the address of SMW's
BGOFS mirrors (aside from layer 4, that one spits out
garbage due to lack of proper mirrors).
