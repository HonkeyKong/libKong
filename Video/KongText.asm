; This subroutine takes the screen address from X & Y
; and Nametable address from A, reads the coordinates, 
; then renders the string to the screen until it runs 
; into a terminating character ($FF), grabs the next 
; string & repeats until the screen terminator. ($FE)

; Moves Y to the next byte of the text data, and moves
; to the next page of the data when Y wraps around.
.macro nextStrByte
  INY
  BNE _samePage
  INC StrAddr+1
_samePage:
.macend

RenderTextScreen:
  STX StrAddr         ; Store lower string address
  STY StrAddr+1       ; Store upper string address
  STA NtTmp           ; Store upper nametable address
  
  LDY #$00            ; Start at the first byte of the data.
TextNextString:
  LDA NtTmp           ; Load Upper nametable byte
  STA TextOffset+1    ; Store in upper offset.
  LDA #$00            ; Clear the accumulator
  STA TextOffset      ; Store in lower offset.
  
  LDA (StrAddr), Y    ; Load the Y position.
  TAX                 ; Transfer A to X
  BEQ TextAddColumn   ; Row 0 doesn't need any rows added.
* LDA TextOffset      ; Load lower offset
  CLC                 ; Clear carry bit
  ADC #$20            ; Add 32 (Increment by one row of tiles)
  STA TextOffset      ; Store result in text offset
  LDA TextOffset+1    ; Load upper byte
  ADC #$00            ; Add 0 (But keep the carry bit)
  STA TextOffset+1    ; Store result (!Not Useless!)
  DEX                 ; Decrement X
  BNE -               ; Keep adding until we run out of rows.
  
TextAddColumn:
  `nextStrByte        ; Seek X position
  LDA (StrAddr), Y    ; Load X position into accumulator
  CLC                 ; Clear carry bit
  ADC TextOffset      ; Add the text offset
  STA TextOffset      ; Store the new offset
  LDA TextOffset+1    ; Load the upper offset
  ADC #$00            ; Add the carry bit
  STA TextOffset+1    ; Store new upper offset
  
  LDA PPUStatus       ; Latch the PPU register
  
  LDA TextOffset+1    ; Load upper offset
  STA VRAMAddr        ; Write to address register
  LDA TextOffset      ; Load lower offset
  STA VRAMAddr        ; Write to address register
  
  `nextStrByte        ; Seek the first character
* LDA (StrAddr), Y    ; Load next byte in string
  CMP #$FE            ; Is it an end-of-screen marker?
  BEQ TextDone        ; Yes? RTS.
  CMP #$FF            ; Is it an end of string marker?
  BEQ +               ; Yes? Move on to the next string.
  STA VRAMIO          ; Store byte in VRAM I/O register
  `nextStrByte        ; Seek the next character
  JMP -               ; Loop back and read next byte.
* `nextStrByte        ; Skip the end of string marker
  JMP TextNextString  ; Render the next string.
TextDone:
  LDA #$00
  STA TextOffset
  STA TextOffset+1
  RTS