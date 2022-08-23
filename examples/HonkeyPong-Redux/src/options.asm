EngineOptions:
  LDA OptionsShowing    ; Check if the title screen is already showing.
  CMP #$01
  BEQ OptionsInput          ; If yes, skip the rendering and setup code.

  LDA #$01
  STA OptionsShowing

  LDA InitialOptions
  CMP #$00
  BEQ +
  
  LDA #$00
  STA OptionsCursorIndex
  STA OptionsModeIndex
  STA OptionsTileIndex
  STA OptionsTextIndex
  STA OptionsMusicIndex
* LDA #$00
  STA TitleCardShowing
  STA FieldRendered
  STA GameOverShowing
  STA TitleShowing
  STA TitleCursorIndex
  STA CreditsShowing

  JSR DisableGFX
  JSR ClearSprites

  JSR SetPalette

  LDX #CHR2K0
  LDY FontBank
  JSR SwitchGameBanks

  LDX #CHR2K1
  LDY BGBank
  JSR SwitchGameBanks

  LDX #CHR1K2
  LDY SpriteBank
  JSR SwitchGameBanks

  ; Draw Options Screen
  LDX #<OptionsScreen
  LDY #>OptionsScreen
  JSR RenderNameTable
  
  ; Draw Mode Selection
  JSR RenderOptionsStringMode
  
  ; Draw Tile Set Selection
  JSR RenderOptionsStringTiles
  
  ; Draw Font Selection
  JSR RenderOptionsStringText
  
  ; Draw BGM Selection
  JSR RenderOptionsStringMusic
  
  ; Draw Preview Sprites
  JSR RenderOptionsSprites
  
  ;LDA #$00|NMIonVBlank|BGAddr0|Sprite8x8|SprAddr1|PPUInc1|NameTable20
  ;STA PPUSettings
  ;JSR ConfigurePPU
  `ConfigurePPU NMIonVBlank|BGAddr0|Sprite8x8|SprAddr1|PPUInc1|NameTable20
  JSR EnableGFX

  LDA #$00
  STA InitialOptions
  JSR FamiToneMusicStop     ; Stop the music!

  ; Read controller 1
OptionsInput:
  LDA ButtonsP1
  AND #BUTTON_B     ; Is B pressed?
  BEQ +             ; If not, skip to the end.

  CMP BufferP1
  BEQ +

  LDA #$00
  STA OptionsShowing
  LDA #STATETITLE   ; Start is pressed, set "TITLE" state.
  STA GameState

  ; Options Navigation Code starts here.
  * LDA ButtonsP1
  AND #DPAD_DOWN
  BEQ +
  CMP BufferP1
  BEQ +

  LDY OptionsCursorIndex  ; Pull current cursor index
  INY                     ; Add one
  STY OptionsCursorIndex  ; Store new cursor index
  CPY #$04                ; Is it out of bounds?
  BNE +                   ; If not, skip ahead.

  LDY #$00                ; If yes, reset to zero (wrap around)
  STY OptionsCursorIndex  ; Store new cursor index

* LDA ButtonsP1
  AND #DPAD_UP
  BEQ +
  CMP BufferP1
  BEQ +

  LDY OptionsCursorIndex  ; Pull current cursor index
  DEY                     ; Subtract one
  STY OptionsCursorIndex  ; Store new cursor index
  CPY #$FF                ; Is it out of bounds?
  BNE +                   ; If not, we're done.

  LDY #$03                ; If yes, reset to index 2
  STY OptionsCursorIndex  ; (wrap to bottom) and store

* LDA ButtonsP1
  AND #DPAD_RIGHT
  BEQ ReadOptionsLeft
  CMP BufferP1
  BEQ ReadOptionsLeft

  LDX OptionsCursorIndex
  CPX #$00
  BNE +
  ; Index 0 - Game Mode
  LDY OptionsModeIndex
  INY
  STY OptionsModeIndex
  LDA #$01
  STA ModeUpdated
  CPY #$02
  BNE +
  LDY #$00
  STY OptionsModeIndex

* LDX OptionsCursorIndex
  CPX #$01
  BNE +
  ; Index 1 - Game Sprites
  LDY OptionsTileIndex
  INY
  STY OptionsTileIndex
  LDA #$01
  STA TileUpdated
  CPY #$03
  BNE +
  LDY #$00
  STY OptionsTileIndex

* LDX OptionsCursorIndex
  CPX #$02
  BNE +
  ; Index 2 - Game Text
  LDY OptionsTextIndex
  INY
  STY OptionsTextIndex
  LDA #$01
  STA TextUpdated
  CPY #$08
  BNE +
  LDY #$00
  STY OptionsTextIndex

* LDX OptionsCursorIndex
  CPX #$03
  BNE +
  ; Index 3 - Game Music
  LDY OptionsMusicIndex
  INY
  STY OptionsMusicIndex
  LDA #$01
  STA MusicUpdated
  CPY #$03
  BNE +
  LDY #$00
  STY OptionsMusicIndex


ReadOptionsLeft:
* LDA ButtonsP1
  AND #DPAD_LEFT
  BEQ ++++
  CMP BufferP1
  BEQ ++++

  LDX OptionsCursorIndex
  CPX #$00
  BNE +
  ; Index 0 - Game Mode
  LDY OptionsModeIndex
  DEY
  STY OptionsModeIndex
  LDA #$01
  STA ModeUpdated
  CPY #$FF
  BNE +
  LDY #$01
  STY OptionsModeIndex

* LDX OptionsCursorIndex
  CPX #$01
  BNE +
  ; Index 1 - Game Sprites
  LDY OptionsTileIndex
  DEY
  STY OptionsTileIndex
  LDA #$01
  STA TileUpdated
  CPY #$FF
  BNE +
  LDY #$02
  STY OptionsTileIndex

* LDX OptionsCursorIndex
  CPX #$02
  BNE +
  ; Index 2 - Game Text
  LDY OptionsTextIndex
  DEY
  STY OptionsTextIndex
  LDA #$01
  STA TextUpdated
  CPY #$FF
  BNE +
  LDY #$07
  STY OptionsTextIndex

* LDX OptionsCursorIndex
  CPX #$03
  BNE +
  ; Index 3 - Game Music
  LDY OptionsMusicIndex
  DEY
  STY OptionsMusicIndex
  LDA #$01
  STA MusicUpdated
  CPY #$FF
  BNE +
  LDY #$02
  STY OptionsMusicIndex

* RTS