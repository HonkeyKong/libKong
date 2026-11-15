; VRAM update buffer.
;
; You can't touch VRAM while the PPU is drawing, so game logic queues its
; nametable, attribute and palette changes here during the frame, and the
; NMI handler copies them in with VRAMBufFlush while VBlank lasts.
;
; Requires ZeroPage/KongExtZP.asm, plus one alias you define before
; including this file:
;
;   .alias VRAMBuffer $0300     ; 256 bytes of RAM, anywhere you like
;
; Buffer format, a list of runs ended by a zero byte:
;
;   [length | flags] [address high] [address low] [data...]
;
; length is 1-63. Flags:
  .alias  VRAMBufInc32  $80     ; Step the address by 32 (write a column)
  .alias  VRAMBufFill   $40     ; One data byte, repeated length times
;
; Budget: VBlank leaves room for roughly 120-150 bytes of runs once OAM DMA
; is done. The buffer itself doesn't check for overflow.

; Empty the buffer. Call once at startup; VRAMBufFlush does it afterwards.
VRAMBufReset:
  LDA #$00
  STA VRAMBufIdx
  STA VRAMBuffer
  RTS

; Start a run. A = length | flags, X = VRAM address high, Y = low.
; Returns X = buffer index to store the data at:
;     STA VRAMBuffer, X
;     INX
; and finish with JSR VRAMBufEnd while X still points past the data.
VRAMBufBegin:
  PHA
  TXA
  LDX VRAMBufIdx
  STA VRAMBuffer+1, X
  TYA
  STA VRAMBuffer+2, X
  PLA
  STA VRAMBuffer, X
  INX
  INX
  INX
  RTS

; Close the run started by VRAMBufBegin. X = index just past the data.
VRAMBufEnd:
  LDA #$00
  STA VRAMBuffer, X
  STX VRAMBufIdx
  RTS

; Queue a single byte. A = value, X = address high, Y = address low.
VRAMBufPutByte:
  PHA
  LDA #$01
  JSR VRAMBufBegin
  PLA
  STA VRAMBuffer, X
  INX
  JMP VRAMBufEnd

; Copy every queued run into VRAM and empty the buffer. Call during
; VBlank (or with rendering off). Uses PPUSettings as the base value for
; $2000, toggling only the increment bit, and leaves $2000 = PPUSettings.
; You'll need to set the scroll again afterwards.
VRAMBufFlush:
.scope
  LDX #$00
_next:
  LDA VRAMBuffer, X
  BEQ _done
  INX
  TAY                     ; Y = length and flags, for now
  BMI _inc32
  LDA PPUSettings
  AND #[$FF ^ PPUInc32]
  JMP _setCtrl
_inc32:
  LDA PPUSettings
  ORA #PPUInc32
_setCtrl:
  STA PPUControl1
  LDA VRAMBuffer, X
  STA VRAMAddr
  INX
  LDA VRAMBuffer, X
  STA VRAMAddr
  INX
  TYA
  AND #VRAMBufFill
  BNE _fill
  TYA
  AND #$3F
  TAY
_copy:
  LDA VRAMBuffer, X
  STA VRAMIO
  INX
  DEY
  BNE _copy
  JMP _next
_fill:
  TYA
  AND #$3F
  TAY
  LDA VRAMBuffer, X
  INX
_fillLoop:
  STA VRAMIO
  DEY
  BNE _fillLoop
  JMP _next
_done:
  STA VRAMBufIdx          ; A is zero here.
  STA VRAMBuffer
  LDA PPUSettings
  STA PPUControl1
  RTS
.scend
