EngineTitle:
  LDA TitleShowing	 	; Check if the title screen is already showing.
  CMP #$01
  BEQ ReadTitleInput				; If yes, skip the rendering and setup code.

  LDA #$01
  STA TitleShowing
  LDA #$00
  STA TitleCardShowing
  STA FieldRendered
  STA GameOverShowing
  STA CreditsShowing
  STA CreditsScreen
  ;STA OptionsShowing
  JSR DisableGFX

  `LoadBGPalette titleBGPal                 ; Load the default game palette.

  LDX #<TitleScreen
  LDY #>Titlescreen
  LDA #NT2
  JSR RenderNameTable
  
  ; Check for 4-player adapter.
  JSR Check4Players
  LDA HasFourScore
  CMP #$01
  BEQ +

  JSR Clear4PlayersTitle  ; If only 2 players, remove 3P and 4P lines.
  JSR ResetScroll         ; Reset the scroll after writing to nametable.

* `ConfigurePPU NMIonVBlank|BGAddr0|Sprite8x8|SprAddr0|PPUInc1|NameTable20
  JSR ClearSprites
  JSR EnableGFX

  ; Set some initial game stats
  JSR ResetPlayfield
  
  LDA #$00
  STA BallLeft    ; Clear the left-moving flag.
  STA BallFrame   ; Set frame lookup to zero.
  STA GamePaused  ; Ensure game is unpaused.

  ; Clear out the scores.
  STA ScoreP1
  STA ScoreP2

  ; Set up the title music.
  LDA #$01                      ; Select Track #2 (LawnMower Title)
  STA BallRight   ; Set the ball moving right.
  JSR FamiToneMusicPlay         ; Hit the music!

ReadTitleInput:
  ; Read controller 1
  LDA ButtonsP1
  AND #BUTTON_START     ; Is start pressed?
  BEQ +++             ; If not, skip to the D-Pad.
  
  ; NOTE: NES button states are active-low, so if
  ; the particular button bit is set to 0, it means
  ; it's pressed. This is why we BEQ instead of BNE.

  CMP BufferP1          ; Compare button state to previous state
  BEQ +++             ; Skip if button held.

  LDA TitleCursorIndex
  CMP #$00
  BNE +
  LDA #$01
  STA numPlayers
  LDA #STATEPLAYING     ; 1P Game selected, set "PLAYING" state.
  STA GameState

* LDA TitleCursorIndex
  CMP #$01
  BNE +
  LDA #$02
  STA numPlayers
  LDA #STATEPLAYING     ; 2P Game selected, set "PLAYING" state.
  STA GameState

* LDA TitleCursorIndex
  CMP #$04
  BNE +
  LDA #STATECREDITS
  STA GameState

* LDA ButtonsP1
  AND #DPAD_DOWN
  BEQ +++
  CMP BufferP1
  BEQ +++

  LDY TitleCursorIndex    ; Pull current cursor index
  INY                     ; Add one
  STY TitleCursorIndex    ; Store new cursor index
  CPY #$05
  BNE +
  LDY #$00
  STY TitleCursorIndex
* CPY #$02                ; Is it out of bounds?
  BCC +                   ; If not, skip ahead.
  JMP SkipToOptions
* CPY #$04
  BCC +
  LDY #$00
  STY TitleCursorIndex

SkipToOptions:
  LDY #$04
  STY TitleCursorIndex

* LDA ButtonsP1
  AND #DPAD_UP
  BEQ ++
  CMP BufferP1
  BEQ ++

  LDY TitleCursorIndex  ; Pull current cursor index
  DEY                   ; Subtract one
  STY TitleCursorIndex  ; Store new cursor index
  CPY #$FF              ; Is it out of bounds?
  BNE +                 ; If not, we're done.

  LDY #$04              ; If yes, reset to index 2
  STY TitleCursorIndex  ; (wrap to bottom) and store

* LDA TitleCursorIndex
  CMP #$02
  BEQ SkipTo2P
  LDA TitleCursorIndex
  CMP #$03
  BNE +
SkipTo2P:
  LDY #$01
  STY TitleCursorIndex

* RTS
