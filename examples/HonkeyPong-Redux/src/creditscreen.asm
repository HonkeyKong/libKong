.alias CREDITS_MAIN   0
.alias CREDITS_THANKS 1

EngineCredits:
  LDA CreditsShowing
  CMP #$01
  BEQ ReadCreditsInput
  
  LDA #$01
  STA CreditsShowing
  LDA #$00
  STA TitleCardShowing 
  STA FieldRendered
  STA GameOverShowing
  STA TitleShowing
  JSR DisableGFX
  JSR ClearSprites
  JSR FamitoneMusicStop
  
  `LoadBGPalette CreditsPal

  LDX #<CreditsBG
  LDY #>CreditsBG
  LDA #NT2
  JSR RenderNameTable
  
  LDX #<CreditScreen1
  LDY #>CreditScreen1
  LDA #NT2
  JSR RenderTextScreen
  
  `setPPU AttributeTable2
  LDX #$00
* LDA Credits1ATR, X
  STA VRAMIO
  INX
  CPX #$40
  BNE -
  
  `ConfigurePPU NMIonVBlank|BGAddr0|Sprite8x8|SprAddr0|PPUInc1|NameTable20
  JSR ClearSprites
  JSR EnableGFX
  
  LDA #$05
  JSR FamiToneMusicPlay
  
ReadCreditsInput:

  Credits_B:
  LDA ButtonsP1
  AND #BUTTON_B
  BEQ Credits_A
  
  CMP BufferP1
  BEQ Credits_A
  
  LDA #$00
  STA CreditsShowing
  LDA #STATETITLE
  STA GameState
  
JumpHereDipshit:
  JMP ReadCreditsInputEnd
  
Credits_A:
  LDA ButtonsP1
  AND #BUTTON_A
  BEQ JumpHereDipshit
  
  CMP BufferP1
  BEQ JumpHereDipshit
  
SwitchToThanks:
  LDA CreditsScreen
  CMP #CREDITS_MAIN
  BNE SwitchToMain
  
  LDA #CREDITS_THANKS
  STA CreditsScreen
  
  JSR WaitVBlank
  
  JSR DisableGFX
  JSR ClearNameTables
  
  LDX #<CreditsBG
  LDY #>CreditsBG
  JSR RenderNameTable
  
  LDX #<CreditScreen2
  LDY #>CreditScreen2
  LDA #NT2
  JSR RenderTextScreen
  
  `setPPU AttributeTable2
  LDX #$00
* LDA Credits2ATR, X
  STA VRAMIO
  INX
  CPX #$40
  BNE -
  
  `ConfigurePPU NMIonVBlank|BGAddr0|Sprite8x8|SprAddr0|PPUInc1|NameTable20
  JSR ClearSprites
  JSR EnableGFX
  JMP ReadCreditsInputEnd

SwitchToMain:
  LDA CreditsScreen
  CMP #CREDITS_THANKS
  BNE ReadCreditsInputEnd
  
  LDA #CREDITS_MAIN
  STA CreditsScreen

  JSR WaitVBlank

  JSR DisableGFX
  JSR ClearNameTables

  LDX #<CreditsBG
  LDY #>CreditsBG
  JSR RenderNameTable

  LDX #<CreditScreen1
  LDY #>CreditScreen1
  LDA #NT2
  JSR RenderTextScreen  
  
  `setPPU AttributeTable2
  LDX #$00
* LDA Credits1ATR, X
  STA VRAMIO
  INX
  CPX #$40
  BNE -
  
  `ConfigurePPU NMIonVBlank|BGAddr0|Sprite8x8|SprAddr0|PPUInc1|NameTable20
  JSR ClearSprites
  JSR EnableGFX
ReadCreditsInputEnd:
  RTS