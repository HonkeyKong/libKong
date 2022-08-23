; This function sets the palette based on the index set in RAM.
; This allows us to set the proper sprite/BG palettes from the
; options screen, then switch back when loading a different screen
; (title, credits, etc.) and reload the proper palette at the
; start of gameplay. Just store the palette index from the options
; menu in the PaletteIndex variable, and call this function to set.
SetPalette:
  ; Old School
  `loadBGPalette OldSchoolBGPal
  `LoadSpritePalette OldSchoolSpritePal
 RTS

; These two functions are self-explanatory. Just store the 
; low byte of the memory address in X, and the high byte in
; the Y register, and call this function. There are also
; macros to make this easier.

SetFieldBG:
  STX BgPtr
  STY BgPtr+1
  RTS

SetFieldAttr:
  STX AttrPtr
  STY AttrPtr+1
  RTS

; This just sets the initial sprite data and attributes in OAM.
InitSprites:
  ; Paddle 1 Top
  LDX #$00
* LDA Paddle1Top, X
  STA PaddleP1Top, X
  INX
  CPX #$04
  BNE -
  ; Paddle 1 Center
  LDX #$00
* LDA Paddle1Mid, X
  STA PaddleP1Mid, X
  INX
  CPX #$04
  BNE -
  ; Paddle 1 Bottom
  LDX #$00
* LDA Paddle1Bot, X
  STA PaddleP1Bot, X
  INX
  CPX #$04
  BNE -
  ; Paddle 2 Top
  LDX #$00
* LDA Paddle2Top, X
  STA PaddleP2Top, X
  INX
  CPX #$04
  BNE -
  ; Paddle 2 Center
  LDX #$00
* LDA Paddle2Mid, X
  STA PaddleP2Mid, X
  INX
  CPX #$04
  BNE -
  ; Paddle 2 Bottom
  LDX #$00
* LDA Paddle2Bot, X
  STA PaddleP2Bot, X
  INX
  CPX #$04
  BNE -
  ; Ball
  LDX #$00
* LDA BallSprite, X
  STA Ball, X
  INX
  CPX #$04
  BNE -
  RTS


; RenderTitleCard:
;   `setPPU NameTable0      ; Set PPU address to Nametable 0.
;   LDA #$04
;   STA BlankRows
;   JSR WriteBlankRows      ; Render 4 blank rows.
;   LDY #$00                ; Set our row counter to zero.
;   LDA #$14
;   STA TempCounter         ; Set row length (20 tiles).
;   LDX #$00                ; Set our table tracker to zero.
; * LDA #$06
;   STA BlankTiles
;   JSR WriteBlankTiles     ; Draw 6 blank tiles to center image.
; * LDA HonkeyLogoData, X   ; Pull tile offset from image table.
;   STA VRAMIO              ; Write to current PPU/Nametable offset.
;   INX                     ; Increment the tracker.
;   CPX TempCounter         ; Compare to current row end offset.
;   BNE -                   ; Pull/draw another tile if not there.
;   LDA TempCounter         ; Pull row end offset from RAM.
;   CLC                     ; Clear the carry bit (Prepare to add).
;   ADC #$14                ; Add another row length.
;   STA TempCounter         ; Store new row end offset in RAM.
;   LDA #$06
;   STA BlankTiles
;   JSR WriteBlankTiles     ; Put blank tiles on right side.
;   INY                     ; Increment row counter.
;   CPY #$05                ; Are all 5 rows rendered yet?
;   BNE --                  ; If not, start the next row.
;   ; Rendered "HONKEY", now start on "KONG".
;   ; The next blocks are basically the same as the first.
;   ; The only real differences are the size of the images.
;   LDX #$00                ; Reset table tracker.
;   LDY #$00                ; Reset row tracker.
;   LDA #$0E                ; These rows are shorter (14 tiles).
;   STA TempCounter         ; Store row length in TempCounter
; * LDA #$09
;   STA BlankTiles
;   JSR WriteBlankTiles     ; Shorter rows mean more filler.
; * LDA KongLogoData, X     ; Pull a tile.
;   STA VRAMIO              ; Place a tile. (Just like the penny tray!)
;   INX                     ; Next tile, please!
;   CPX TempCounter         ; Is this row finished?
;   BNE -                   ; No? Place the next tile.
;   LDA TempCounter         ; Yes? Bump up the counter.
;   CLC                     ; Clear the carry again.
;   ADC #$0E                ; Add another row's worth.
;   STA TempCounter         ; Store the new value.
;   LDA #$09
;   STA BlankTiles
;   JSR WriteBlankTiles     ; Fill the rest of the row.
;   INY                     ; Increment the row counter.
;   CPY #$05                ; Are all five rows filled?
;   BNE --                  ; No? Do another one.
;   ; Rendered "KONG", next render my super-awesome avatar sprite
;   LDA #$02
;   STA BlankRows
;   JSR WriteBlankRows      ; Drop a couple more blank rows.
;   LDX #$00                ; New table, clear the tracker.
;   LDY #$00                ; Wipe out the row tracker too.
;   LDA #$04                ; I'm only 4 tiles wide!
;   STA TempCounter         ; (I wish I was really that thin.)
; * LDA #$0E
;   STA BlankTiles
;   JSR WriteBlankTiles     ; (HOLY CRAP, FOURTEEN BLANKS!)
; * LDA HonkeySprite, X     ; Pull my tiles. (Be gentle!)
;   STA VRAMIO              ; Put me in place. (It's my first time!)
;   INX                     ; NEXT!
;   CPX TempCounter         ; Are we done yet?
;   BNE -                   ; No? Shit! Do it again!
;   LDA TempCounter         ; Pull the counter again.
;   CLC                     ; Clear the carry bit. (Sound familiar?)
;   ADC #$04                ; Add another row of tiles.
;   STA TempCounter         ; Put it back! You don't know where it's been!
;   LDA #$0E
;   STA BlankTiles
;   JSR WriteBlankTiles     ; 14 more blanks. That's a lot of empty space.
;   INY                     ; Yep, we're done with this row now.
;   CPY #$06                ; Are all six rows finished?
;   BNE --                  ; Guess not. Back to the grind...
;   ; I look fantastic. Let's do more shameless self-promotion.
;   ; If you don't understand this by now, I can't help you.
;   LDA #$02
;   STA BlankRows
;   JSR WriteBlankRows
;   LDX #$00
;   LDY #$00
;   LDA #$14
;   STA TempCounter
; * LDA #$06
;   STA BlankTiles
;   JSR WriteBlankTiles
; * LDA HonkeyKongURLData, X
;   STA VRAMIO
;   INX
;   CPX TempCounter
;   BNE -
;   LDA #$06
;   STA BlankTiles
;   JSR WriteBlankTiles
;   LDA TempCounter
;   CLC
;   ADC #$14
;   STA TempCounter
;   INY
;   CPY #$02
;   BNE --
;   LDA #$04      ; Whoops, I was forgetting to write one line. Fixed.
;   STA BlankRows
;   JSR WriteBlankRows
;   RTS

; WriteHKAttributes:
;   `setPPU AttributeTable2
;   LDA #$00
;   LDX #$00
; * STA VRAMIO
;   INX 
;   CPX #$20
;   BNE -
;   LDA #$55
;   LDX #$00
; * STA VRAMIO
;   INX
;   CPX #$10
;   BNE -
;   LDA #$00
;   LDX #$00
; * STA VRAMIO
;   INX
;   CPX #$10
;   BNE -
;   RTS

Clear4PlayersTitle:
  ; Clear "3 Players" Line
  `setPPU NameTable2+$2AC
  LDX #$09
  LDA #$00
* STA VRAMIO
  DEX
  CPX #$00
  BNE -
  ; Clear "4 Players" Line
  `setPPU NameTable2+$2CC
  LDX #$09
  LDA #$00
* STA VRAMIO
  DEX
  CPX #$00
  BNE -
  RTS

; This macro and the function below it might get a bit messy,
; like my title card renderer, but in the end, it should also
; be much smaller than storing the entire nametable.

.macro WriteTileLoop
  LDX #$00
  LDA #_1
_wtlByte:
  STA VRAMIO
  INX
  CPX #_2
  BNE _wtlByte
.macend

RenderCompressedField:
  LDA #$00
  LDX #$00
  LDY #$00
  `setPPU NameTable0      ; Start on the first nametable.
  LDA #$04                ; How many blank rows do we write?
  JSR WriteBlankRows      ; Use our subroutine for that.
  LDA #$00                ; Manually load a blank space.
  STA VRAMIO              ; Write it to the PPU.
  LDA #$B9                ; Load the top-left corner tile.
  STA VRAMIO              ; Write to the PPU.
  `WriteTileLoop $BA, $1C  ; Use my spiffy macro to repeat the top tile.
  LDA $BB                 ; Load the top-right corner tile.
  STA VRAMIO              ; Write to the PPU. (Get it yet?)
  LDA $00                 ; Load a blank to end the row.
  STA VRAMIO              ; What does this do? WRITE THE PPU!
  ; Now it's time to get a little trickier. Loops inside of loops? LOOPCEPTION!
  LDX #$00
  LDY #$00
* LDA #$00
  STA VRAMIO
  LDA #$BE
  STA VRAMIO
  `WriteTileLoop $80, $1C
  LDA #$BE
  STA VRAMIO
  LDA #$00
  STA VRAMIO
  INY
  CPY #22
  BNE -
  LDX #$00
  LDY #$00
  LDA #$00
  STA VRAMIO
  LDA #$BC
  STA VRAMIO
  `WriteTileLoop $BA, $1C
  LDA #$BD
  STA VRAMIO
  LDA $00
  STA VRAMIO
  LDA #$02
  JSR WriteBlankRows
  ;That'll do it for the playfield, now let's backtrack and write the score.
  ; We'll jump forward to the mirrored area rather than roll the counter back.
  `setPPU $2842 ; HACKETY-HACK! (Don't talk back!)
  LDX #$00
* LDA scoreRow, X
  STA VRAMIO
  INX
  CPX #$20
  BNE -
  ; There's the score info, now we need the attribute table.
  `setPPU AttributeTable2
  LDX #$00
* LDA ReduxATR, X
  STA VRAMIO
  INX
  CPX #$40
  BNE -
  RTS


 