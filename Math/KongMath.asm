; Small math helpers. Requires ZeroPage/KongExtZP.asm.

; Pseudo-random byte in A, from a 16-bit Galois LFSR (period 65535).
; Seed RandSeed with anything but $0000 first. Clobbers Y, keeps X.
KongRandom:
  LDY #$08
  LDA RandSeed
* ASL
  ROL RandSeed+1
  BCC +
  EOR #$39
* DEY
  BNE --
  STA RandSeed
  CMP #$00
  RTS

; Split A (0-255) into decimal digits: KongDigits = hundreds, tens, ones.
; Add $30 to each for ASCII-ordered fonts. Keeps X and Y.
KongByteToDigits:
.scope
  PHA
  LDA #$00
  STA KongDigits
  STA KongDigits+1
  PLA
_hundreds:
  CMP #100
  BCC _tens
  SBC #100                ; Carry is already set.
  INC KongDigits
  JMP _hundreds
_tens:
  CMP #10
  BCC _ones
  SBC #10
  INC KongDigits+1
  JMP _tens
_ones:
  STA KongDigits+2
  RTS
.scend
