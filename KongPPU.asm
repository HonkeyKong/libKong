; Set up aliases for PPU registers.

	.alias	PPUControl1			$2000		; PPU Control Register 1
		.alias	NMIonVBlank		%10000000	; Execute Non-Maskable Interrupt on VBlank
		.alias	PPUMaster		%00000000	; Select Master PPU (Unused on NES and Famicom)
		.alias	PPUSlave		%01000000 	; Select Slave PPU (Unused on NES and Famicom)
		.alias	Sprite8x8		%00000000 	; Use 8x8 Sprites
		.alias	Sprite8x16		%00100000 	; Use 8x16 Sprites
		.alias	BGAddr0			%00000000 	; Background Pattern Table at $0000 in VRAM
		.alias	BGAddr1			%00010000 	; Background Pattern Table at $1000 in VRAM
		.alias	SprAddr0		%00000000 	; Sprite Pattern Table at $0000 in VRAM
		.alias	SprAddr1		%00001000 	; Sprite Pattern Table at $1000 in VRAM
		.alias	PPUInc1			%00000000 	; Increment PPU Address by 1 (Horizontal rendering)
		.alias	PPUInc32		%00000100 	; Increment PPU Address by 32 (Vertical rendering)
		.alias	NameTable20		%00000000 	; Name Table Address at $2000
		.alias	NameTable24		%00000001 	; Name Table Address at $2400
		.alias	NameTable28		%00000010 	; Name Table Address at $2800
		.alias	NameTable2C		%00000011 	; Name Table Address at $2C00
	
	.alias	PPUControl2			$2001		; PPU Control Register 2
		.alias	BGBlack			%00000000	; Black Background
		.alias	BGRed			%00100000	; Red Background
		.alias	BGBlue			%01000000	; Blue Background
		.alias	BGGreen			%10000000	; Green Background
		.alias	SprVisible		%00010000 	; Sprites Visible
		.alias	BGVisible		%00001000 	; Backgrounds Visible
		.alias	SprClipping		%00000100 	; Sprites clipped on left column
		.alias	BGClipping		%00000010 	; Background clipped on left column
		.alias	DispColor		%00000000 	; Display in Color
		.alias	DispMono		%00000001 	; Display in Monochrome

	.alias	PPUStatus	$2002	; PPU Status Register
		.alias	VBlankOn		%10000000 	; VBlank Active
		.alias	VBlankSprite0	%01000000 	; VBlank hit Sprite 0
		.alias	SprScan8		%00100000 	; More than 8 sprites on current scanline
		.alias	VRAMIgnore		%00010000 	; VRAM Writes currently ignored.

	.alias	SpriteAddr 	$2003	; Sprite RAM Address Register
	; Contains 8-bit address in Sprite RAM to access via I/O Register

	.alias	SpriteIO	$2004	; Sprite RAM I/O Register
	; Used for reading/writing to Sprite RAM

	.alias	BGScroll	$2005	; Background Scrolling Register
	; First byte written scrolls Horizontal, second byte Vertical.

	.alias	VRAMAddr	$2006	; VRAM Address Register
	; Contains 16-bit address in VRAM to access via I/O Register

	.alias	VRAMIO 		$2007	; VRAM I/O Register
	; Used for reading/writing to VRAM

	; Palette RAM Aliases.
	.alias BGPalette 		$3F00	; Background Palette
	.alias SpritePalette 	$3F10 	; Sprite Palette

	; Sub-Palette Aliases.
	.alias BGPal0 			$3F00	; Background Palette 0
	.alias BGPal1 			$3F04	; Background Palette 1
	.alias BGPal2 			$3F08	; Background Palette 2
	.alias BGPal3 			$3F0C	; Background Palette 3

	.alias SprPal0 			$3F10	; Background Palette 0
	.alias SprPal1 			$3F14	; Background Palette 1
	.alias SprPal2 			$3F18	; Background Palette 2
	.alias SprPal3 			$3F1C	; Background Palette 3

	.alias 	SpriteDMA	$4014	; Sprite DMA Register
	; Used to directly send data to Sprite RAM

	; Aliases for OAM Access
	.alias SpriteYPos	$00
	.alias SpriteIndex 	$01
	.alias SpriteAttr	$02
	.alias SpriteXPos	$03

	; Attribute masks for OAM
	.alias SpritePal0	%00000000
	.alias SpritePal1	%00000001
	.alias SpritePal2	%00000010
	.alias SpritePal3	%00000011
	.alias SpriteLayer0	%00000000
	.alias SpriteLayer1	%00100000
	.alias SpriteFlipX	%01000000
	.alias SpriteFlipY	%10000000

	.alias AttributeTable0	$23C0
	.alias AttributeTable1	$27C0
	.alias AttributeTable2	$2BC0
	.alias AttributeTable3	$2FC0

	.alias NameTable0 		$2000
	.alias NameTable1 		$2400
	.alias NameTable2 		$2800
	.alias NameTable3 		$2C00

	; These are some hacky shortcuts for the Nametable high bytes.
	; Their use will be explained in KongRender.asm's RenderNameTable function.
	.alias NT0 				$20
	.alias NT1 				$24
	.alias NT2 				$28
	.alias NT3 				$2C

	; Same principle, but with Attribute Tables. Used with ClearAttribute.
	.alias AT0 				$23
	.alias AT1 				$27
	.alias AT2 				$2B
	.alias AT3 				$2F

; Pretty self-explanatory. Just keep bit-checking the PPU
; Status register until the Vblank fires, then return.
WaitVBlank:
*	BIT PPUStatus
	BPL -
	RTS

; Zero out the PPU Control registers, clearing all configuration
; flags, effectively disabling all graphics rendering.
DisableGFX:
	LDA	#$00
	STA PPUControl1
	STA PPUControl2
	RTS

; Not exactly a feature-rich function, but it gets the
; job done for turning on all the graphics.
EnableGFX:
	LDA #$00|SprVisible|BGVisible    ; enable sprites and backgrounds
	STA PPUControl2
	JSR ResetScroll   ; Reset the scroll register
	RTS

ClearNameTables:			; Clear the name tables.
	LDA	#$20
	STA	VRAMAddr
	LDY	#$00
	STY	VRAMAddr
	LDX	#$08
	LDA	#$20
	LDY	#$00
*	STA	VRAMIO
	INY
	BNE	-
	DEX
	BNE	-
	RTS

; Clears out sprite RAM and moves off-screen.
; Write #$FE to all 256 OAM bytes.
; #$FF may possibly wrap the sprites around.
; Y goes down past the drawable area.  
; Tile index will be at the end of the bank.
; (In small games, this slot is usually empty.)
; Palette and rotation bits don't matter.
; (We can't see them right there anyway.)
; X position to the far right.
ClearSprites:
  LDA #$FE 
* STA $200,X
  INX
  CPX #$FF
  BNE	-
  RTS
