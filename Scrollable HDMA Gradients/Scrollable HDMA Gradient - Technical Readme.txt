                    Waves HDMA Library
	  Description of Defines, Macros and Functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Defines
----------------------------------------------------------

!ScrollDefBank
The bank byte of the HDMA data tables. The data tables are
the tables which contains the actual colours and to not
complicate the library any further, I made it so that the
tables are both located in the same bank.
This, alongside the other two defines, are primarily used
for calling the macros. You're free to use a different
area by taking the macro and replace the defines.
By default, the data is located in bank $7F. If you have
enough SRAM installed, you can also use SRAM (banks $70
and $71) or BW-RAM (banks $40 and $41), depending on
whether you use SA-1 or not.
In fact, for SA-1 boosting, the tables MUST be in BW-RAM
as SA-1 can't write to the table otherwise.

----------------------------------------------------------

!ScrollDefRedGreen
Fixed colour HDMA requires three writes since you can only
change one colour at a time for fixed colour. Fortunately,
HDMA allows you to perform up to two writes to the same
register so the colours for red and green can be put to
the same table.
In more usable information, that means each scanline takes
two bytes so make sure you reserve enough space for the
blue table.
By default, it is $1343	which is part of the event tilemap
so consider using the $7F0000 reload patch or change it to
a different area in RAM.

----------------------------------------------------------

!ScrollDefBlue
This contains the data for blue colour only and works the
same as the previous define aside from the fact that it
only contains the colours for blue and so it takes one
byte per scanline.
By default, it is $1943 i.e. 0x600 bytes after
!ScrollDefRedGreen or 0x300 scanlines.

Macros
----------------------------------------------------------

%ScrollHdmaInit(gradient_ptr):
This runs the gradient code by setting up HDMA for a certain
channel, decompresses the gradient to RAM and sets up the
HDMA pointer table. By default, it uses the aforementioned
defines for the decompression destination.
- gradient_ptr is the address of the colour gradient.
  Naturally, you want to use labels.

----------------------------------------------------------

%ScrollHdmaMain(layer, offset, factor):
Run by the main and init code, what it does is to handle
the scrolling. The position is typically dependent on the
given layer:
- layer is the background layer where the scrolling is
  hooked is how the gradient scrolls in relation to a
  certain layer.
  The parameter is optional in the sense that entering 0
  will use a constant position for the gradient.
- offset is how far the gradient is shifted in relation to
  the layer. If no layer is hooked, only it will be used
  to determine the offset (though this usually is a pretty
  wasteful unless you know what you're doing).
- factor is how fast the gradient scrolls relative to the
  background layer. It should be noted that it results in
  powers of two so entering a value of 1 yields 2, a value
  of 2 yields 4, a value of 3 yields 8, etc. It also
  divides by the sum of the layer and constant offset.
  You can also enter negative values to allow for faster
  scrolling.
  This parameter is not used if you use direct values.

----------------------------------------------------------

%ScrollHdmaDiv(layer, offset, factor):
That one is similar to the previous macro except that it
allows you to divide the value by any value and not just
powers of two. You can't, however, use faster scrolling
that way and it's also the slower option of these two.
- layer is mostly the same as in the previous macro, just
  not optional.
- divisor is the value which divides the sum of the layer
  offset and the constant offset. Valid values range from
  $01 to $FF, though you generally to use smaller values
  as the scrolling would otherwise be too unnoticeable.
