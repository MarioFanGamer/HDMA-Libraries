				 Scrollable HDMA Gradient
                    by MarioFanGamer
            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

What does this UberASM code do?
----------------------------------------------------------
This code allows you to "scroll" HDMA (more specifically,
a colour gradient, that distinction is important for a
later information) relative to the screen in contrast to
the commonly static HDMA. If this is something which
always bugged you then the time is now over!

Where should I put each file?
----------------------------------------------------------
ScrollHDMA.asm has to be put into the library folder.
That is the most important part. The other HDMA files are
for levels.
You can change the way how it scrolls at !Layer (which
layer the gradient is relative), !Offset (how much the
gradient is shifted) and !ScrollFactor (how fast the
gradient scrolls). You can also change the buffer which is
a good idea if the gradient ends up being too (or both
final tables overwrite each other).

My HDMA tables don't work!
----------------------------------------------------------
That's because scrollable HDMA gradients don't use
standard HDMA tables. Instead, they use a specialised
colour table with a line counter and a red, green and blue
colour value (I could have gone with a palette, though).
Furthermore, they go over 224 lines in which they're
incompatible with regular gradients anyway. So far, the
only tool which can generate these gradients is
Gradient Tool:
https://www.smwcentral.net/?p=section&a=details&id=11691
(Keep in mind that scrollble HDMA is rather old and my
code makes use of these tables, see below for more
details.)
Keep in mind that Gradient Tool doesn't create scrollable
HDMA gradients by default. In order to create them, you
have to enable them in the menu (the tools in the tool
bar) and set the HDMA type to scrollable AND set the line
counter big enough so you don't see garbage lines.

The overworld messes up!
----------------------------------------------------------
I'm sorry but I had to put the decompression buffer
SOMEWHERE! I didn't randomly chose that freeRAM as
Event Restore ( https://www.smwcentral.net/?p=section&a=details&id=19580 )
frees up that area.
If you use Dynamic Sprites without Dynamic Z, chances are
you already have it installed.

The tables are so big!
----------------------------------------------------------
In that case, it's a good idea to put them in a separate
freespace. UberASM has got the macro %prot_file(file, label)
in which a file is inserted separately. Do note that it
searches in the same folder where UberASM is located
so if you want to put the gradient in the level folder,
add "level" in front of the file name. They can be put in
any folder, in fact (such as, preferably, "HDMA" or
"gradients"). Label means which name the gradient has got
in the ASM file. A typical name is "Gradient" which is the
same name I chose for the (would be) gradient in Base.asm.
Keep in mind to remove the label if you're already using
as no label can be a duplicate.

What's the secret?
----------------------------------------------------------
HDMA works on a scanline basis (as practically everything
on the SNES or rather, older computers in general) so HDMA
is, by definition, static to the "camera" (which doesn't
really exist on the SNES). They also usually change the
colour every X scanlines and there is no HDMA buffer which
means you can't use them to scroll the table.
A less important point but also something I can bring up
is that HDMA can only affect up to two background colours
(or fixed colour if we're technical) each. The reason is
that the fixed colour can only read one colour per write
(either red, green or blue) which means you need three
writes but HDMA can only write to each register up to two
times. This is why each fixed colour HDMA uses either
three tables (if the resulting code writes to each colour
once) or two tables (if the HDMA first writes two colours
each and then a third one, usually red-green and then
blue). It makes a small difference: Two tables means that
HDMA only needs two channels (there are 8 channels each
and SMW uses a couple of them) and the scanline count of
one colour disappears so two tables also are generally
smaller than three tables).

I'm not the first person with the idea of scrollable HDMA.
However, I have perfectionised the tables. Alright, let's
go to the history lesson of scrollable HDMA gradients:
The first person who created scrollable HDMA gradients is
Ersanio. His idea is that you have regular HDMA tables
(one for red-green, one for blue, you know, the standard
stuff) but unlike traditional HDMA tables, the scanlines
they use have a scanline count of one line each (and
obviously uses more values than there are scanlines on a
SNES screen) and all you need to do is to change the
beginning of the table during runtime. This does create a
problem: The tables are so damn big so you can easily run
out of space with them!
Imamelia had a grand idea to bypass that limitation:
Instead of having two tables with individual values stored
in ROM, you have a compressed red-green-blue table (it
isn't a real HDMA table, after all) with a scanline count!
The result is twofold: The first one is that the table now
uses a scanline counts which aren't necesserily one AND
it also unifies red, green and blue into a single table.
Of course, the tables then need to be decompressed into
RAM and the resulting table still takes as much space as
in Ersanio's method but the price is worth! (I mean, hey,
all the graphics are compressed too, aren't they?).
Furthermore, since these aren't real HDMA tables (as
remember, HDMA can transfer maximally two bytes per
register – and you can only affect three unique colours on
the fixed colour register), his decompression routine
takes a table with a scanline count + red, green AND blue
colour values instead of two tables with scanlines of red
and green and scanlines of blue (where does this sound
familiar...). Similar to as using two HDMA tables instead
of three, the resulting table will be smaller than using
more faithful HDMA table. But in the end, the result is
the same: Each scanline takes five bytes when
decompressed. There also is the problem that the main code
writes to HDMA registers and while levelASM (read: the
level code in UberASM) usually runs in v-blank (as NMI is
short enough in SMW and LevelASM is one of the first
things which run), a costy NMI routine might result in
a midscreen HDMA write, something what should be avoided
by all means...
I use a different approach which is smaller and safer:
Indirect continuous HDMA. What this means is that I have
two tables, one of which is made out of pointers and
contains scanlines and the other contains actual data
(without any scanline count). The scanline counter in the
first table also is set to use continuous HDMA. What that
means is instead of using the same colour for X scanlines,
HDMA reads a different value for the next scanlines!
Or in other words: The colour table doesn't use a scanline
count, therefore requires almost 40% less bytes of RAM
than in imamelia's version (almost because the pointer
table requires some RAM too but that's nothing compared to
the colour table). In addition, writing to the pointer
table is less dangerious now as the worst what could
happen is Screen Tearing without writing to the pointer
table in NMI.

The only way to compress the table even further is to use
CG-RAM colour values i.e. there is a word which contains
the red, green and blue colours and decompresses them
accordingly but there is no tool support for that. :P

Can this be used for parallax scrolling?
----------------------------------------------------------
Not really. The reason why scrollable HDMA gradient works
in the first place is because the tables are static. A
dynamic table i.e. one for parallax scroll is out of luck
with this method. The reason is that scrolling HDMA works
best with indirect HDMA (so you don't have to calculate
each row even with identical values) and you can't use
pointers to pointers in HDMA. For this reason, using
non-continuous HDMA is still the best method for scrolling
HDMA.
However, if you have some spare time in-game (especially
if you use SA-1 or Super FX), you still can use a
variation of scrolling HDMA: You calculate each scanline
on the screen! Remember that scrolling HDMA is dynamic, it
changes every frame. For this reason, you can write to a
HDMA buffer which is as large as the screen and calculate
each scanline manually! In that case, you less decompress
a table but rather redraw a screen with given values (not
much different from what we're doing today except it's a
HDMA and not a graphics buffer).
It also requires a double buffer to prevent screen
tearing.

What about SA-1?
----------------------------------------------------------
SA-1 is a bit... special. It's a second processor included
in some games, is around three to four times faster than
the SNES (depending on whether you count the SNES's usual
clocking or the actual clocking) and has got better
arithmetics (MUCH faster multiplication and division).
However, it also can't access ANYTHING from the SNES
including WRAM (banks $7E and $7F).
This is why SA-1 Pack remaps so much since that's the only
way to guarantee that most code works for SA-1.
However, SA-1 isn't activated all the time. It is for
e.g. blocks and regular sprites but UberASM runs on the
SNES by default. As such, you CAN leave the colour table
as default as long as you don't ENABLE SA-1 (i.e. change
!EnableSA1Boost to 1) for the decompression. If you do so,
you need to change the bank in the level code.

An alternative is to leave the buffer where it is but
enable a separate decompression buffer for SA-1.
After the decompression has been finished, the SNES
then transfers from the SA-1 buffer to the SNES buffer.
By default, it uses the CC-DMA Buffer which is unused
in 99% of all SA-1 hacks.

!FreeRAM_RG_Ptr and !FreeRAM_B_Ptr don't need to be
changed since it's the SNES which handles the table.
(Calling SA-1 is too overkill there.)

Why did you make this code?
----------------------------------------------------------
As I mentioned before, Gradient Tool already supports
scrollable HDMA gradients as Ersanio and imamelia already
made such type of HDMA (especially imamelia and his
decompression code) but the former had an obscure code
(and only works with HDMA Gradient Ripper) whereas I could
never manage to make the latter work.
It was Yoshi's Island which really inspired me to make my
own code, though, as it uses the indirect continuous HDMA
approach which I then inspired me (but never adopted due
to different table formats) to create one for SMW (and
65816 because YI uses Super FX to decompress the tables).

Do I must give you credits?
----------------------------------------------------------
Nope, even if it required some testing and was some work,
I'll give you a pass.

Is that really all?
----------------------------------------------------------
Make sure the table has got the correct height! Do not
only take the maximum of how much the table can scroll in
mind but also that the screen is 224 pixels high. Not
doing so results in garbage colorus being loaded which may
or may not be hidden out by the background.

In addition, the HDMA is hardcoded to channels 3 and 4.
While many HDMA codes can be easily adjusted to not be
specific to certain HDMA channels, that one is more
difficult for Scrollable HDMA Gradients.
