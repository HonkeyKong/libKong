EngineTitleCard:
  LDA TitleCardShowing    ; Check the render state of the title card.
  CMP #$01                ; Is it already rendered?
  BEQ +                   ; If so, skip ahead to the music bit.

  ; This is the old shit. The new shit is below.
  ; Load the title card palette.
  ;`LoadBGPalette honkeyPal

  ; Load the background.
  ;JSR RenderTitleCard         ; Render "Honkey Kong" title card
  ;JSR WriteHKAttributes       ; Write Attribute Table

  `LoadBGPalette RetroCardPal
  LDX #<RetroCard
  LDY #>RetroCard
  LDA #NT2
  JSR RenderNameTable
  
  ; Set the nametable same as before, but enable NMI.
  `ConfigurePPU NMIOnVBlank|BGAddr1|PPUInc1|NameTable20
  JSR EnableGFX               ; Enable graphics
  LDA #$01
  STA TitleCardShowing        ; Tell the game the title card is drawn.

* LDA MusicPlaying            ; Check the state of the music player
  CMP #$01                    ; Is it playing?-
  BEQ +                       ; If so, skip over the next segment.

  ; Set up the sound engine
  LDX #<ReduxSoundtrack_music_data   ; Load low byte of music address into X
  LDY #>ReduxSoundtrack_music_data   ; Load high byte of music address into Y
  LDA #$01                      ; Load NTSC_MODE constant into accumulator
  STA MusicPlaying              ; Set the Music Playing flag.
  STA GamePaused                ; Pause main game logic.
  JSR FamiToneInit              ; Initialize the music engine.
  LDX #<sounds                  ; Load low byte of sound address into X
  LDY #>sounds                  ; Load high byte of sound address into Y
  JSR FamiToneSfxInit           ; Initialize the sound engine.
  LDA #$04                      ; Set pause duration for 4 seconds.
  STA PauseDuration             ; (Length of the opening jingle.)
  LDA #$00                      ; Clear the Accumulator.
  STA PauseTimer                ; Set the pause timer to zero.
  JSR FamiToneMusicPlay         ; Hit the music! (Play song #0)

  ; If the title card is rendered and sound is initialized,
  ; This is where our per-frame logic starts.
* LDA GamePaused
  CMP #$00
  BNE +
  LDA #$00
  STA MusicPlaying              ; Clear the Music Playing flag.
  STA TitleCardShowing          ; Clear the Title Card flag.
  STA CreditsShowing            ; Clear the Credits flag.
  JSR FamiToneMusicStop         ; Stop the music.

  LDX #$00
  STX PaletteIndex

  ;`setPlayfieldAttr StandardBG, StandardAttr
  `LoadSpritePalette OldSchoolSpritePal   ; Load the default sprite palette.
  
  LDA #STATETITLE               ; Load the Title Screen state value.
  STA GameState                 ; Transfer to Game State.

* RTS