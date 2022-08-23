PauseText:
  .byte 7, 7
  .byte "Press A to Resume."
  .byte $FE

ClearPause:
  .byte 7, 7
  .byte "                  "
  .byte $FE

EnginePlaying:

  ; Check if game logic is paused.
  LDA GamePaused
  CMP #$01
  BNE +                 ; If the game isn't paused, check the score.
  JMP PlayEngineDone    ; If it is paused, skip all the logic.
  
; * LDA GamePlayPaused
;   CMP #$01
;   BNE +
;   JMP PlayEngineDone
  
* LDA PlayScoreSound
  CMP #$01
  BNE +
  LDX #FT_SFX_CH0       ; Set effect channel 0
  LDA #$02              ; Set sound effect #2 (score)
  JSR FamiToneSfxPlay   ; Play sound effect.
  LDA #$00
  STA PlayScoreSound

  LDA #$01
  STA PauseDuration     ; Pause the game for 1 second.
  STA GamePaused        ; Set the paused flag.
  
  ; Check if the playfield has already been rendered.
* LDA FieldRendered
  CMP #$01
  BEQ CheckBall                	; If yes, skip rendering it again.

  ; Clear the title state.
  LDA #$00
  STA TitleShowing
  STA TitleCardShowing
  STA GameOverShowing
  STA CreditsShowing
  ;STA OptionsShowing
  JSR ClearSprites
  
  ; Set up and render the playing field.
  JSR DisableGFX
  JSR SetPalette
  
  `ConfigurePPU BGAddr0|Sprite8x8|SprAddr0|PPUInc1|NameTable20

  JSR ClearNameTables

  LDX #<ReduxField
  LDY #>ReduxField
  LDA #NT0
  JSR RenderNameTable

  `setPPU $22FF
  LDA #$00
  STA VRAMIO

  `ConfigurePPU NMIonVBlank|BGAddr0|Sprite8x8|SprAddr0|PPUInc1|NameTable20

  LDA #$01
  STA FieldRendered
  JSR InitSprites
  JSR EnableGFX

  LDA #$02                ; Set Track 3 (Gameplay Music)
  JSR FamiToneMusicPlay   ; Play the music!

  ; Check the direction of the ball and move it.
CheckBall:
  LDA BallRight		    ; Is the ball moving right?
  BEQ +      			    ; If not, skip ahead.

  LDA BallX
  CLC                 ; CLear the Carry bit.
  ADC BallSpeedX 	    ; ADd with Carry
  STA BallX           ; BallX = BallX + BallSpeedX

  ; Check for a collision against the right wall.
  LDA BallX
  CMP #RIGHTWALL
  BCC +               ; Branch if Carry Clear (if BallX < RIGHTWALL)
                      ; Skip ahead and keep moving right.

  INC ScoreP1         ; Give player 1 a point.
  LDA #$01
  STA ScoreP1Updated  ; Inform the game engine that the score has changed.
  STA BallLeft        ; Set the ball moving to the left. (Serve player 1)
  LDA #$00      
  STA BallRight       ; Clear the right-moving flag.
  JSR ResetPlayfield  ; Reset the playing field.

  ; This is the same as the right bit, only reversed.
* LDA BallLeft 		    ; Is the ball moving left?
  BEQ +   				    ; If not, skip ahead.

  LDA BallX
  SEC                 ; SEt the Carry bit.
  SBC BallSpeedX      ; SuBtract with Carry
  STA BallX           ; BallX = BallX - BallSpeedX

  LDA BallX
  CMP #LEFTWALL
  BCS +               ; Branch if Carry Set (if BallX > LEFTWALL)

  INC ScoreP2         ; Give player 2 a point.
  LDA #$01        
  STA ScoreP2Updated  ; Inform the game engine that the score has changed.
  STA BallRight       ; Set the ball moving to the right. (Serve player 2)
  LDA #$00
  STA BallLeft        ; Clear the left-moving flag.
  JSR ResetPlayfield  ; Reset the playing field.

  ; Move the ball up.
* LDA BallUp          ; Is the ball moving up?
  BEQ +               ; If not, skip ahead.

  LDA BallY
  SEC
  SBC BallSpeedY
  STA BallY           ; BallY = BallY - BallSpeedY
  CLC                 ; Clear the carry bit again.
  ADC #$08            ; Add 8 to ball Y position.
  STA BallBottom      ; Store as bottom boundary for collisions.

  LDA BallY
  CMP #TOPWALL
  BCS +               ; If (BallY < TOPWALL), skip ahead.
  
  LDX #FT_SFX_CH0     ; Set effect channel 0
  LDA #$01            ; Set sound effect #1 (Ping!)
  JSR FamiToneSfxPlay ; Play sound effect.

  LDA #$01
  STA BallDown        ; Set the down-moving flag.
  LDA #$00
  STA BallUp          ; Clear the up-moving flag, bounce down.

  ; Move the ball down.
* LDA BallDown        ; Is the ball moving down?
  BEQ CheckP1Up       ; If not, skip ahead.

  LDA BallY
  CLC
  ADC BallSpeedY  
  STA BallY           ; BallY = BallY + BallSpeedY
  CLC                 ; CLear Carry
  ADC #$08            ; Add 8 to BallY
  STA BallBottom      ; Store bottom ball boundary.

  LDA BallY
  CMP #BOTTOMWALL
  BCC CheckP1Up               ; If BallY > BOTTOMWALL, skip ahead.

  LDX #FT_SFX_CH0     ; Set effect channel 0
  LDA #$01            ; Set sound effect #1 (Ping!)
  JSR FamiToneSfxPlay ; Play sound effect.

  LDA #$00
  STA BallDown        ; Clear down-moving flag.
  LDA #$01
  STA BallUp          ; Set up-moving flag, bounce ball up.

  ; Time to check for player input.
CheckP1Up:
  ; Player 1 D-Pad Up
  LDA #$00
  STA P1PaddleUp
  LDA ButtonsP1
  AND #DPAD_UP
  BEQ CheckP1Down     ; If P1 Up bit = 1, it's not pressed. Skip ahead.
  
  ; Check if the paddle is hitting the top wall.
  LDA Paddle1YTop
  CMP #PADDLETOP
  BCC CheckP1Down               ; If it's touching the top, skip ahead.
  
  ; Move the paddle up.
  LDA #$01
  STA P1PaddleUp
  SEC                 ; We're subtracting, so set the carry bit.
  LDA Paddle1YTop
  SBC #$02            ; Subtract 2 from the paddle Y position.
  STA Paddle1YTop     ; Store the new value in RAM.
  CLC                 ; Clear the carry bit for addition.
  LDA Paddle1YTop 
  ADC #PADDLELENGTH   ; Add the length of the paddle.
  STA Paddle1YBot     ; Store paddle bottom position in RAM.

CheckP1Down:
  ; Player 1 D-Pad Down
  ; Same as up, only moving/checking down.
  LDA #$00
  STA P1PaddleDown
  LDA ButtonsP1
  AND #DPAD_DOWN
  BEQ +
  
  LDA Paddle1YBot
  CMP #PADDLEBOTTOM
  BCS +

  LDA #$01
  STA P1PaddleDown
  CLC
  LDA Paddle1YTop
  ADC #$02
  STA Paddle1YTop
  CLC
  ADC #PADDLELENGTH
  STA Paddle1YBot
  
CheckP1Select:
* LDA ButtonsP1
  AND #BUTTON_SELECT
  BEQ +
  
  ; LDA #$05
  ; STA PauseFrameCounter
  ; JSR WaitVBlank
  LDX #<PauseText
  LDY #>PauseText
  LDA #NT2
  JSR RenderTextScreen
  JSR ResetScroll
  LDA #STATEPAUSED
  STA GameState

AICheck:
* LDA numPlayers
  CMP #$01
  BNE CheckP2Up
  
P2PaddleAI:

  LDA numPlayers    ; Check the number of players.
  BEQ CheckP2Up     ; More than one? Skip this function then.

  LDA BallRight     ; Is it moving right?
  ;BEQ CheckPaddle1  ; No? Fuck it, skip.
  BNE NotBallRight
  JMP CheckPaddle1
NotBallRight:
  LDA #$00          ; Reset the paddle directions.
  STA P2PaddleUp    ; This allows the CheckPaddle function 
  STA P2PaddleDown  ; to handle it just like a human player.
  
  LDA BallY         ; Check the ball Y position
  CMP Paddle2YTop   ; Is it above top of the paddle?
  BCS +             ; If so, skip to the next part.
  LDA Paddle2YTop   ; Check the paddle top position.
  CMP #PADDLETOP    ; Is it equal or higher than the top wall?
  BCC +             ; Skip to check the lower bounds.
  LDA #$01          
  STA P2PaddleUp    ; Set the P2 Paddle flag moving up.
  SEC               ; Set the carry bit (Prepare for subtraction)
  LDA Paddle2YTop   ; Pull the second paddle top position again.
  SBC #$04          ; Subtract 2 (Move the paddle up)
  STA Paddle2YTop   ; Store the new position in RAM.
  CLC               ; Clear the carry bit (Prepare for addition)
  ADC #PADDLELENGTH ; Add with carry using Paddle Length Constant.
  STA Paddle2YBot   ; Store at the bottom, completing the hitbox.
  
* LDA BallY         ; Check the ball Y position again.
  CMP Paddle2YTop   ; Check against the paddle top again.
  BCC CheckPaddle1  ; Skip if it's not below the paddle.
  LDA Paddle2YBot   ; Pull the paddle bottom position.
  CMP #PADDLEBOTTOM ; Check against the bottom boundary.
  BCS CheckPaddle1  ; If it's touching the wall, don't move.
  LDA #$01          
  STA P2PaddleDown  ; Set the downward-moving flag.
  CLC               ; Clear the carry bit.
  LDA Paddle2YTop   ; Pull the Paddle Y Position from RAM.
  ADC #$04          ; Add 2 (Make the paddle go down)
  STA Paddle2YTop   ; Store the new position in RAM.
  CLC
  ADC #PADDLELENGTH ; Same hitbox calculation as before.
  STA Paddle2YBot
  JMP CheckPaddle1  ; Skip over the P2 Input Checks.
  
CheckP2Up:
  ; Player 2 D-Pad Up
  ; Identical to the Player 1 function, only with Player 2.
  LDA #$00
  STA P2PaddleUp
  LDA ButtonsP2
  AND #DPAD_UP
  BEQ CheckP2Down
  
  LDA #$01
  STA P2PaddleUp
  LDA Paddle2YTop
  CMP #PADDLETOP
  BCC CheckP2Down

  SEC
  LDA Paddle2YTop
  SBC #$02
  STA Paddle2YTop
  CLC
  ADC #PADDLELENGTH
  STA Paddle2YBot
  
CheckP2Down:
  ; Player 2 D-Pad Down
  ; Same as above, with Player 2.
  LDA #$00
  STA P2PaddleDown
  LDA ButtonsP2
  AND #DPAD_DOWN
  BEQ CheckPaddle1

  LDA Paddle2YBot
  CMP #PADDLEBOTTOM
  BCS CheckPaddle1

  LDA #$01
  STA P2PaddleDown
  CLC
  LDA Paddle2YTop
  ADC #$02
  STA Paddle2YTop
  CLC
  ADC #PADDLELENGTH
  STA Paddle2YBot

  ; We're done with input, now check for paddle collisions.
  ; If (BallX < PADDLE1X)
CheckPaddle1:
* LDA BallX
  CMP #PADDLE1X
  BCS CheckPaddle2           ; No collision, skip.
  ; If (BallBottom > Paddle1YTop)
  LDA BallBottom
  CMP Paddle1YTop
  BCC CheckPaddle2           ; No collision, skip.
  ; If (BallY < Paddle1YBot)
  LDA BallY
  CMP Paddle1YBot
  BCS CheckPaddle2           ; No collision, skip.
  ; If nothing was skipped, we have a collision! 

  LDX #FT_SFX_CH0      ; Set effect channel 0
  LDA #$00            ; Set sound effect #0 (Pong!)
  JSR FamiToneSfxPlay ; Play sound effect.
  
  ; Put some english on the ball if the paddle is moving.
  LDA P1PaddleUp
  BEQ +
  LDA BallUp
  BEQ +
  LDA BallSpeedY    ; Ball moving up, check speed.
  CMP #$05          ; Max speed?
  BEQ +             ; Yes? Skip ahead.
  INC BallSpeedY    ; No? Make it move up faster.


* LDA P1PaddleDown
  BEQ +
  LDA BallDown
  BEQ +
  LDA BallSpeedY    ; Ball moving down, check speed.
  CMP #$05          ; Max speed?
  BEQ +             ; Yes? Skip ahead.
  INC BallSpeedY    ; No? Make it move down faster.

* LDA P1PaddleUp
  BEQ +
  LDA BallDown
  BEQ +
  LDA BallSpeedY    ; Ball moving up, check speed.
  CMP #$01          ; Minimum speed?
  BEQ +             ; Yes? Skip ahead.
  DEC BallSpeedY    ; No? Make it move down slower.

  LDA P1PaddleDown
  BEQ +
  LDA BallUp
  BEQ +
  LDA BallSpeedY    ; Ball moving down, check speed.
  CMP #$01          ; Minimum speed?
  BEQ +             ; Yes? Skip ahead.
  DEC BallSpeedY    ; No? Make it move up slower.

  ;Bounce it!
* LDA #$00
  STA BallLeft
  LDA #$01
  STA BallRight

  ; Repeat for second paddle
  ; Check if BallX is greater than PADDLE2X
CheckPaddle2:
  LDA BallX
  CMP #PADDLE2X
  BCC PlayEngineDone
  
  ; Check Paddle 2 top boundary against ball bottom.
  LDA BallBottom
  CMP Paddle2YTop
  BCC PlayEngineDone
  
  ; Check Paddle 2 bottom boundary against ball top.
  LDA BallY
  CMP Paddle2YBot
  BCS PlayEngineDone
  
  ; Collision! 
  LDX #FT_SFX_CH0      ; Set effect channel 0
  LDA #$00            ; Set sound effect #0 (Pong!)
  JSR FamiToneSfxPlay ; Play sound effect.

  ; Put some english on the ball if the paddle is moving.
  LDA P2PaddleUp
  BEQ +
  LDA BallUp        ; Is the ball moving up?
  BEQ +             ; No? Skip to the next check.
  LDA BallSpeedY    ; Ball moving up, check speed.
  CMP #$05          ; Max speed?
  BEQ +             ; Yes? Skip ahead.
  INC BallSpeedY    ; No? Make it move up faster.

* LDA P2PaddleDown
  BEQ +
  LDA BallDown      ; Is the ball moving down?
  BEQ +             ; No? Skip ahead.
  LDA BallSpeedY    ; Ball moving down, check speed.
  CMP #$05          ; Max speed?
  BEQ +             ; Yes? Skip ahead.
  INC BallSpeedY    ; No? Make it move down faster.

* LDA P2PaddleUp
  BEQ +
  LDA BallDown      ; Is the ball moving down?             
  BEQ +             ; No? Skip to the next check.
  LDA BallSpeedY    ; Ball moving up, check speed.
  CMP #$01          ; Minimum speed?
  BEQ +             ; Yes? Skip ahead.
  DEC BallSpeedY    ; No? Make it move down slower.

* LDA P2PaddleDown
  BEQ +
  LDA BallUp        ; Is the ball moving up?
  BEQ +             ; No? Skip ahead.
  LDA BallSpeedY    ; Ball moving down, check speed.
  CMP #$01          ; Minimum speed?
  BEQ +             ; Yes? Skip ahead.
  DEC BallSpeedY    ; No? Make it move up slower.
  
  ; Bounce the ball.
* LDA #$00
  STA BallRight
  LDA #$01
  STA BallLeft
  JMP PlayEngineDone

PlayEngineDone:
  RTS   ; ReTurn from Subroutine