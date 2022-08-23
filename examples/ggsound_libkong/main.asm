; libKong Sound Test - 32KB PRG

; Data Segment, RAM variables and constants.
.data
; Zero-Page variables
.org $00
  .include "../../KongZP.asm"
  .include "demo_zp.inc"
  .include "ggsound_zp.inc"

; $100-$1FF is the stack.

; OAM Copy (Sprite Data)
.org $0200
  .space  sprites 256         ; $0200-$02FF
  ; $0300 - start of general work RAM
  .include "ggsound_ram.inc"  

; Text Segment, code and data.
.text
; Set .text program counter at the start of the mapped ROM space.
; Note that this doesn't affect the .data program counter, as
; the two operate independently.
.org $8000
  ; Throw some data and shit in here.
  .include "../../KongSetup.asm"
  .include "../../KongPPU.asm"
  .include "../../KongMacros.asm"
  .include "../../KongInput.asm"
  .include "ggsound.inc"

; Hardcoding the palettes for now, though it's better practice
; to store the palettes in their own binary file, or with your
; graphics data ASM code. This is just a quick & dirty hack.
DemoBGPalette:
  .byte $0e,$08,$18,$20,$0e,$0e,$12,$20,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e
DemoSpritePalette:
  .byte $0e,$0e,$09,$1a,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e



; This ensures that we don't go out of bounds in the first 8KB page.
; Since this demo is one contiguous 32KB PRG ROM, it doesn't matter,
; but it's still good practice to prepare yourself for bigger mappers.
; It just tells the assembler to check the program counter and ensure
; that we haven't crossed over the boundary of this first page.
.checkPC $9FFF
.advance $A000
  .include "track_data.inc"
;  .align 64
  .include "track_dpcm.inc"
NameTable:
  .include "name_table.inc"

;.advance $C000
  .include "sprite_overlay.inc"
  .include "../../KongRender.asm"
  .include "ggsound.asm"


; Skip the program counter up to the final bank and pad up the empty space.
.advance $E000
  ; Throw the important shit here where we know it'll be loaded.
RESET:
  JSR ResetNES
  JSR WaitVBlank
  JSR ClearRAM
  `clearStack
  JSR ClearSprites
  JSR WaitVBlank

  JSR DisableGFX
  `LoadBGPalette DemoBGPalette
  `LoadSpritePalette DemoSpritePalette
  JSR ClearNameTables

  ; Now we're safe to render graphics.
  LDX #<NameTable
  LDY #>NameTable
  LDA #NT2
  JSR RenderNameTable

  ; Load Sprites
  LDA #>sprites
  STA SpriteDMA
  LDA #$20
  STA VRAMIO
  LDA #$00
  STA VRAMAddr
  STA BGScroll
  LDA $88
  STA VRAMAddr


  ; Turn on the graphics.
  JSR EnableGFX

  ; Set up the sound engine.
  lda #0
    ;sta nmis
    ;jsr get_tv_system
    ;tax
    LDA #$00
    STA current_song
    ;LDA #$00
    STA pause_flag
    sta sound_param_byte_0
    LDA #<song_list
    sta sound_param_word_0
    lda #>song_list
    sta sound_param_word_0+1
    lda #<sfx_list
    sta sound_param_word_1
    lda #>sfx_list
    sta sound_param_word_1+1
    lda #<instrument_list
    sta sound_param_word_2
    lda #>instrument_list
    sta sound_param_word_2+1
    lda #<dpcm_list
    sta sound_param_word_3
    lda #>dpcm_list
    sta sound_param_word_3+1
    jsr sound_initialize
    ;load a song
    lda current_song
    sta sound_param_byte_0
    jsr play_song


MainLoop:
  JMP MainLoop

NMI:
  ;JMP MainLoop
  `soundengine_update
  RTI

  ; Skip to the end and set up our vector table.
.advance $FFFA
  .word NMI
  .word RESET
  .word 0