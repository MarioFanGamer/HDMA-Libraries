                        HDMA Waves
                     by MarioFanGamer
          ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

What is this UberASM library?
----------------------------------------------------------
This UberASM library which allows you to run waves HDMA.
It's purpose is to have an as generic waves HDMA library
as possible while also having the library.

A side effect is that this kind of HDMA waves is quite
slow in calculation, though it also allows you to use
more dynamic waves HDMA such as having variable amplitude
and having only parts of the screen affected by the waves.

How do I use it?
----------------------------------------------------------
The code usage can get rather complex. But the very first
thing you have to do is to copy the contents of
waves_macro.asm to the end of macro_library.asm.

The most important macros are InitWave and CallWave which
allows you to get the HDMA running. InitWave should be set
up at init code, CallWave should be run by both.

In order to have animating waves, you want to put RunWave
in the main code. In addition, you also want to use
WaveStoreOffset which stores the initial angle (i.e. it
loads both the animation frame and corrects the wave to
the current position) before CallWave and have the third
parameter (initial angle) to be 0.

Certain parameters can be disabled by setting the value to
0. In fact, this how to handle animated waves since you
generally want to have the angle dynamic and not static.

A more complicated macro is RangedWaves which is used if
only part of the screen is affected by the waves.

See the example files for more information.

Side note: Heat.asm assumes you have installed the
Scrollable HDMA Gradients library. You won't be able to
insert it in UberASM otherwise.

How do I use it with SA-1?
----------------------------------------------------------
The library is compatible with SA-1 by default since none
of the code runs on SA-1.

That being said, you may want to enable SA-1 boosting,
considering it can greatly benefit from SA-1's speed. If
doing so, make sure you relocate freeRAM to BW-RAM (banks
$40 and $41) and enable SA-1 boosting in the library code.

Can you explain the macros in detail?
----------------------------------------------------------
See "Macros and Functions - HDMA Waves.txt" for more
detail.

There is so much slow down!
----------------------------------------------------------
That one is natural considering I must fill the whole
screen of data. That being said, most of the.

Tip: Use as small wavelengths as possible. That way, only
few scanlines have to be really calculated.

Can this work with parallax scrolling?
----------------------------------------------------------
Depends. Multiple layers and dynamic tiles are fine.
However, parallax HDMA doesn't since the waves and
parallax scrolling would overwrite each other and
combining both of them would make the code infinitely more
complicated.

Why did you make this library?
----------------------------------------------------------
Originally, I released one for C3 Summer 2020 a generic
HDMA library, mostly to create a quick release for it
while this release is a genuine one (with slight hints of
wanting to create another thread of C3 Winter 2022 ;) ).
The primary driver is that I always disliked how most 
implementations for waves HDMA are actually triangle waves
rather than sine waves. They also are tool generated while
my code doesn't require any tool for that.
In addition, the tool generated libraries are limited in
another way that they affect the whole screen.

Have you done everything by yourself?
----------------------------------------------------------
Yes.

Do I must give you credits?
----------------------------------------------------------
Despite being rather complex, no.

Is that all?
----------------------------------------------------------
Occasionally, HDMA might flicker when a lot of data has
been updated on the screen (e.g. changing many blocks,
many dynamic sprites onscreen, lots of ExAnimations).
