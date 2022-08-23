  ; HonkeyPong main program bank, 32KB

  ; A bit about segmentation before we start:
  ; We use two segments here, .data and .text
  ; Each segment contains its own Program Counter 
  ; to keep track of where we are in the data.
  ; This means we can build up the data segment
  ; in one location, and build the text segment
  ; in another without worrying about overwriting
  ; data due to conflicting program counters.

  .data

  ; This header contains our main zero-page requirements.
  ; Don't allocate before $20 just to be safe.
  ; 32 bytes on the zero page should be enough for libKong.
  .include "../../../ZeroPage/MainZP.asm"

  ; Starting here leaves a 32-byte boundary between
  ; the libKong allocation and our ZP requisites.
  .org $40 

;  .space  BGPtrLow            1   ; Low byte of BG Pointer for restoration.
;  .space  BgPtr               2   ; Pointer to Background address.
;  .space  AttrPtr             2   ; Pointer to Attribute address.
  .space  ModeStrPtr          2   ; Pointer to Mode String.
  .space  FontStrPtr          2   ; Pointer to Font String.
  .space  TileStrPtr          2   ; Pointer to Tile String.
  .space  BGMStrPtr           2   ; Pointer to BGM String.

  .checkpc $FC

  ; 3-byte scratchpad for Famitone,
  ; stored at end of zero page.
  .org $00FC
  .space  FT_TEMP           3

  ; Designated sprite RAM.
  ; Sprite attributes are ordered as such:
  ; Y Position, Tile Index, Attributes, X Position

  .org $0200

  ; The ball sprite is split into 4 variables so
  ; we can alter things like palette and rotation.
  ; Technically this could also be done by addressing
  ; Ball+2 for the attribute byte, and Ball+3 for X.
  ; However, the code comes out cleaner and does the
  ; same thing arranged this way, so I'm doing it for
  ; the sake of readability and maintainability.
  .space  Ball              1
  .space  BallIndex         1
  .space  BallAttr          1
  .space  BallXPos          1

  ; Game Sprites, 4 bytes per sprite.
  ; Paddle Tile Index, Rotation, Palette and
  ; X Position are fixed, so 1 var each is OK.
  .space  PaddleP1Top       4
  .space  PaddleP1Mid       4
  .space  PaddleP1Bot       4
  .space  PaddleP2Top       4
  .space  PaddleP2Mid       4
  .space  PaddleP2Bot       4

  ; Smoke Puff sprites
  ; When the ball reaches top speed,
  ; this smoke trail will be drawn.

  .space  Puff1             4
  .space  Puff2             4
  .space  Puff3             4

  ; Cursor Sprites, 4 bytes per sprite.
  ; X Position, Index and Attributes are fixed.

  .space  TitleCursor       4
  
  ; One page of RAM reserved for Famitone sound library.
  .org $0300
  .space  FT_BASE_ADR       256

  .org $400

  .space  ScoreP1             1   ; Player 1 Score
  .space  ScoreP2             1   ; Player 2 Score
  .space  BallX               1   ; Ball X Position Copy
  .space  BallY               1   ; Ball Y Position Copy
  .space  BallBottom          1   ; Bottom boundary of ball.
  .space  Paddle1YTop         1   ; Y position of Player 1 paddle top.
  .space  Paddle1YBot         1   ; Bottom boundary of Player 1 paddle.
  .space  Paddle2YTop         1   ; Y position of Player 2 paddle top.
  .space  Paddle2YBot         1   ; Bottom boundary of Player 2 paddle.
  .space  BallSpeedX          1   ; Number of pixels to increment X position.
  .space  BallSpeedY          1   ; Number of pixels to increment Y position.
  .space  GameState           1   ; Current game state.
  .space  BallFrame           1   ; Frame counter for ball animation.
  .space  TempCounter         1   ; Tile counter for nametable rendering.
  .space  FrameCounter        1   ; Frame counter used for timing pauses.
  .space  PauseTimer          1   ; Counter used for timing seconds paused.
  .space  PauseDuration       1   ; How long should the game logic be paused?
  .space  BallUp              1   ; Flag set when ball is moving up.
  .space  BallDown            1   ; Flag set when ball is moving down.
  .space  BallLeft            1   ; Flag set when ball is moving left.
  .space  BallRight           1   ; Flag set when ball is moving right.
  .space  TitleShowing        1   ; Flag raised when title screen is rendered.
  .space  TitleCardShowing    1   ; Flag raised when title card is rendered.
  .space  InitialOptions      1   ; Flag set on load, cleared on options init.
  .space  FieldRendered       1   ; Flag raised when playfield is rendered.
  .space  ScoreP1Updated      1   ; Flag raised when P1 score is updated.
  .space  ScoreP2Updated      1   ; Flag raised when P2 score is updated.
  .space  MusicPlaying        1   ; Flag raised when music is playing.
  .space  PlayScoreSound      1   ; Flag raised when scoring sound plays.
  .space  GameOverShowing     1   ; Flag raised when game over is shown.
  .space  CreditsShowing      1   ; Flag raised when credits are shown.
  .space  CreditsScreen       1   ; Flag keeping track of credits screen
  .space  GamePaused          1   ; Flag raised when game logic is paused.
  .space  ModeUpdated         1   ; Flag raised when Game Mode is updated.
  .space  TileUpdated         1   ; Flag raised when Tile Set is updated.
  .space  TextUpdated         1   ; Flag raised when Font is updated.
  .space  MusicUpdated        1   ; Flag raised when Music is updated.
  .space  TextOffset          2   ; Offset in nametable where text is written.
  .space  TitleCursorIndex    1   ; Y Index of Title Screen Cursor.
  .space  PaletteIndex        1   ; Index of game Palette.
  .space	numPlayers				  1   ; number of players
  .space  GamePlayPaused      1   ; Is Gameplay paused?
  .space  P1PaddleUp          1   ; Is the P1 Paddle moving up?
  .space  P1PaddleDown        1   ; Is the P1 Paddle moving down?
  .space  P2PaddleUp          1   ; Is the P2 Paddle moving up?
  .space  P2PaddleDown        1   ; Is the P2 Paddle moving down?
  .space  PauseFrameCounter   1   ; Pause Frame Counter, duh.

; -------------------- END OF DATA SEGMENT --------------------

  ; Start of the text segment, this is our program code.
  ; This is laid out different from the MMC3-based Deluxe
  ; version of the game, but that's because we're never 
  ; swapping out PRG banks, everything should fit in 32KB.

  .text

  ; First 8KB data bank, Sound and Music Data.
  ; .ORG $8000
  .org $C000

  ; This source file contains all songs, just shy of 5KB.
  .include "../res/snd/ReduxSoundtrack.oph"

  ; ~3KB free after music data, before $A000.

  ; Second 8KB data bank (Sound and Music Data)
  ; .advance $A000

  ;.include "backgrounds.oph"            ; Background data, 768 bytes.
  
  ; Other essential game data.
  .include "sprites.asm"                ; Sprite tables
  .include "gamedata.asm"               ; Game data (Strings, Constants)
  .include "palettedata.asm"            ; Prebuilt BG/Sprite Palettes
  .include "graphicsdata.asm"           ; Nametable maps
  .include "credits.asm"                ; Credits data
  .include "../res/snd/Sounds.oph"      ; Game Sounds
  
  ; BUT, just to be safe...
  ; Check to make sure we're not spilling out into the next bank.
  ; .checkpc $BFFF
  
  ; Third 8KB data bank
  ; .advance $C000


  .include "../../../Video/KongPPU.asm"   ; libKong PPU code
  .include "../../../KongSetup.asm"       ; libKong NES setup
  .INCLUDE "../../../KongMacros.asm"      ; libKong Macros
  .include "../../../Video/KongText.asm"    ; libKong String Functions
  .include "engine.asm"                   ; Main gameplay stuff

  .include "../../../Video/KongRender.asm"     ; Rendering routines
  .include "render.asm"                 ; Game-specific rendering.
  .include "../../../Input/KongInput.asm"      ; Controller handler
  .include "famitone2.asm"              ; Audio library
  
  ; Sanity check for third bank.
  ; .checkpc $DFFF

  ; .advance $E000

RESET:
  ; Make sure everything gets set up properly.
  JSR ResetNES      ; Basic boilerplate NES setup code
  JSR WaitVBlank    ; VBlank #1
  JSR ClearRAM      ; Clear out RAM
  `clearStack       ; Clean up the stack.
  JSR ClearSprites  ; Move sprites off-screen.
  
  LDA #$01
  STA InitialOptions  ; Set a flag to tell the engine we're initialized.

  JSR WaitVBlank    ; VBlank #2
  
  ; It generally takes 2 VBlank cycles to ensure the PPU is
  ; warmed up and ready to start drawing stuff on the screen.
  ; Now that the necessary time is passed, we can configure
  ; the PPU and get stuff set up to render the title card.
  JSR DisableGFX    ; Disable graphics

  ; Clear the nametables.
  JSR ClearNameTables

  LDA #STATETITLECARD     ; We load the initial title card state here,
  STA GameState           ; before the main loop starts.
  JSR EngineTitleCard     ; Start title card rendering.
  ; This routine will start the Non-Maskable Interrupt when it's
  ; safe to do so. After it completes, it'll jump into the main loop.

MainLoop:
  JMP MainLoop     ; Jump back, infinite loop. All game logic performed on NMI.

; Non Maskable Interrupt, ran once per frame when VBlank triggers.
NMI:

CheckGameOver:
* LDA GameState
  CMP #STATEGAMEOVER
  BNE CheckPlaying
  LDA GameOverShowing
  BNE CheckPlaying

  ; LDA #$03
  ; JSR FamiToneMusicPlay

  `setPPU gameOverField
  LDX #$00
* LDA gameOverLine1, X
  STA VRAMIO
  INX
  CPX #$09
  BNE -

  `setPPU pressStartField
  LDX #$00
* LDA gameOverLine2, X
  STA VRAMIO
  INX
  CPX #$14
  BNE -

  LDA #$00
  STA TitleShowing
  STA GamePlayPaused
  ; STA TempUp
  ; STA TempDown
  ; STA TempLeft
  ; STA TempRight
  
  LDA #$01
  STA GameOverShowing

CheckPlaying:
* LDA GameState
  CMP #STATEPLAYING
  BNE ++
  LDA ScoreP1Updated    ; Check if player 1 scored.
  BNE +                 ; If so, jump ahead to update the point display.
  LDA ScoreP2Updated    ; If not, see if player 2 scored.
  BEQ ++                ; If player 2 didn't score either, branch
* JSR DrawScore
  LDA #$01
  STA PlayScoreSound

  ; The VBlank period has just started, it's safe to update PPU memory.
* LDA #$00
  STA SpriteAddr  ; set low byte (00) of Sprite RAM
  LDA #$02
  STA SpriteDMA   ; set high byte (02) of Sprite RAM, start the transfer.

  ; Reset the scroll register on each frame update where VRAM is written.
  JSR ResetScroll

  ; PPU updates are done, run the game logic.
  
* JSR CheckPauseTimer

  ; Read the controller states.
  JSR ReadController1
  JSR ReadController2

  ; Check the game state, AND jump to the proper subroutine.

* LDA GameState
  CMP #STATETITLECARD
  BNE +
  JSR EngineTitleCard
  
* LDA GameState
  CMP #STATECREDITS
  BNE +
  JSR EngineCredits

* LDA GameState
  CMP #STATETITLE
  BNE +
  JSR EngineTitle

* LDA GameState
  CMP #STATEPLAYING
  BNE +
  JSR EnginePlaying
  
* LDA GameState
  CMP #STATEPAUSED
  BNE +
  JSR EnginePaused

* LDA GameState
  CMP #STATEGAMEOVER
  BNE +
  JSR EngineGameOver

  ; Update sound engine
* JSR FamiToneUpdate

  ; Update Sprite RAM

  JSR UpdateSprites

  RTI   ; ReTurn from Interrupt

  ; Set up the 3 main vectors the NES looks for 
  ; at the end of the ROM on power-up.

  ; Unlike the .org directive, .advance will advance the program 
  ; counter and zero fill the space leading up to it to pad the 
  ; binary up to the designated location. This is necessary in places
  ; like this, where the hardware expects a lookup table with the 
  ; necessary functions to set up the NES and get things running.

  .advance $FFFA    ; First of the three vectors starts here

  .word NMI         ; Non-Maskable Interrupt, runs at VBlank, once per frame.

  .word RESET       ; This function is performed on power-on and reset.

  .word 0           ; external IRQ is not used here
