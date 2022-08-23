; Subroutines for rendering blank tiles and rows.
; This helps to compress 1K nametables down to
; smaller procedurally-generated maps.
; Basically a lousy version of RLE (Run-Length Encoding)
; that only handles blank space, but even this can improve
; data sizes dramatically in certain scenarios.

WriteBlankRows:
  TYA                 ; Transfer Y to Accumulator.
  PHA                 ; PusH Accumulator to stack.
  LDY #$00            ; Clear Y for row counter.
* LDA #$20            ; Load 32 into Accumulator
  STA BlankTiles      ; Tell the function to write 32 tiles.
  JSR WriteBlankTiles ; Write the blank tiles.
  INY                 ; Increment the row counter.
  CPY BlankRows       ; Compare Y to blank row total.
  BNE -               ; Repeat if not equal.
  LDA #$00            ; Clear the Accumulator.
  STA BlankRows       ; Zero out blank rows.
  PLA                 ; PuLl Accumulator from stack.
  TAY                 ; Transfer Accumulator to Y. (Restore Y)
  RTS

WriteBlankTiles:
  TXA                 ; Transfer X to Accumulator.
  PHA                 ; Push Accumulator to stack.
  LDX #$00            ; Clear X for column counter.
* LDA #$00            ; Load #$00 (blank tile index)
  STA VRAMIO          ; Write to VRAM I/O register.
  INX                 ; Increment X.
  CPX BlankTiles      ; Compare X to blank tile total.
  BNE -               ; Branch up if not equal.
  LDA #$00            ; Clear accumulator.
  STA BlankTiles      ; Reset blank tile counter.
  PLA                 ; Pull Accumulator from stack.
  TAX                 ; Transfer A to X. (Restore X)
  RTS  

RenderNameTable:      ; X = Low byte, Y = High byte. A = NT0, NT1, NT2, or NT3
  STX MapAddr
  STY MapAddr+1

  PHA                 ; Push the upper nametable byte into the stack.
  LDA PPUStatus       ; Reset the PPU latch.
  PLA                 ; Pull it back from the stack.
  STA VRAMAddr        ; Store in VRAM Address register.
  LDA #$00            ; Set the lower byte.
  STA VRAMAddr        ; Store just like the upper byte.
  
  LDY #$00            ; Clear low byte counter
  LDX #$04            ; Set loop counter (256 x 4 = 1024, 1 kilobyte)

* LDA (MapAddr), Y    ; Load nametable byte at MapAddr, incremented by Y
  STA VRAMIO          ; Write byte through VRAM I/O register.
  INY                 ; Increment low byte counter
  CPY #$FF            ; Have we written 256 bytes yet? (8-bit limit)
  BNE -               ; If not, loop back.
  INC MapAddr+1       ; If so, increment high byte of map address
  DEX                 ; Decrease loop counter.
  CPX #$00            ; Are there any loops left?
  BNE -               ; If so, start writing VRAM again.
  RTS                 ; If not, we're all done. Return.

ClearAttribute:       ; A = AT0, AT1, AT2, or AT3
  PHA                 ; PusH Accumulator into stack.
  LDA PPUStatus       ; Latch the PPU
  PLA                 ; PulL Accumulator from stack.
  STA VRAMAddr        ; Store in VRAM Address Register
  LDA #$00            ; Load that lower byte.
  LDX #$00            ; Zero out X to use as a counter.
  STA VRAMAddr        ; Store it in VRAM Address too.
* STA VRAMIO          ; Then store it in VRAM IO to clear it.
  INX                 ; Increment our counter.
  CPX #$40            ; Check against #$40 (64)
  BNE -               ; Branch up if Not Equal
  RTS                 ; ReTurn from Subroutine
