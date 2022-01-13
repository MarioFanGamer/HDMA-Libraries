                    Waves HDMA Library
	  Description of Defines, Macros and Functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Defines
----------------------------------------------------------

!WaveTableBase
That one is a 24-bit address which only contains the bank
byte of the data tables.
In order to simplify the codes, I made the code so that
all the data are assumed to be in the same bank.
Default value is $7F0000.

----------------------------------------------------------

!WaveOffset
That one handles the current phase or "angle" of the wave.
It must be two consecutive bytes of freeRAM in the
mirrored WRAM, SRAM or BW-RAM or I-RAM area (i.e. $0000 -
$1FFF, $6000 - $7FFF and $3000 - $37FF).
Furthermore, the low byte is the "subangle" i.e. the
invisible value. You can think of the variable as being
divided by 256.
Default value is $13E6|!addr.

Macros
----------------------------------------------------------

%InitWave(reg, channel, table_src):
Initialises the waves by setting up HDMA for a certain
channel. It belongs in the
- reg is the register. I don't want you to enter them
  directly which is why I provide 
- channel is the HDMA channel which handles the HDMA.
  Valid values are from 0 to 7 but USABLE are only from
  3 to 6 except if you use SA-1 Pack in which case it's
  from 3 to 7.
- table_src is the address of the HDMA pointer table.
  Most of the time, Waves_HDMAPtrs is sufficient but I
  enable the option to use that as a variable in case you
  want to use two different waves.

----------------------------------------------------------

%InitWaveOffset(value):
This initialises the wave phase to a certain value. Useful
if you want to have the waves start all consistently and
you use freeRAM which don't get cleared at level load (the
default ones do).
- value is unsurprisingly the initial value of the phase.

----------------------------------------------------------

%RunWave(offset):
That one is the first main code macro. What it does is to
increment the waves by a certain value. Ideally, it
should run for every frame except for when the game is
paused (though this applies to all main code macros).
- offset is the value which is added to the phase.

----------------------------------------------------------

%CallWave(wavelength, amplitude, start_pos, bg_offset,
angle_offset, hdma_data, height):
This macro has got plenty of parameters which makes sense
because this is a highly customisable library. Certain
parameters are optional and can be ignored by setting
their value to 0. This isn't necessarily good if you use
scratch RAM $00 but that gets overwritten by the macro
immediately anyway so nothing lost.
- wavelength is a mandatory constant. What it does is to
  set, how large the waves are in scanlines and how large
  the delta is for each.
  Prefer to use smaller values because the more unique
  scanlines there are, the more the code has to calculate
  which can easily induce slowdown, especially without
  SA-1.
- amplitude is an optional constant. What it does is to
  set, how wide the waves are in dots/scanlines (depending
  on the direction of the waves).
- start_pos is an optional DP variable. Most of the time,
  you don't have to set this register since you generally
  want to call WaveStoreOffset (see below). I still put it
  in in case you really need it for some reason (in fact,
  I do).
- bg_offset is an optional parameter, the DP address of 
  the background offset which is affected. It preferably
  should be the same layer in the same direction as you
  used for InitWave
- angle_offset is an optional constant which is added to
  the delta (i.e. reciprocal of wavelength). I primarily
  use that to handle alternating waves.
- hdma_data is an optional constant which is the start of
  the HDMA data table. You generally want to have it set
  to be equal to !DefHDMATable in Waves.asm (particularly
  if you use the normal HDMA pointer table) but you can
  use other values if you want to have the wave only
  start at a certain height (e.g. to keep the status bar
  in place or have two different waves).
  By the way, if the address really is $0000: Just enter
  $10000. Asar will (and must) truncate the value to the
  last four bytes for writing the binary data but won't
  do that in calculations.
- height is an optional constant which is usually set to
  224 or $E0 but much like hdma_data, it's also a
  parameter because you can use it as a way to control the
  waves for your likings, especially because hdma_data is
  also customisable.

----------------------------------------------------------

%WaveStoreOffset(layer):
In order to have animating waves, I added this macro to
handle the current. It not only loads the current
angle frame (rounded to the nearest $100's value) but also
adds in the entered layer's (typically the affected one's)
vertical position.
Put this right before CallWave.
- layer is an optional parameter which adds in the
  aforementioned vertical position of the given layer to
  the current angle.

----------------------------------------------------------

%RangedWaves(wavelength, amplitude, bg_offset, dir,
layer_dep, wave_edge, angle_offset, hdma_data, height):
That routine is quite big. It does allow you for having
the waves only appear in parts of the screen (e.g. tides),
at least. Or rather, whether the top part of the screen
has got waves or not. One where only the top part of the
screen gets affected will be implemented later on.
If the constants have the same name as in CallWave, it's
the same parameter with the same use unless noted
otherwise.
- amplitude is mandatory by limitations, can't really fix
  it unless I want to make the code even more complicated.
- bg_offset is a mandatory parameter which unlike its
  CallWave counterpart doesn't contain the address of the
  BG offset but rather the layer itself.
- dir is a mandatory parameter which sets the direction
  of the waves. In case you forgot which value is which,
  0 is horizontal and 1 is vertical.
- layer_dep is an optional parameter which contains the
  dependent layer. In order to take full potential of
  a partially affected screen, I allow in the option to
  hook the height with a layer's position.
  A value of 0 means the height is dependent of the
  screen and not of a layer.
- wave_edge is a mandatory parameter. It's the height
  where the waves start to appear. Depending on the
  preceding value, it's either the screen height or the
  height within a layer tilemap.
