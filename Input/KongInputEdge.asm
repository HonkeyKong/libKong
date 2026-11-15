; Edge detection for controller input. Requires ZeroPage/KongExtZP.asm.
;
; ReadController1/2 keep last frame's state in BufferP1/P2, so after
; reading the pads, call UpdatePressed to get only the buttons that went
; down this frame in PressedP1/P2. Use those for menus, jumping, firing:
; anything that shouldn't repeat while the button is held.

UpdatePressed:
  LDA BufferP1
  EOR #$FF
  AND ButtonsP1
  STA PressedP1
  LDA BufferP2
  EOR #$FF
  AND ButtonsP2
  STA PressedP2
  RTS
