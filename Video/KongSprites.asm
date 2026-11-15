; OAM shadow helpers and metasprites. Requires ZeroPage/KongExtZP.asm.
;
; Per frame:
;     JSR OAMBegin            ; start filling at sprite 1
;     ...set MSprPtr/MSprX/MSprY, JSR DrawMetaSprite, as often as needed...
;     JSR OAMClearRest        ; hide whatever's left over
; then DMA KongOAM from your NMI.
;
; Sprite 0 is never touched by these routines, so it's free for a
; sprite-0 hit or anything else you want to pin in place.

  .alias  KongOAM     $0200

; Reset OAMIndex to sprite 1.
OAMBegin:
  LDA #$04
  STA OAMIndex
  RTS

; Hide every sprite from OAMIndex to the end of OAM.
OAMClearRest:
  LDX OAMIndex
  BEQ +                   ; Zero means OAM wrapped around: it's full.
  LDA #$FF
* STA KongOAM, X
  INX
  INX
  INX
  INX
  BNE -
* RTS

; Draw the metasprite at MSprPtr, anchored at (MSprX, MSprY).
;
; Definition format:
;     .byte count
;     .byte dy, tile, attr, dx      ; count times; dy/dx are signed
;
; MSprX and MSprY are 16-bit signed screen coordinates, so a metasprite
; can hang off any edge; sprites that land off screen are skipped.
; MSprAttr is EORed into every attribute byte (palette swaps, priority).
; Setting MSprFlip to $40 mirrors the whole thing horizontally around
; the anchor, so define metasprites centered on it (dx -8 and 0 for a
; 16-pixel-wide one). Sprites above scanline MSprClipTop are skipped,
; which keeps them off a status bar. Clobbers A, X and Y.
DrawMetaSprite:
.scope
  LDY #$00
  LDA (MSprPtr), Y
  BEQ _rts
  STA MSprTmp             ; MSprTmp = sprites left to draw
  INY
  LDX OAMIndex
_loop:
  CPX #$00
  BEQ _out                ; OAM is full.

  ; Y position
  LDA (MSprPtr), Y
  CLC
  ADC MSprY
  STA KongOAM, X
  LDA (MSprPtr), Y
  AND #$80
  BEQ +
  LDA #$FF
* ADC MSprY+1
  BNE _skipFromY          ; High byte non-zero: off screen.
  LDA KongOAM, X
  CMP MSprClipTop
  BCC _skipFromY
  CMP #$EF
  BCS _skipFromY

  ; X position, mirrored to -dx-8 when flipping.
  INY
  INY
  INY
  LDA (MSprPtr), Y
  BIT MSprFlip
  BVC +
  EOR #$FF
  SEC
  SBC #$07
* STA MSprTmp+1
  CLC
  ADC MSprX
  STA KongOAM+3, X
  LDA MSprTmp+1
  AND #$80
  BEQ +
  LDA #$FF
* ADC MSprX+1
  BNE _skipFromX

  ; Tile and attributes.
  DEY
  DEY
  LDA (MSprPtr), Y
  STA KongOAM+1, X
  INY
  LDA (MSprPtr), Y
  EOR MSprAttr
  EOR MSprFlip
  STA KongOAM+2, X
  INY
  INY                     ; Next definition entry.
  INX
  INX
  INX
  INX
  DEC MSprTmp
  BNE _loop
_out:
  STX OAMIndex
_rts:
  RTS

_skipFromY:
  INY
  INY
  INY
_skipFromX:
  INY
  DEC MSprTmp
  BNE _loop
  STX OAMIndex
  RTS
.scend
