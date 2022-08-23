; Game engine

 .include "titlecard.asm"
 .include "titlescreen.asm"
 .include "creditscreen.asm"
 .include "gameplay.asm"

.macro setPlayfieldAttr ; `setPlayfieldAttr Background, Attribute
  LDX #<_1
  LDY #>_1
  JSR SetFieldBG
  LDX #<_2
  LDY #>_2
  JSR SetFieldAttr
.macend

EnginePaused:

  ; TXA
  ; PHA
  ; LDX PauseFrameCounter
  ; DEX
  ; CPX #$00
  ; BCS +

  ; LDA GamePlayPaused
  ; CMP #$01
  ; BNE +
  ; JSR FamiToneUpdate
  LDA ButtonsP1
  AND #BUTTON_A
  BEQ +
  ; CMP BufferP1
  ; BEQ +
  ; LDA #$00
  ; STA GamePaused
  ; STA GamePlayPaused
  ; JSR WaitVBlank
  LDX #<ClearPause
  LDY #>ClearPause
  LDA #NT2
  JSR RenderTextScreen
  JSR ResetScroll
  LDA #STATEPLAYING
  STA GameState
* RTS

EngineGameOver:

  LDA ButtonsP1
  AND #BUTTON_A
  BEQ +
  LDA #$00
  STA PlayScoreSound
  LDA #STATETITLE
  STA GameState
* RTS

CheckPauseTimer:
  LDA GamePaused        ; Check if pause flag is set.
  CMP #$01
  BNE ++                ; If it isn't, skip ahead and return.
  LDX FrameCounter      ; Read out the frame counter.
  INX                   ; Increment frame counter on X register.
  CPX #$3C              ; Is the frame counter at 60? (1 second)
  BNE +                 ; If not, skip the next two instructions.
  INC PauseTimer        ; Increment the pause timer by one second.
  LDX #$00              ; Reset the frame counter on X.
* STX FrameCounter      ; Store new X value into frame counter.

  LDA PauseTimer                ; Read pause timer (updated once per second).
  CMP PauseDuration             ; Has the duration passed?
  BNE +                         ; If not, branch ahead.
  LDA #$00                      ; If so, clear out the accumulator.
  STA PauseTimer                ; Clear the pause timer.
  STA PauseDuration             ; Clear pause duration.
  STA GamePaused                ; Unpause the game logic.
* RTS

DrawScore:
  LDA ScoreP1Updated
  BEQ +
  JSR SetScoreP1
  LDA #$00
  STA ScoreP1Updated

* LDA ScoreP2Updated
  BEQ +
  JSR SetScoreP2
  LDA #$00
  STA ScoreP2Updated
* RTS

ResetPlayfield:
  LDA #$01
  STA BallDown
  LDA #$00
  STA BallUp

  LDA #$20
  STA BallY

  LDA #$80
  STA BallX

  LDA #$02
  STA BallSpeedX
  STA BallSpeedY

  LDA #$78
  STA Paddle1YTop
  STA Paddle2YTop

  LDA #$90
  STA Paddle1YBot
  STA Paddle2YBot

  RTS

SetScoreP1:
  `setPPU ScoreP1Loc
  LDX ScoreP1
  CPX #$0A
  BEQ SetP1Win
  LDA scoreTable, X
  STA VRAMIO
  JMP SetP1Done

SetP1Win:
  `setPPU ScoreP1Loc
  LDX #$00
* LDA scoreWin, X
  STA VRAMIO
  INX
  CPX #$03
  BNE -
  `setPPU ScoreP2Loc
  LDX #$00
* LDA scoreLose, X
  STA VRAMIO
  INX
  CPX #$04
  BNE -
  JSR FamiToneMusicStop
  LDA #$03                ; Set the track
  JSR FamiToneMusicPlay   ; Play the track
  LDA #STATEGAMEOVER
  STA GameState
SetP1Done:
  RTS

SetScoreP2:
  `setPPU ScoreP2Loc
  LDX ScoreP2
  CPX #$0A
  BEQ SetP2Win
  LDA scoreTable, X
  STA VRAMIO
  JMP SetP2Done

SetP2Win:
  `setPPU ScoreP2Loc
  LDX #$00
* LDA scoreWin, X
  STA VRAMIO
  INX
  CPX #$03
  BNE -
  `setPPU ScoreP1Loc
  LDX #$00
* LDA scoreLose, X
  STA VRAMIO
  INX
  CPX #$04
  BNE -
  JSR FamiToneMusicStop
  LDA #$04
  JSR FamiToneMusicPlay
  LDA #STATEGAMEOVER
  STA GameState

SetP2Done:
  RTS

RotateBall:
  LDA BallFrame           ; Load the ball's frame counter.
  CMP #$10                ; Check if it's reached 16.
  BNE +                   ; If not, skip to the rotation logic.
  LDA #$00                ; If so, reset the counter.
  STA BallFrame           ; Store back into RAM.
* TAY                     ; Transfer A to Y
  LDX #$02                ; Load sprite attribute byte offset
  LDA BallSprite, X       ; Read default ball attributes.
  ORA BallAngle, Y        ; OR attributes with Rotation LUT + Frame offset.
  STA BallAttr            ; Store new attributes into OAM.
  LDA BallRotation, Y
  STA BallIndex
  INY                     ; Increment frame counter.
  STY BallFrame           ; Store back into RAM.
  RTS

UpdateSprites:
  ; The first OAM byte for a sprite is always
  ; The Y position, so to update Y, it's safe
  ; to write an 8-bit value directly to its 
  ; base address in memory.

  LDA GameState
  CMP #STATEPLAYING
  BEQ UpdateBall
  JMP PuffDone

UpdateBall:
  ; Update Ball
  LDA BallY
  STA Ball

  ; This doesn't necessarily need to be between
  ; the X and Y bytes, but I feel it's cleaner
  ; to update the OAM in sequence rather than
  ; doing it all in random order.
  
  JSR RotateBall

  ; X is always the 4th OAM byte, so we update
  ; that by either writing to Base+3, or by
  ; Declaring an X variable in our OAM copy
  ; Stored 3 bytes ahead of the first OAM byte.
  LDA BallX
  STA BallXPos

  ; Update Player 1 Paddle
  LDA Paddle1YTop
  STA PaddleP1Top
  CLC
  ADC #$08
  STA PaddleP1Mid
  CLC
  ADC #$08
  STA PaddleP1Bot

  ; Update Player 2 Paddle
  LDA Paddle2YTop
  STA PaddleP2Top
  CLC
  ADC #$08
  STA PaddleP2Mid
  CLC
  ADC #$08
  STA PaddleP2Bot

  ; Skipping smoke trails until I un-fuck my code.
  JMP PuffDone

  ; Update Smoke Puffs
  ; $9A, $9B and $9C, small to large
  ; Counting backwards would probably make the most sense here.
  LDA BallSpeedY
  CMP #$05
  BEQ LoadPuffIndices
  JMP ClearSmoke
LoadPuffIndices:
  ; Load the proper tile indices.
  LDA #$9C
  STA Puff3+SpriteIndex
  LDA #$9B
  STA Puff2+SpriteIndex
  LDA #$9A
  STA Puff1+SpriteIndex

  ; Render smoke based on ball trajectory.

SmokeDownRight:
  LDA BallDown
  BEQ SmokeUpRight
  ;LDA BallRight
  ;BNE SmokeDownLeft
  ; Set the attributes for the smoke sprites.
  LDA #$00
  ORA SPDownRight
  STA Puff3+SpriteAttr
  STA Puff2+SpriteAttr
  STA Puff1+SpriteAttr
  ; Calculate smoke positions based on the ball's position.
  LDA BallY
  SEC
  SBC #$08
  STA Puff3+SpriteYPos
  SEC
  SBC #$08
  STA Puff2+SpriteYPos
  SEC
  SBC #$08
  STA Puff1+SpriteYPos
  LDA BallX
  SEC
  SBC #$04
  STA Puff3+SpriteXPos
  SEC
  SBC #$04
  STA Puff2+SpriteXPos
  SEC
  SBC #$04
  STA Puff1+SpriteXPos
  JMP PuffDone

SmokeUpRight:
  LDA BallRight
  BEQ SmokeUpLeft
  ;LDA BallUp
  ;BNE SmokeDownRight
  ; Set the attributes for the smoke sprites.
  LDA #$00
  ORA SPUpRight
  STA Puff3+SpriteAttr
  STA Puff2+SpriteAttr
  STA Puff1+SpriteAttr
  ; Set vertical position for smoke sprites.
  LDA BallY
  CLC
  ADC #$08
  STA Puff3+SpriteYPos
  CLC
  ADC #$08
  STA Puff2+SpriteYPos
  CLC
  ADC #$08
  STA Puff1+SpriteYPos
  ; Now set the horizontal position.
  LDA BallX
  SEC
  SBC $04
  STA Puff3+SpriteXPos
  SEC
  SBC #$04
  STA Puff2+SpriteXPos
  SEC
  SBC #$04
  STA Puff1+SpriteXPos
  JMP PuffDone

SmokeDownLeft:
  LDA BallDown
  BEQ SmokeUpLeft
  ;LDA BallLeft
  ;BNE SmokeDownRight

  LDA #$00
  ORA SPDownLeft
  STA Puff3+SpriteAttr
  STA Puff2+SpriteAttr
  STA Puff1+SpriteAttr
DownLeftY:
  ; Original Code
  LDA BallY
  SEC
  SBC #$08
  STA Puff3+SpriteYPos
  SEC
  SBC #$08
  STA Puff2+SpriteYPos
  SEC
  SBC #$08
  STA Puff1+SpriteYPos
  ; End Original

; Revised Code
;  LDA BallY
;  CLC
;  ADC #$08
;  STA Puff1+SpriteYPos
;  CLC
;  ADC #$08
;  STA Puff2+SpriteYPos
;  CLC
;  ADC #$08
;  STA Puff3+SpriteYPos
; End Revision
DownLeftX:  
  LDA BallX
  CLC
  ADC #$08
  STA Puff3+SpriteXPos
  CLC
  ADC #$08
  STA Puff2+SpriteXPos
  CLC
  ADC #$08
  STA Puff1+SpriteXPos
  JMP PuffDone

SmokeUpLeft:
  ;LDA BallUp
  ;BNE SmokeDownRight
  ;LDA BallLeft
  ;BNE SmokeUpRight

  LDA #$00
  ORA SPUpLeft
  STA Puff3+SpriteAttr
  STA Puff2+SpriteAttr
  STA Puff1+SpriteAttr

;  Original Code
;  LDA BallY
;  CLC
;  ADC #$08
;  STA Puff3+SpriteYPos
;  CLC
;  ADC #$08
;  STA Puff2+SpriteYPos
;  CLC
;  ADC #$08
;  STA Puff1+SpriteYPos
;  End Original

; Test Revision
  LDA BallY
  SEC
  SBC #$08
  STA Puff3+SpriteYPos
  SEC
  SBC #$08
  STA Puff2+SpriteYPos
  SEC
  SBC #$08
  STA Puff1+SpriteYPos
; End Revision


  LDA BallX
  CLC
  ADC #$04
  STA Puff3+SpriteXPos
  CLC
  ADC #$04
  STA Puff2+SpriteXPos
  CLC
  ADC #$04
  STA Puff1+SpriteXPos
  JMP PuffDone
  
ClearSmoke:
  ; Clear the tile indices if the sprites shouldn't be visible.
  LDA #$00
  STA Puff1+SpriteIndex
  STA Puff2+SpriteIndex
  STA Puff3+SpriteIndex

PuffDone:
* LDA GameState
  CMP #STATEGAMEOVER
  BNE +
  JSR RotateBall

* LDA GameState
  CMP #STATETITLE
  BNE UpdateSpritesDone

  LDY TitleCursorIndex  ; Pull current cursor index
  LDA TitleCursors, Y   ; Load position + index from LUT
  STA TitleCursor       ; Store position
  LDX #$01              ; Start on byte 1 of cursor OAM
* LDA TCSprite, X       ; Pull attribute byte
  STA TitleCursor, X    ; Store attribute byte
  INX                   ; Increment X
  CPX #$04              ; Are we finished yet?
  BNE -                 ; Nope, loop back.

;* LDA GameState
;  CMP #STATEOPTIONS
;  BNE UpdateSpritesDone

  ;LDY OptionsCursorIndex  ; Pull current cursor index
  ;LDA OptionsCursors, Y   ; Load position + index from LUT
  ;STA OptionsCursor       ; Store position
  ;LDX #$01                ; Start on byte 1 of cursor OAM
;* LDA OCSprite, X         ; Pull attribute byte
  ;STA OptionsCursor, X    ; Store attribute byte
  ;INX                     ; Increment X
  ;CPX #$04                ; Are we finished yet?
  ;BNE -                   ; Nope, loop back.

UpdateSpritesDone:
  RTS