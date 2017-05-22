  ; libKong example program ROM, 16KB

  .data

  ; This header contains our main zero-page requirements.
  ; Don't allocate before $20.
  ; 32 bytes on the zero page should be enough for libKong.
  .include "../../KongZP.asm"

  ; Starting here leaves a 16-byte boundary between
  ; the libKong allocation and our ZP requisites.
  ; It's not necessary, but it keeps things safe from being overwritten.
  .org $30 

  ; $100-$1FF are where the stack is located, so make sure you're not putting
  ; anything into that area. $200 is a good place for a copy of the Object
  ; Attribute Memory (OAM) to be written, so you can manipulate sprites before
  ; and after the VBlank, then DMA them into VRAM during the VBlank cycle.

  .org $0200

  ; (256 bytes / 4 bytes per sprite) = 64 sprites on-screen at once.

  .org $0300

  ; This is where variables should go that don't require the speed of a
  ; zero-page read or write. You have $0300-$07FF available to you.
  ; That's roughly 1.25 kilobytes. Should be enough for everyone. :)

  ; Let's set up a few variables for important things like scrolling.
  .space  ScrollX       1
  .space  ScrollY       1
  .space  ActiveScreen  1

; -------------------- END OF DATA SEGMENT --------------------

  ; Start of the text segment, this is our program code.
  
  .text

  ; Addressable ROM space starts at $8000. Everything below this area is wired
  ; to the NES hardware or a mirror of a hardware space, with the exception of
  ; $6000-$7FFF in boards with 8KB expansion RAM, such as TLROM and TKROM cart
  ; configurations.

  ; Since we're only making a 16KB binary, we can set the origin to $C000,
  ; rather than starting at $8000. This configuration is called "NROM-128",
  ; because it makes a 128 kilobit program ROM. These ROMs are compatible with
  ; 32KB/256 kilobit (NROM-256) boards, though to make them work, you'll need 
  ; to write the PRG data twice to inflate the size to 32KB.

  .org $C000

  .include "../../KongSetup.asm"      ; libKong NES setup
  .include "../../KongPPU.asm"        ; libKong PPU code
  .include "../../KongMacros.asm"     ; libKong Macros
  .include "../../KongRender.asm"     ; Rendering routines
  .include "../../KongInput.asm"      ; Controller handler

  ; Add our graphics data.

simplePal:              ; Palette data
  .incbin "simplegfx.pal"

simpleScreen1:          ; Screen 1 Data
  .incbin "simple1.nam"

simpleScreen2:
  .incbin "simple2.nam" ; Screen 2 Data
  
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

  ; Init our scrolling position.
  LDA #$00
  STA ScrollX
  STA ScrollY
  LDA #$00|NMIOnVBlank|BGAddr0|PPUInc1
  STA ActiveScreen

  ; Load our palettes.
  `loadBGPalette simplePal
  `loadSpritePalette simplePal

  ; Clear the nametables.
  JSR ClearNameTables

  ; Set up the PPU. This is self explanatory, but I'll break it down.
  ; Set Backgrounds to CHR Page 0
  ; Increment PPU address by 1 (horizontal rendering)
  ; Set Nametable to PPU Address $2000 (Top-Left)
  ; We'll actually be writing to the nametable at $2800 (Bottom-Left), but with
  ; mirroring set to vertical, writing to $2800 will copy that data to $2000.
  `ConfigurePPU BGAddr0|PPUInc1|NameTable20  
  
  LDX #<simpleScreen1
  LDY #>simpleScreen1
  LDA #NT0
  JSR RenderNameTable

  LDX #<simpleScreen2
  LDY #>simpleScreen2
  LDA #NT1
  JSR RenderNameTable

  ; Now that we've rendered our background, we can reconfigure the PPU with our
  ; VBlank Non-Maskable Interrupt enabled.
  `ConfigurePPU NMIOnVBlank|BGAddr0|PPUInc1|NameTable20

  ; Enable graphics.
  JSR EnableGFX

MainLoop:
  JMP MainLoop     ; Jump back, infinite loop. All game logic performed on NMI.

; Non Maskable Interrupt, ran once per frame when VBlank triggers.
NMI:

  ; Set the scroll register using our stored values.
  LDX ScrollX
  LDY ScrollY
  CPX #$FF
  BNE +
  LDA ActiveScreen
  EOR #$01
  STA ActiveScreen
  STA PPUControl1
* INX
  STX ScrollX
  STX BGScroll
  STY BGScroll
  
  ; PPU updates are done, run the game logic.

;ReadPads:
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