# LibKong
NES Programming Library, written for the Ophis Assembler,
designed to make getting NES projects up and running quick and easy.

___

## Why?

  Why the hell not? People still make NES games, but not enough people are 
making/releasing them like they should. The way I see it, anything that makes 
it a little easier for someone on the fence or struggling up the slope is 
better for everyone.

  Most NES developers write their own tools and libraries, and I guess I was 
no exception, though my purpose in doing so was to make something easier to use
and understand, not only for myself, but for other people who want to make cool
NES stuff. It might not be a significant or even worthwhile contribution, but 
hey, at least I tried.
___

## So how do I use it?

I'm glad you asked. OK, not really, but I'm happy to explain. Well, maybe not 
"happy", but I don't mind.

  If you're familiar with programming in C, you surely understand the concept
of the #include directive. Ophis has a feature just like that, designated with 
a period instead of an octothorpe. To use certain parts of the library, simply 
.include them. At the very least, you'll want to include KongZP.asm and
KongSetup.asm to initialize the zero-page variables used by the library, and 
set up the hardware. I'm sure you'll actually want to draw stuff on the screen,
read controllers and such too, so maybe including other parts of the library 
would be useful as well.

## What does each part do?

### KongZP.asm
  This is a bare-bones zero-page RAM allocation. Various things used in libKong
are placed here, such as current PPU settings, numbers of blank rows/tiles to 
write to the nametable (for rudimentary RLE rendering), a pointer to a tilemap 
to write to the nametable (for dumping a pre-assembled map into VRAM), palette 
addresses, PPU offsets, input buffers, the fun stuff you need to get a basic 
program running.

This file should be included at the very start of your .data segment since its 
origin is $00. It currently allocates the first $1F bytes of zero page, so your
.org directive after this .include should be set at $20 or higher.

### KongSetup.asm
  The name of this file is fairly self-explanatory. This is the stuff that sets
up the hardware and makes it ready for you to use. Clearing out RAM, pushing 
sprites off-screen and cleaning their attributes, clearing out the nametables 
so they're ready for rendering, all that fun initialization logic, with only a
few lines of code.

If you're using mapper 0 (NROM/No mapper), it doesn't really matter where you 
put this in the .text segment.

If you're using mapper 4 (MMC3, probably other mappers), you want to .include 
this and other lib code past $E000.

### KongMMC3.asm

  I guess the last part of the KongSetup explanation let it slip, but my 
library does support the MMC3 mapper for larger/more complex games, as a matter
of necessity in some of my other programming efforts. This is the only mapper 
implemented in the library so far, but that doesn't mean I'm not open to adding
others in the future. I recently acquired some MMC1 and CHR-RAM dev hardware, 
so those will probably be next to get support.

  Anyway, this file contains the code for initializing the mapper, 
bankswitching, unlocking/reading/writing WRAM and other general tasks. There's 
no support for the scanline counter in this yet, I haven't needed to use it 
so far.

Obviously, this should be included past $E000, since it's the only bank 
guaranteed to be mapped in the correct place when you power on the NES. Don't 
let the emulators you test in fool you, hardware is random as hell with this.

### KongPPU.asm
  Another pretty self-explanatory name, a trend you've almost certainly noticed
by now. This file includes functions and aliases for working with the PPU and 
putting pretty graphics on the screen. Used in conjunction with KongMacros.asm,
most of your basic rendering needs should be handled here, though for games 
with any complexity, you're going to need to write some of your own rendering 
stuff too. This is just a good point to step off from.

You should probably .include this after the setup code, for the sake of 
cleanliness.

### KongMacros.asm
  These are some assembler macros for the PPU code. Macros should be written 
sparingly, as unlike subroutines, which are jumped to and executed when needed,
the macros will be repeated in code every time they're called. It's a necessary
evil at times though to make certain things like bankswitching or writing a 
cluster of graphics to the VRAM without writing all this code over and over 
again each time.

Currently, loading palettes, setting the PPU offset and configuring the PPU are
the main things macros are used for.

Include these in the same general vicinity as the PPU code, because you'll be 
calling them a lot while rendering.

### KongRender.asm
  Another graphics-related file, this one deals with actually rendering stuff
on the screen, as opposed to the PPU file which just aliases various hardware.

As usual, include this with your other headers. Really, all these should be 
grouped together wherever possible, though the MMC3 and Setup headers are the
only ones that need to be placed past $E000 if you're using that mapper.

### KongInput.asm
  Can you guess what this one is for? Controller stuff! Yay!

  2 player controls have been extensively tested, and even though I've added 
basic support for 4-player adapters (NES only for now, sorry Famicom owners),
I haven't done much testing beyond detecting and confirming the adapter is 
connected to the console and switched into 4-player mode. It might work, it
might not. Isn't that part of the fun of testing unfinished \***cough**\* I mean
"Early Access" code?
___

## FAQ

### Does this work on a real NES?
  Yes. I've tested this code extensively on not only emulators, but real NES
hardware and clone consoles such as the Retro-Bit Retro Entertainment System
and the Yobo FC3 Plus. No discrepancies have been found outside of the typical
clone problems with palettes, sound and such, and those aren't my fault.

### How do I use this?
  Well, if you read the stuff above, you'd have a pretty good idea of how to 
include it in your project, but you know, back when I was in the service, they
used to say, "Don't show a man how to do something, tell him what to do and let
him surprise you with his ingenuity."

No, wait. That was Tom Anderson who said that to those two hooligans, 
"Buff-Coat and Beaver". In that case, just take a look inside the "example"
folder for a small sample program that I've hacked together after writing this 
so-called "documentation". It's pretty bare-bones, just writing a few lines of
text to the screen, but I'm sure I'll get around to making more examples later.
For a list of further functions and aliases, read the library source code. I've
tried to comment it thoroughly so that it's easy to understand everything going
on under the hood.

The example program, as well as the library, are built with the Ophis assembler
which is freely available for Windows, Linux and Mac OS X, and written in 
Python. If you don't already have it, you can grab it [here](http://michaelcmartin.github.io/Ophis/). Once you have it
installed and in your path, just navigate to the "example" folder and run the 
following command:

>ophis BuildExampleROM.oph

This should place the "example.nes" ROM in the example/bin folder. You can now 
run this in the emulator of your choice. But what about real hardware, you ask?
The process is a bit different, as the NES uses two separate ROM files, one for
code and data, and another for graphics. To produce the PRG (Program) ROM, run

>ophis BuildExamplePRG.oph

This will assemble an "example.prg" file containing only the contents of the 
PRG ROM, suitable for burning to a 32KB EEPROM or flashing to a cartridge. The 
CHR ROM is a bit easier, as it's pre-built. Just burn the "example.chr" to an
8KB EEPROM or flash it to your cartridge.

I may write better documentation at some point, but I think I should improve it
some more first, and add more functionality. The library is far from in a 
finished state right now, and is constantly evolving as I work on projects. If
you want to make modifications, feel free to fork this repo and submit your own
pull requests with additions or bug fixes where applicable.

If you're looking for a better build system for your game, check out the
HonkeyPong project in my github repo to illustrate how to use makefiles and 
other modern stuff to build your game. I've also supplied other tools for
building your games as well.

### Can I use your code in my own game?
  Yes. this code is made available under the MIT License. If you're unfamiliar 
with the terms, the gist of it is that you can use this code however you want, 
even in a commercial title that you want to sell. If you want to modify, reuse,
redistribute and relicense the code, that's fine as well. The only thing you
can't do is hold me responsible if it blows up your NES, Famicom, PC, TV, cell 
phone, tablet, cat, or toaster. That (probably) won't happen though. There's no
warranty, use at your own risk.

### How can I put this on a cartridge and run it on a real NES?
  There are several ways to do this. Memory card-based devices like the 
[Everdrive N8](http://www.stoneagegamer.com/flash-carts/everdrive-n8-fc-nes/north-america-europe-nes/) and [Powerpak](http://www.retrousb.com/product_info.php?cPath=24&products_id=34) are fairly popular, but also extremely expensive. The 
plus sides are that you can use an SD or CompactFlash card to store many games,
and they support a ton of different mappers. This type of solution seems to be 
geared more toward gamers who just want a ton of games on a single cartridge, 
as opposed to developers with a rapid testing cycle.

  If you're like me, you'd probably rather have a cheaper flash device that can
be reprogrammed quickly and easily from a PC, and don't care about just loading
up a bunch of games and playing them. This is where dedicated flash cartridges 
come in. I highly recommend the [INL-ROM flash boards](http://www.infiniteneslives.com/aux4.php) from [Infinite NES Lives](http://www.infiniteneslives.com/). 
I own some of his NROM, MMC1 and MMC3 flash boards, as well as the SNES 
Hi/LoROM flash board, and have never had any problems with them, aside from the
time I put the SNES board in the programmer backwards and it got really hot.

  If you just want a basic NROM board for making small games, you can buy one 
for around $13. He also sells new NES plastic cartridge shells starting at $5,
so you can make your dev cart look cool and not cannibalize an original NES 
game for parts (or you could buy a crappy sports game for a dollar and use 
that). If you want something like a larger 6 megabit MMC3 battery backed flash 
board, one can be had for under $30. That's a damn sight cheaper than a 
Powerpak.

  Paul's boards are programmable via the [INL-Retro USB Programmer](http://www.infiniteneslives.com/aux3.php), available 
for $20 in a one-slot version, with up to two additional slots available for $5
each. If you just want NES, it's $20. If you want NES and SNES (or Famicom) it's 
$25. If you want all three (NES + SNES + Famicom), it'll only cost you $30. 
Again, it's much cheaper (and modern) than the old-school expensive parallel 
port and floppy-disk based flash devices and copiers.

___

## Credits

### Graphics
Game tiles and screen arrangements by [Ryan Souders (HonkeyKong)](http://www.honkeykong.org/)

### Programming
Library programming and tool development by [Ryan Souders (HonkeyKong)](http://www.honkeykong.org/)