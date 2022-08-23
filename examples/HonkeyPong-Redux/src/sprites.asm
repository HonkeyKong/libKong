; HonkeyPong Sprites
; Sprites are stored in OAM
; in the following order:
; Y Pos, Index, Attr, X Pos

Paddle1Top:
  .byte $78, $9F, $00, $10	; Paddle 1 top
Paddle1Mid:
  .byte $80, $9E, $00, $10	; Paddle 1 center
Paddle1Bot:
  .byte $88, $A0, $00, $10	; Paddle 1 bottom

Paddle2Top:
  .byte $78, $9F, $41, $E8	; Paddle 2 top
Paddle2Mid:
  .byte $80, $9E, $41, $E8	; Paddle 2 center
Paddle2Bot:
  .byte $88, $A0, $41, $E8	; Paddle 2 bottom

BallSprite:
  .byte $80, $B8, $02, $7C	; Initial ball state

TCSprite:
  .byte $96, $B8, $02, $50	; Title Cursor sprite

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

BallRotation:
  .byte $B8, $B8, $B8, $B8, $9D, $9D, $9D, $9D
  .byte $B8, $B8, $B8, $B8, $9D, $9D, $9D, $9D

BallAngle:
  .byte $00, $00, $00, $00, $00, $00, $00, $00
  .byte SpriteFlipY|SpriteFlipX, SpriteFlipY|SpriteFlipX, SpriteFlipY|SpriteFlipX, SpriteFlipY|SpriteFlipX
  .byte SpriteFlipY|SpriteFlipX, SpriteFlipY|SpriteFlipX, SpriteFlipY|SpriteFlipX, SpriteFlipY|SpriteFlipX
