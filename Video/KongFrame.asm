; Frame sync and safe rendering on/off. Requires ZeroPage/KongExtZP.asm.
;
; These assume your NMI handler does "INC FrameCount" once per frame and
; writes PPUSettings to $2000 and PPUMaskSettings to $2001 (directly or
; through its own copies).

; Wait for the next NMI to finish.
WaitFrame:
  LDA FrameCount
* CMP FrameCount
  BEQ -
  RTS

; Turn off NMIs and rendering at the start of VBlank, so the screen
; doesn't tear. Afterwards you have the PPU to yourself for as long as
; you need: write VRAM directly, then call RenderingOn.
RenderingOff:
  LDA PPUSettings
  BPL +                   ; NMI already off: just wait for VBlank.
  JSR WaitFrame
  JMP ++
* JSR WaitVBlank
* LDA PPUSettings
  AND #[$FF ^ NMIonVBlank]
  STA PPUSettings
  STA PPUControl1
  LDA #$00
  STA PPUMaskSettings
  STA PPUControl2
  RTS

; Turn NMIs back on. A = the $2001 bits you want (BGVisible|SprVisible...);
; it's stored in PPUMaskSettings for the NMI handler to apply, so the
; screen comes back cleanly at the start of the next frame.
RenderingOn:
  STA PPUMaskSettings
  BIT PPUStatus           ; Clear a pending VBlank flag so the NMI
  LDA PPUSettings         ; doesn't fire halfway through VBlank.
  ORA #NMIonVBlank
  STA PPUSettings
  STA PPUControl1
  RTS
