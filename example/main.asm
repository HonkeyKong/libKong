  ; libKong example program ROM, 32KB

  ; A bit about segmentation before we start:
  ; We use two segments here, .data and .text
  ; Each segment contains its own Program Counter 
  ; to keep track of where we are in the data.
  ; This means we can build up the data segment
  ; in one location, and build the text segment
  ; in another without worrying about overwriting
  ; data due to conflicting program counters.

  .data

  ; This header contains our main zero-page requirements.
  ; Don't allocate before $20.
  ; 32 bytes on the zero page should be enough for libKong.
  .include "../KongZP.asm"

  ; Starting here leaves a 16-byte boundary between
  ; the libKong allocation and our ZP requisites.
  ; It's not necessary, but it keeps things safe from being overwritten.
  .org $30 

  ; $100-$1FF are where the stack is located, so make sure you're not putting
  ; anything into that area. $200 is a good place for a copy of the Object
  ; Attribute Memory (OAM) to be written, so you can manipulate sprites before
  ; and after the VBlank, then DMA tham into VRAM during the VBlank cycle.

  .org $0200

  ; The ball sprite is split into 4 variables so
  ; we can alter things like palette and rotation.
  ; Technically this could also be done by addressing
  ; Ball+2 for the attribute byte, and Ball+3 for X.
  ; However, the code comes out cleaner and does the
  ; same thing arranged this way, so I'm doing it for
  ; the sake of readability and maintainability.
  .space  Ball              1
  .space  BallIndex         1
  .space  BallAttr          1
  .space  BallXPos          1

  ; $200-$2FF should be set aside for OAM.
  ; (256 bytes / 4 bytes per sprite) = 64 sprites on-screen at once.

  .org $0300

  ; This is where variables should go that don't require the speed of a
  ; zero-page read or write. You have $0300-$07FF available to you.
  ; That's roughly 1.25 kilobytes. Should be enough for everyone. :)

; -------------------- END OF DATA SEGMENT --------------------

  ; Start of the text segment, this is our program code.
  
  .text

  ; Addressable ROM space starts at $8000. Everything below this area is wired
  ; to the NES hardware or a mirror of a hardware space, with the exception of
  ; $6000-$7FFF in boards with 8KB expansion RAM, such as TLROM and TKROM cart
  ; configurations.

  .org $8000

  .include "../KongSetup.asm"      ; libKong NES setup
  .include "../KongPPU.asm"        ; libKong PPU code
  .include "../KongMacros.asm"     ; libKong Macros
  .include "../KongRender.asm"     ; Rendering routines
  .include "../KongInput.asm"      ; Controller handler

  ; Set up some strings.

  demoText:
  .byte "LibKong Example ROM"

  dtLength:
  .byte 19

  copyrightText:
  .byte "`2017 Ryan D. Souders"
    
  ctLength:
  .byte 21

  webText:
  .byte "www.HonkeyKong.Org"

  wtLength:
  .byte 18

  twitterText:
  .byte "@HonkeyKong on Twitter"

  ttLength:
  .byte 22

  ; Set up a palette.
  ; Note, this isn't the most efficient way to do it. For any significant NES
  ; development, you should really be using a more featured tool, like the
  ; wonderful NES Screen Tool developed by Shiru. http://shiru.untergrund.net/
  demoPal:
  .byte $0F, $00, $10, $20 ; Palette 0 (B&W)
  .byte $0F, $05, $15, $26 ; Palette 1 (Reds)
  .byte $0F, $0A, $1A, $2A ; Palette 2 (Greens)
  .byte $0F, $01, $11, $21 ; Palette 3 (Blues)


RESET:
  ; Make sure everything gets set up properly.
  JSR ResetNES      ; Basic boilerplate NES setup code
  JSR WaitVBlank    ; VBlank #1
  JSR ClearRAM      ; Clear out RAM
  `clearStack       ; Clean up the stack.
  JSR ClearSprites  ; Move sprites off-screen.
  
  JSR WaitVBlank    ; VBlank #2
  
  ; It generally takes 2 VBlank cycles to ensure the PPU is
  ; warmed up and ready to start drawing stuff on the screen.
  ; Now that the necessary time is passed, we can configure
  ; the PPU and get stuff set up to render the title card.
  JSR DisableGFX    ; Disable graphics

  ; Load our palettes.
  `loadBGPalette demoPal
  `loadSpritePalette demoPal

  ; Clear the nametables.
  JSR ClearNameTables

  ; Set up the PPU. This is self explanatory, but I'll break it down.
  ; Turn on Non-Maskable Interupts on VBlank
  ; Set Backgrounds to CHR Page 1
  ; Increment PPU address by 1 (horizontal rendering)
  ; Set Nametable to PPU Address $2000 (Top-Left)
  ; We'll actually be writing to the nametable at $2800 (Bottom-Left), but with
  ; mirroring set to vertical, writing to $2800 will copy that data to $2000.
  `ConfigurePPU BGAddr0|PPUInc1|NameTable20  
  
  ; Now that we've set up the text we want to write to the screen, it's time to
  ; start actually rendering it.

  ; Set the VRAM Address register to point at the lower-left NameTable.
  ; libKong addresses them ordered as 0, 1, 2, 3.
  `setPPU NameTable0

  ; Note: Writing to the nametable manually isn't necessary, this is just to 
  ; demonstrate the functions for doing so. It's also good for quickly writing
  ; text to the screen. Using the NES Screen Tool mentioned above, you can 
  ; easily import the formats exported by the tool directly in your code with 
  ; the .incbin directive and use them with libKong functions and macros like
  ; loadBGPalette, loadSpritePalette, RenderNameTable and such.

  ; Set up a few blank rows from the top of the screen.
  LDA #$08
  STA BlankRows
  JSR WriteBlankRows

  ; Now we want to offset a few blank tiles to center the text.
  LDA #$06
  STA BlankTiles
  JSR WriteBlankTiles

  ; Write the first line of text.
  LDX #$00                  ; Zero out X.
  * LDA demoText, X         ; Load the data in this address, offset by X.
  STA VRAMIO                ; Write the byte loaded into VRAM.
  INX                       ; Increment our data counter.
  CPX dtLength              ; Compare the counter to the length stored above.
  BNE -                     ; Branch backward if not equal.

  ; Let's fill the rest of the line up and put in another blank row.

  LDA #$07
  STA BlankTiles
  JSR WriteBlankTiles

  LDA #01
  STA BlankRows
  JSR WriteBlankRows

  ; Time for the second line.
  
  LDA #$05
  STA BlankTiles
  JSR WriteBlankTiles

  LDX #$00
  * LDA copyrightText, X
  STA VRAMIO
  INX
  CPX ctLength
  BNE -

  LDA #$06
  STA BlankTiles
  JSR WriteBlankTiles

  LDA #$01
  STA BlankRows
  JSR WriteBlankRows

  ; Third line of text.

  LDA #$07
  STA BlankTiles
  JSR WriteBlankTiles

  LDX #$00
  * LDA webText, X
  STA VRAMIO
  INX
  CPX wtLength
  BNE -

  LDA #$07
  STA BlankTiles
  JSR WriteBlankTiles

  LDA #$01
  STA BlankRows
  JSR WriteBlankRows

  ; Fourth line of text.

  LDA #$05
  STA BlankTiles
  JSR WriteBlankTiles

  LDX #$00
  * LDA twitterText, X
  STA VRAMIO
  INX
  CPX ttLength
  BNE -

  LDA #$05
  STA BlankTiles
  JSR WriteBlankTiles

  LDA #$01
  STA BlankRows
  JSR WriteBlankRows

  ; Now fill up the rest of the screen.

  LDA #14
  STA BlankRows
  JSR WriteBlankRows

  ; The nametable is done, but we still have an attribute table to fill.
  ; Again, designing this with the screen tool is much easier, this is just
  ; filling it with zeroes, telling it to use the first palette entry for all
  ; of our tiles, effectively making it black and white.
  `setPPU AttributeTable0
  LDA #$00
  LDX #$00
  * STA VRAMIO
  INX
  CPX #$40
  BNE -


  ; Now that we've rendered our background, we can reconfigure the PPU with our
  ; VBlank Non-Maskable Interrupt enabled.
  `ConfigurePPU NMIOnVBlank|BGAddr0|PPUInc1|NameTable20

  ; Enable graphics.
  JSR EnableGFX

MainLoop:
  JMP MainLoop     ; Jump back, infinite loop. All game logic performed on NMI.

; Non Maskable Interrupt, ran once per frame when VBlank triggers.
NMI:

  ; The VBlank period has just started, it's safe to update PPU memory.
  LDA #$00
  STA SpriteAddr  ; set low byte (00) of Sprite RAM
  LDA #$02
  STA SpriteDMA   ; set high byte (02) of Sprite RAM, start the transfer.

  ; Reset the scroll register on each frame update where VRAM is written.
  JSR ResetScroll

  ; PPU updates are done, run the game logic.

  ; Read the controller states.
  JSR ReadController1
  JSR ReadController2

  RTI   ; ReTurn from Interrupt

  ; Set up the 3 main vectors the NES looks for 
  ; at the end of the ROM on power-up.

  ; Unlike the .org directive, .advance will advance the program 
  ; counter and zero fill the space leading up to it to pad the 
  ; binary up to the designated location. This is necessary in places
  ; like this, where the hardware expects a lookup table with the 
  ; necessary functions to set up the NES and get things running.

  .advance $FFFA    ; First of the three vectors starts here

  .word NMI         ; Non-Maskable Interrupt, runs at VBlank, once per frame.

  .word RESET       ; This function is performed on power-on and reset.

  .word 0           ; external IRQ is not used here