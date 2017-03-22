; PPU Macros

; This is just a simple way to send configuration info
; to the PPU, best used in combination with the aliases
; defined for configuration in KongPPU. Just OR them 
; together to flip the necessary bits for your setup.
.macro ConfigurePPU		; `ConfigurePPU configBits
  JSR WaitVBlank
  LDA #_1
  STA PPUControl1
.macend

; Background Palette loading macro
.macro LoadBGPalette 		; `LoadBGPalette address
  `setPPU BGPalette
  LDX #$00
_BGpaletteLoop:
  LDA _1, x      		;load palette byte
  STA VRAMIO            ;write to PPU
  INX                   ;set index to next byte
  CPX #$10            
  BNE _BGpaletteLoop      ;if x = $10, 16 bytes copied, all done
.macend

; Sprite Palette loading macro
.macro LoadSpritePalette 		; `LoadSpritePalette address
  `setPPU SpritePalette
  LDX #$00
_SprpaletteLoop:
  LDA _1, x      		;load palette byte
  STA VRAMIO            ;write to PPU
  INX                   ;set index to next byte
  CPX #$10            
  BNE _SprpaletteLoop      ;if x = $10, 16 bytes copied, all done
.macend

; This macro sets the 16-bit I/O address for the PPU.
.macro setPPU 			; `setPPU address
  LDA PPUStatus         ; read PPU status to reset the high/low latch
  LDA #>_1
  STA VRAMAddr          ; write the high byte of nametable address
  LDA #<_1
  STA VRAMAddr          ; write the low byte of nametable address
.macend
