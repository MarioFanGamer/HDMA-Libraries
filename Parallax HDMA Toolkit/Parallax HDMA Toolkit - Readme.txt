                  Parallax HDMA Toolkit
                     by MarioFanGamer
          ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

What is this UberASM library?
----------------------------------------------------------
This UberASM library easily allows you to create parallax
HDMA without a tool like Effect Tool or Scroll Bars.

Parallax HDMA is a subset of raster parallax, one of the
many types of parallax scrolling. Parallax is the
displacement of objects which "move" slower when they're
further from the viewpoint. According to Wikipedia, you
have the following options on a 2D plane: Sprites, layers,
dynamic graphics and raster interrupts.
The former was often used on the NES as it only supported
one background, layers, the most common parallax on the
SNES, allows you to have a background independently of a
foreground, dynamic graphics is where you have multiple
rendition of a graphic, all shifted by a certain position
and lastly, raster interrupts where you change the
position midscreen through raster interrupts.

HDMA is raster interrupt and is commonly understood as
a colour gradient. But you can do more with it as shown
with parallax HDMA. This allows you to have pretty smooth
scrolling on a single layer!

Unlike Effect Tool and Scroll Bars, it uses a what I call
an "HDMA buffer" i.e. an HDMA table which spans over the
whole screen. This has got two advantages: The first one
is that the code is now generalised and the only necessary
input is a table and the second advantage is that you can
scroll the background vertically!

If you're confused which file should be put where:
Parallax.asm is the level file and ParallaxToolkit.asm
the library.

How do I create my own table?
----------------------------------------------------------
This requires knowledge on how the table looks like.
Let's take a look at a single value:
db $aa : dw $bbbb,$cccc : db $dd,$ee

$aa: The mode. Currently, only two values are valid: $00
and $02. $00 is a simple parallax and $02 applies a wave
effect alongside the parallax. Keep in mind that the
latter uses two additional bytes for the wavelength and
amplitude.

$bbbb: The scroll factor. This determines how fast the
background scrolls in relation to layer 1. Keep in mind
that the value is divided by $100 before the scrolling
is applied. For this reason, a value of $0100 means same
position as layer 1, $0200 double as fast as and $0080
half as fast, etc.

$cccc is the max Y position to apply the parallax.
I didn't use the starting position as not only is that
harder to code but also because you would always enter
$0000 anyway.
Keep in mind that the layer 3 position is slightly
shifted. You want to apply a parallax for a whole block
(16 scanlines), the value should end with $0E.
This is relative to the background's Y position.
The last value should ALWAYS have a max Y position of
$FFFF. This avoids crashes in case the background scrolls
too far vertically (in both directions).

$dd: Wavelength. Well, not quite. It's more the
wavelength's reciprocal. It's better to say the "clock"
speed, which "angle" is added to the next scanline.
As this is only used for waves, remember that this byte is
omitted if you use just parallax.

$ee: Amplitude / radius. This determines the range of
the wave. The value is signed so for an inverted wave,
use a value from $FF to $80.
Similar to the wavelength, you should never put a value
here if you use just parallax.

How do I use it programmacally?
----------------------------------------------------------
The init code takes only one input: The PPU register
(should be the background X offset register). It otherwise
only enables HDMA on channel 5, write-twice, continuous on
the whole screen.

The main code takes four values: The table address
(16-bit A for the address and 8-bit X for the bank), the
frame counter (16-bit value in $08), the base X position
for the scrolling (16-bit value in $0A, I use the
layer 1 X position) and the base Y position for the
parallax Y position (should be the affected layer's Y
position).

Which background did you chose to test?
----------------------------------------------------------
Originally on SMW2: Yoshi's Island - Sunset (perfect test
background and primary inspiration of the toolkit) but
that's a custom background which is better to submit in
the graphics section. For an SMW example, I used the hills
i.e. Donut Plains 1. While SMW has got quite a bit of
backgrounds which can be enhanced with parallax scrolling,
most of them work only work with two layers (e.g.
Yoshi's Island 1). Only a handful of them can work with
parallax HDMA including castle stone blocks and hills.
Even then, the latter might not look very good as there
is that one cloud on the same height as the hill tops,
arg!

I use layer 3, the Status Bar glitches!
----------------------------------------------------------
This toolkit assumes you use no layer 3 status bar as
working with a Status Bar requires you to make some
changes to the HDMA table and parallax code.
More specifically, you need an entry which points to
memory with a value of $0000 (has to be in RAM as bank can
be only in RAM) with some amount of scanlines (for the
vanilla Status Bar: $23 scanlines). This allows you to
save some RAM and cycles as fewer entries have to be
written.

Yes, it is complicated, don't be surprised that I didn't
implement this feature.

I use a Status Bar, layer 3 glitches!
----------------------------------------------------------
Sadly, layer 3 is incompatible with fullscreen parallax
HDMA. The SNES keeps the Status Bar always on the top of
the screen with IRQ (remember that it shares the same
tilemap als layer 3 a foreground/background). Since the
SNES has to write to each background offset register
twice, the last value has to be buffered first - and there
is only one buffer. The result: If HDMA writes to the
register while IRQ hasn't fully written to it yet, the
wrong value is stored.
For this reason, the Toolkit works best with no layer 3
Status Bar.

This also applies with the goal march. I have added a code
to disable channel 5 (i.e. the parallax) at goal march.
The background will snap back back to without HDMA so use
a layer 1 background similar to the level in SMB3.

If you put the Status Bar behind a black background (a
common way of having a layer 3 background and full screen
background at the same time), you can at least modify the
table in such a way HDMA only affects the part below/above
the Status Bar.

There is slowdown in my level!
----------------------------------------------------------
Let's be honest: Calculating each scanline is difficult.
Add in the fact that the SNES doesn't support
16-bit times 16-bit multiplication (fortunatelly, that
problem doesn't exist on SA-1) and you get a pretty high
propability of lags.
I do have optimised the code for cycles by changing the
data bank to the same bank as the parallax table and
minimise the usage of NOPs in the multiplication code
(both, SA-1 and SNES).

Of course, if you have lags with SA-1, you have far
bigger problems to take care of than this parallax code.

Have you done it everything by yourself?
----------------------------------------------------------
I have taken a look at how Yoshi's Island handles its
parallax HDMA and used it as a help if I was stuck
(especially the waves). The code is otherwise completely
original, though.

Do I must give you credits?
----------------------------------------------------------
Preferable but I don't care if you don't credit me (even
if I was in rush for C3).

Is that all?
----------------------------------------------------------
The parallax table should be located in the banks $00-$3F.
The reason is that I'm relying on multiplication registers
which are only located at those banks.

The tables should never be big enough to be in data banks
(banks $40+ on SNES and $80+ on SA-1) anyway.
Another thing to keep in mind is that the HDMA uses
channel 5. For this reason, a three channel fixed colour
HDMA (a colour gradient) likely doesn't work as it would
use channels 3, 4 and 5. But you shouldn't be using three
channels to begin with on the fixed colour anyway as
that's a waste of channels. Fortunatelly, Gradient Tool
does allow you to generate HDMA on two channels.
Unfortunatelly, the same doesn't apply for Effect Tool.
