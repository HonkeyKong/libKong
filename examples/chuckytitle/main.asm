; libKong MMC1 example program, 32KB

  .data

; set up our Zero-Page variables.
  .include "../../KongZP.asm"

; skip RAM allocation to $30.
.org $30 
  .space TileSrc  2   ; Set up a place to store CHR-RAM addresses.

; Skip past the stack, and into our OAM copy.
; (256 bytes / 4 bytes per sprite) = 64 sprites on-screen at once.
.org $0200

; End of OAM, start of general-purpose variables.
.org $0300
; $0300-$07FF are available to you.

; -------------------- END OF DATA SEGMENT --------------------

; Start of the text segment, this is our program code.
.text

.org $8000 ; First 16KB bank goes from $8000-$BFFF
  
TitleGFX:
  .incbin "title-crop.chr"

MMC1Stub0:
  .include "../../MMC1Stub.asm"

.advance $BFFA
  .word NMI, MMC1Stub0, 0

.advance $C000

.include "../../KongSetup.asm"      ; libKong NES setup
.include "../../KongPPU.asm"        ; libKong PPU code
.include "../../KongMacros.asm"     ; libKong Macros
.include "../../KongRender.asm"     ; Rendering routines
;.include "../../KongInput.asm"      ; Controller handler

; Add our graphics data.
simplePal:              ; Palette data
  .incbin "CP3Title-Lossy.pal"

simpleScreen1:          ; Screen 1 Data
  .incbin "CP3TItle-Lossy.nam"

CopyTiles:
  LDA #<TitleGFX  ; load the source address into a pointer in zero page
  STA TileSrc
  LDA #>TitleGFX
  STA TileSrc+1

  LDY #0            ; starting index into the first page
  STY PPUControl2   ; turn off rendering just in case
  `setPPU $0000     ; Set the PPU at the start of tile memory (CHR RAM)
  LDX #16           ; number of 256-byte pages to copy

*  LDA (TileSrc),y  ; copy one byte
  STA VRAMIO
  INY
  BNE -  ; repeat until we finish the page
  INC TileSrc+1  ; go to the next page
  DEX
  BNE -  ; repeat until we've copied enough pages
  RTS

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

  JSR CopyTiles

  ; Load our palettes.
  `loadBGPalette simplePal
  `loadSpritePalette simplePal

  ; Clear the nametables.
  JSR ClearNameTables

  ; Set up the PPU. This is self explanatory, but I'll break it down.
  ; Set Backgrounds to CHR Page 0
  ; Increment PPU address by 1 (horizontal rendering)
  ; Set Nametable to PPU Address $2000 (Top-Left)
  `ConfigurePPU BGAddr0|SprAddr1|PPUInc1|NameTable20  
  
  LDX #<simpleScreen1
  LDY #>simpleScreen1
  LDA #NT0
  JSR RenderNameTable
  JSR ClearSprites  ; Move sprites off-screen.

  ; Now that we've rendered our background, we can reconfigure the PPU with our
  ; VBlank Non-Maskable Interrupt enabled.
  `ConfigurePPU NMIOnVBlank|BGAddr0|SprAddr1|PPUInc1|NameTable20

  ; Enable graphics.
  JSR EnableGFX

MainLoop:
  JMP MainLoop     ; Jump back, infinite loop. All game logic performed on NMI.

; Non Maskable Interrupt, ran once per frame when VBlank triggers.
NMI:

  ; The VBlank period has just started, it's safe to update PPU memory.
  
  ; Reset the scroll register on each frame update where VRAM is written.
  JSR ResetScroll

  ; PPU updates are done, run the game logic.

;ReadPads:
  ; Read the controller states.
  ;JSR ReadController1
  ;JSR ReadController2

  RTI   ; ReTurn from Interrupt

MMC1Stub1:
  .include "../../MMC1Stub.asm"

  ; Set up the 3 main vectors the NES looks for 
  ; at the end of the ROM on power-up.

  ; Unlike the .org directive, .advance will advance the program 
  ; counter and zero fill the space leading up to it to pad the 
  ; binary up to the designated location. This is necessary in places
  ; like this, where the hardware expects a lookup table with the 
  ; necessary functions to set up the NES and get things running.

  .advance $FFFA    ; First of the three vectors starts here

  .word NMI         ; Non-Maskable Interrupt, runs at VBlank, once per frame.

  .word MMC1Stub1   ; This function is performed on power-on and reset.

  .word 0           ; external IRQ is not used here