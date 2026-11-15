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

; ===================================================================
; Shadow-safe bankswitching, IRQ scanline counter, mirroring.
; These use the MMC3 shadow bytes at the end of ZeroPage/MainZP.asm.
; ===================================================================

; Extra flags for the bank select ($8000) register. OR them into X
; when calling MMC3SetBank if you need them.
  .alias  MMC3PRGFixed8000  $40   ; PRG mode 1: $C000 swappable, $8000 fixed

; Values for MMC3SetMirroring.
  .alias  MirrorVertical    $00   ; Horizontal arrangement (side-scrolling)
  .alias  MirrorHorizontal  $01   ; Vertical arrangement (vertical scrolling)

; Full MMC3 setup: banks from MMC3InitTable, vertical mirroring,
; IRQ off, and every shadow byte filled in to match.
MMC3Init:
  JSR InitMMC3
  LDX #$05
* LDA MMC3InitTable, X
  STA MMC3CHRBanks, X
  DEX
  BPL -
  LDA MMC3InitTable+6
  STA MMC3Bank8000
  LDA MMC3InitTable+7
  STA MMC3BankA000
  LDA #$00
  STA BankControl         ; InitMMC3 finishes by selecting register 0.
  STA MMC3IRQOff
  RTS

; X = bank register (CHR2K0...PRG01), A = bank number.
;
; Every write to $8000 goes through the BankControl shadow first, so an
; interrupt that switches banks itself can put $8000 back the way it found
; it (see MMC3RestoreSelect) without wrecking a switch in progress here.
MMC3SetBank:
  STX BankControl
  STX MMC3BankControl
  STA MMC3BankSelect
  RTS

; Call at the end of any interrupt handler that writes to $8000.
MMC3RestoreSelect:
  LDA BankControl
  STA MMC3BankControl
  RTS

; A = 8KB PRG bank to map at $8000-$9FFF. Clobbers X.
MMC3SetPRG8000:
  STA MMC3Bank8000
  LDX #PRG00
  JMP MMC3SetBank

; A = 8KB PRG bank to map at $A000-$BFFF. Clobbers X.
MMC3SetPRGA000:
  STA MMC3BankA000
  LDX #PRG01
  JMP MMC3SetBank

; Copy the six MMC3CHRBanks shadows into R0-R5. Change the shadows any
; time during the frame, then call this from your NMI so the switch
; lands during VBlank. Bank numbers are in 1KB units; R0 and R1 are 2KB
; banks, so their low bit is ignored. Clobbers A and X.
MMC3ApplyCHR:
  LDX #$05
* STX MMC3BankControl
  LDA MMC3CHRBanks, X
  STA MMC3BankSelect
  DEX
  BPL -
  LDA BankControl
  STA MMC3BankControl
  RTS

; A = MirrorVertical or MirrorHorizontal.
MMC3SetMirroring:
  STA MMC3Mirror
  RTS

; Call a routine that lives in another bank's $8000-$9FFF window, then
; put the original bank back. Must itself run from fixed ROM ($C000+).
; The routine's A and X results are lost; return values in memory.
.macro MMC3FarCall            ; `MMC3FarCall bank, routine
  LDA MMC3Bank8000
  PHA
  LDA #_1
  JSR MMC3SetPRG8000
  JSR _2
  PLA
  JSR MMC3SetPRG8000
.macend

; ----- Scanline IRQ -----
;
; The MMC3 counts rising edges on PPU address line A12. With 8x8 sprites,
; background tiles at $0000 and sprite tiles at $1000, that's exactly one
; tick per rendered scanline. Call MMC3IRQStart from your NMI with the
; number of the scanline the IRQ should fire after (the interrupt arrives
; near the end of that line, around dot 260). Remember to CLI.

; A = scanline count.
MMC3IRQStart:
  STA MMC3IRQLatch
  STA MMC3IRQReload
  STA MMC3IRQOn
  RTS

MMC3IRQStop:
  STA MMC3IRQOff
  RTS

; Put this at the top of your IRQ handler. Acknowledges the interrupt
; and disables further ones until the next MMC3IRQStart. Keeps A.
.macro MMC3IRQAck
  STA MMC3IRQOff
.macend

; Chain another split from inside the IRQ handler: A = scanlines from
; here to the next interrupt, minus one.
.macro MMC3IRQNext
  STA MMC3IRQOff
  STA MMC3IRQLatch
  STA MMC3IRQReload
  STA MMC3IRQOn
.macend
