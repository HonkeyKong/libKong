; Input Registers

  .alias	Pad1	$4016
  .alias	Pad2	$4017 
; Note: The upper bits of $4017 are also
; the APU's frame counter. To keep from
; corrupting it, we latch Pad1's register
; while reading Pad2 instead. It works OK.

; Bitmasks used for button testing
  .alias  BUTTON_A        %10000000
  .alias  BUTTON_B        %01000000
  .alias  BUTTON_SELECT   %00100000
  .alias  BUTTON_START    %00010000
  .alias  DPAD_UP         %00001000
  .alias  DPAD_DOWN       %00000100
  .alias  DPAD_LEFT       %00000010
  .alias  DPAD_RIGHT      %00000001

; Write 1 then 0 to the controller register
; to reset the latch, then read it and shift 
; the bottom-most bit into the carry bit, then
; rotate it back into our input byte. This 
; gives us a bitmask of the controller state 
; that we can check for individual buttons 
; instead of checking each bit in sequence.

ReadController1:
  LDA ButtonsP1
  STA BufferP1
  LDA #$01
  STA Pad1
  LDA #$00
  STA Pad1
  LDX #$08
* LDA Pad1
  LSR	              ; bit0 -> Carry
  ROL ButtonsP1     ; bit0 <- Carry
  DEX
  BNE -
  RTS
  
ReadController2:
  LDA ButtonsP2
  STA BufferP2
  LDA #$01
  STA Pad1
  LDA #$00
  STA Pad1
  LDX #$08
* LDA Pad2
  LSR	              ; bit0 -> Carry
  ROL ButtonsP2	    ; bit0 <- Carry
  DEX
  BNE -
  RTS

Check4Players:
  ; Player 1
  LDA #$01
  STA Pad1
  LDA #$00
  STA Pad1
  LDX #$08
* LDA Pad1
  LSR
  ROL ButtonsP1
  DEX
  CPX #$00
  BNE -
  ; Player 3
  LDX #$08
* LDA Pad1
  LSR
  ROL ButtonsP3
  DEX
  CPX #$00
  BNE -
  ; Port 1 Signature
  LDX #$08
* LDA Pad1
  LSR
  ROL Port1Sig
  DEX
  CPX #$00
  BNE -
  ; Player 2
  LDA #$01
  STA Pad1
  LDA #$00
  STA Pad1
  LDX #$08
* LDA Pad2
  LSR
  ROL ButtonsP2
  DEX
  CPX #$00
  BNE -
  ; Player 4
  LDX #$08
* LDA Pad2
  LSR
  ROL ButtonsP4
  DEX
  CPX #$00
  BNE -
  ; Port 2 Signature
  LDX #$08
* LDA Pad2
  LSR
  ROL Port2Sig
  DEX
  CPX #$00
  BNE -
  LDA Port1Sig
  CMP #$10
  BNE +
  LDA Port2Sig
  CMP #$20
  BNE +
  LDA #$01
  STA HasFourScore
* RTS

ReadController1and3:
  LDA ButtonsP1
  STA BufferP1
  LDA #$01
  STA Pad1
  LDA #$00
  STA Pad1
  LDX #$08
* LDA Pad1
  LSR               ; bit0 -> Carry
  ROL ButtonsP1     ; bit0 <- Carry
  DEX
  BNE -
  LDA ButtonsP3
  STA BufferP3
  LDA #$01
  STA Pad1
  LDA #$00
  STA Pad1
  LDX #$08
* LDA Pad1
  LSR               ; bit0 -> Carry
  ROL ButtonsP3     ; bit0 <- Carry
  DEX
  BNE -
  RTS
  
ReadController2and4:
  LDA ButtonsP2
  STA BufferP2
  LDA #$01
  STA Pad1
  LDA #$00
  STA Pad1
  LDX #$08
* LDA Pad2
  LSR               ; bit0 -> Carry
  ROL ButtonsP2     ; bit0 <- Carry
  DEX
  BNE -
  LDA ButtonsP4
  STA BufferP4
  LDA #$01
  STA Pad1
  LDA #$00
  STA Pad1
  LDX #$08
* LDA Pad2
  LSR               ; bit0 -> Carry
  ROL ButtonsP4     ; bit0 <- Carry
  DEX
  BNE -
  RTS