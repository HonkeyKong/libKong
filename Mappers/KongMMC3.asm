; MMC3 Aliases

; 8KB MMC3 Work RAM, also serves as 
; battery-backed SRAM on TKROM boards.
; Located at $6000-$7FFF
  .alias	MMC3WRAM			$6000

; MMC3 Bank Control Register
  .alias	MMC3BankControl		$8000
    .alias	CHR2K0			$00 	; PPU $0000-$07FF
    .alias	CHR2K1			$01	  ; PPU $0800-$0FFF
    .alias	CHR1K0			$02	  ; PPU $1000-$13FF
    .alias	CHR1K1			$03 	; PPU $1400-$17FF
    .alias	CHR1K2			$04 	; PPU $1800-$1BFF
    .alias	CHR1K3			$05 	; PPU $1C00-$1FFF
    .alias	PRG00			  $06 	; CPU $8000-$9FFF
    .alias	PRG01			  $07 	; CPU $A000-$BFFF
    .alias  InvertCHR   $80   ; Invert CHR ROM
    ; 4x1KB pages at top, 2x2KB pages at bottom.

; MMC3 Bank Select Register
  .alias		MMC3BankSelect	$8001

; Aliases for MMC3 interupts.
  .alias 		MMC3IRQLatch	$C000
  .alias		MMC3IRQReload	$C001

; MMC3 Nametable Mirroring Control Register
  .alias		MMC3Mirror		$A000
    .alias	vert			$00
    .alias	horiz			$01

; MMC3 Work RAM protection control
  .alias 	MMC3WRAMProtect		$A001
  	.alias WRAMEnable			$80
  	.alias WRAMDisable		$00

; Writing anything to these registers will enable
; or acknowledge/disable the MMC3 interrupts.
  .alias	MMC3IRQOff		$E000
  .alias	MMC3IRQOn		$E001

; MMC3 Functions

SwitchBank:
  LDA #BankType
  STA MMC3BankControl
  LDA #BankSlot
  STA MMC3BankSelect
  RTS

; Roll through the init table, smack the mapper
; bank stuff into place. Blame tepples for this 
; quick & dirty setup. It's small and it works.
InitMMC3: 				; "Let's play 6502 golf."
  LDX #$07 				; Start at 8th index.
* STX MMC3BankControl 	; Which bank are we mapping?
  LDA MMC3InitTable, X 	; Pull from the init table.
  STA MMC3BankSelect 	; Select this chunk of ROM.
  DEX 					; Subtract X by one.
  BPL - 				; (Yes, we're counting backwards.)
  STA MMC3Mirror 		; We're at zero now, store it
  				 		; in mirror control to set up
  				 		; vertical mirroring.
  RTS					; TA-DAAAAAH! Everything's ready.

; Lookup table for InitMMC3 subroutine.
MMC3InitTable:
  .byte $00,$02,$04,$05,$06,$07,$00,$01

; Call this to unlock TSROM/TKROM 8KB Work RAM.
UnlockMMC3WRAM:
  LDA #WRAMEnable
  STA MMC3WRAMProtect
  RTS

; Call this to lock TSROM/TKROM 8KB Work RAM.
LockMMC3WRAM:
  LDA #WRAMDisable
  STA MMC3WRAMProtect
  RTS

ClearMMC3WRAM:		; Clear out MMC3 WRAM. Erases battery backup on TKROM.
	JSR UnlockMMC3WRAM
	LDX	#$00
*	LDA	#$00
	STA	$6000,X
	STA	$6100,X
	STA $6200,X
	STA	$6300,X
	STA	$6400,X
	STA	$6500,X
	STA	$6600,X
	STA	$6700,X
	STA	$6800,X
	STA	$6900,X
	STA $6A00,X
	STA	$6B00,X
	STA	$6C00,X
	STA	$6D00,X
	STA	$6E00,X
	STA	$6F00,X
	STA	$7000,X
	STA	$7100,X
	STA $7200,X
	STA	$7300,X
	STA	$7400,X
	STA	$7500,X
	STA	$7600,X
	STA	$7700,X
	STA	$7800,X
	STA	$7900,X
	STA $7A00,X
	STA	$7B00,X
	STA	$7C00,X
	STA	$7D00,X
	STA	$7E00,X
	STA	$7F00,X
	INX
	BNE	-
	JSR LockMMC3WRAM
	RTS

.macro SwitchBank 			; `SwitchBank Location BankNumber
  LDA #_1
  STA MMC3BankControl
  LDA #_2
  STA MMC3BankSelect
.macend
