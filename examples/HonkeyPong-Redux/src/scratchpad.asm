
SmokePuff1:
  .byte $FE, $9A, $03, $FE

SmokePuff2:
  .byte $FE, $9B, $03, $FE

SmokePuff3:
  .byte $FE, $9C, $03, $FE

SPUpLeft:
  .byte SpritePal3|SpriteFlipX

SPUpRight:
  .byte SpritePal3

SPDownRight:
  .byte SpritePal3|SpriteFlipY

SPDownLeft:
  .byte SpritePal3|SpriteFlipX|SpriteFlipY

CheckSmoke:
  LDA BallSpeedY
  CMP #$05
  BNE SmokeEnd
  LDA BallUp
  BEQ SmokeDown
  LDA BallLeft
  BEQ SmokeUpRight
  ; Put the Up/Left Smoke Puff logic here.
  ;X Co-ordinates
  LDA BallX
  SEC
  ADC #$08
  STA Puff1+SpriteXPos
  SEC
  ADC #$08
  STA Puff2+SpriteXPos
  SEC
  ADC #$08
  STA Puff3+SpriteXPos
  ; Y Co-ordinates
  LDA BallY
  SEC
  ADC #$08
  STA Puff1+SpriteYPos
  SEC
  ADC #$08
  STA Puff2+SpriteYPos
  ADC #$08
  STA Puff2+SpriteYPos
  LDA SPUpRight
  STA Puff1+SpriteAttr
  STA Puff2+SpriteAttr
  STA Puff3+SpriteAttr
  JMP SmokeEnd
SmokeUpRight:
  ; Put the Up/Right logic here.
  LDA BallX
  SEC
  ADC #$08
  STA Puff1+SpriteXPos
  SEC
  ADC #$08
  STA Puff2+SpriteXPos
  SEC
  ADC #$08
  STA Puff3+SpriteXPos
  ; Y Co-ordinates
  LDA BallY
  SEC
  ADC #$08
  STA Puff1+SpriteYPos
  SEC
  ADC #$08
  STA Puff2+SpriteYPos
  ADC #$08
  STA Puff2+SpriteYPos
  LDA SPUpRight
  STA Puff1+SpriteAttr
  STA Puff2+SpriteAttr
  STA Puff3+SpriteAttr
  JMP SmokeEnd
SmokeDown:
  LDA BallLeft
  BEQ SmokeDownRight
  ; Put the Down/Left logic here.
SmokeDownRight:
  ; Put the Down/Right logic here.
SmokeEnd:
  JSR SetSmoke
  RTS

  ; Logic for smoke trail

(When these positions are > TOPWALL & < BOTTOMWALL)

Ball moving Up+Left:
Puff 1 = BallX + 8, BallY + 8   (Attribute SpriteFlipX)
Puff 2 = BallX + 16, BallY + 16 (Attribute SpriteFlipX)
Puff 3 = BallX + 24, BallY + 24 (Attribute SpriteFlipX)

Ball moving Up+Right:           (Attribute 00)
Puff 1 = BallX - 8, BallY + 8   (Attribute 00)
Puff 2 = BallX - 16, BallY + 16 (Attribute 00)
Puff 3 = BallX - 24, BallY + 24 (Attribute 00)

Ball moving Down+Right:
Puff 1 = BallX - 8, BallY - 8   (Attribute SpriteFlipY)
Puff 2 = BallX - 16, BallY - 16 (Attribute SpriteFlipY)
Puff 3 = BallX - 24, BallY - 24 (Attribute SpriteFlipY)

Ball moving Down+Left:
Puff 1 = BallX + 8, BallY - 8   (Attribute SpriteFlipX|SpriteFlipY)
Puff 2 = BallX + 16, BallY - 16 (Attribute SpriteFlipX|SpriteFlipY)
Puff 3 = BallX + 24, BallY - 24 (Attribute SpriteFlipX|SpriteFlipY)


SetSmoke:
  LDA BallSpeedY
  CMP #$05
  BEQ SetSmokeEnd
  LDA #$FE
  STA Puff1
  STA Puff1+3
  STA Puff2
  STA Puff2+3
  STA Puff3
  STA Puff3+3
SetSmokeEnd:
  RTS
