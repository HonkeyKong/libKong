; This subroutine takes the screen address from X & Y
; and Nametable address from A, reads the coordinates, 
; then renders the string to the screen until it runs 
; into a terminating character ($FF), grabs the next 
; string & repeats until the screen terminator. ($FE)

RenderTextScreen:
  STX StrAddr         ; Store lower string address
  STY StrAddr+1       ; Store upper string address
  STA NtTmp           ; Store upper nametable address
  
  LDY #$FF            ; Load Y with $FF so it overflows
                      ; when the loop starts with INY.
* INY                 ; Start loop, increment Y
  LDA NtTmp           ; Load Upper nametable byte
  STA TextOffset+1    ; Store in upper offset.
  
  LDA (StrAddr), Y    ; Load the Y position.
  TAX                 ; Transfer A to X
  LDA #$00            ; Clear the accumulator
  STA TextOffset      ; Store in lower offset.
* LDA TextOffset      ; Load lower offset
  CLC                 ; Clear carry bit
  ADC #$20            ; Add 32 (Increment by one row of tiles)
  STA TextOffset      ; Store result in text offset
  LDA TextOffset+1    ; Load upper byte
  ADC #$00            ; Add 0 (But keep the carry bit)
  STA TextOffset+1    ; Store result (!Not Useless!)
  DEX                 ; Decrement X
  CPX #$00            ; Check if we've run out of loops
  BNE -               ; Branch up if not equal (keep adding)
  
  INY                 ; Increment Y to seek X position
  LDA (StrAddr), Y    ; Load X position into accumulator
  CLC                 ; Clear carry bit
  ADC TextOffset      ; Add the text offset
  STA TextOFfset      ; Store the new offset
  LDA TextOFfset+1    ; Load the upper offset
  ADC #$00            ; Add the carry bit
  STA TextOffset+1    ; Store new upper offset
  
  LDA TextOffset      ; Load text offset
  SEC                 ; Set the carry bit
  SBC #$01            ; Subtract 1
  STA TextOffset
  LDA TextOffset+1
  SBC #$00
  STA TextOffset+1
  
  LDA PPUStatus       ; Latch the PPU register
  
  LDA TextOffset+1    ; Load upper offset
  STA VRAMAddr        ; Write to address register
  LDA TextOffset      ; Load lower offset
  STA VRAMAddr        ; Write to address register
  
* LDA (StrAddr), Y    ; Load next byte in string
  CMP #$FE            ; Is it an end-of-screen marker?
  BEQ ++              ; Yes? RTS.
  LDA (StrAddr), Y    ; No? Let's load it again.
  CMP #$FF            ; Is it an end of string marker?
  BEQ ---             ; Yes? Branch back to the start of the loop.
  CPY #$FF            ; Is Y about to overflow?
  BNE +               ; No? Skip this next bit.
  INC StrAddr+1       ; Increment the upper string address.
* INY                 ; Increment Y
  STA VRAMIO          ; Store byte in VRAM I/O register
  LDA #$00            ; Clear Accumulator
  STA TextOffset      ; Clear lower text offset
  JMP --              ; Loop back and read next byte.
* LDA #$00
  STA TextOffset
  STA TextOffset+1
  RTS