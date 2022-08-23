; MMC1 Aliases

; NOTE: The MMC1 uses some weird serial port shit that no
; other mapper I've seen so far uses. I guess Nintendo
; didn't want to have a lot of extra pins on their mapper
; ASIC. I'm glad they came to their senses with the MMC3.

; Bankswitching seems to work by writing 5 bits to the
; mapper's shift register. With a nybble (half-byte/4 bits) 
; having a value from 0-F, that leaves a maximum number of
; 16 available 16KB PRG banks, for a grand total of 256KB.
; The fifth bit appears to be the control bit, telling the
; mapper which part of the ROM is being bankswitched.

; Gonna dump some docs here to reference as I work out the ASM code.

; CPU $6000-$7FFF: 8 KB PRG RAM bank, fixed on all boards but SOROM and SXROM
; CPU $8000-$BFFF: 16 KB PRG ROM bank, either switchable or fixed to the first bank
; CPU $C000-$FFFF: 16 KB PRG ROM bank, either fixed to the last bank or switchable
; PPU $0000-$0FFF: 4 KB switchable CHR bank
; PPU $1000-$1FFF: 4 KB switchable CHR bank

;Load register ($8000-$FFFF)
;7  bit  0
;---- ----
;Rxxx xxxD
;|       |
;|       +- Data bit to be shifted into shift register, LSB first
;+--------- 1: Reset shift register and write Control with (Control OR $0C),
;              locking PRG ROM at $C000-$FFFF to the last bank.

.alias  MMC1Load      $8000
  .alias  MMC1ResetBit   %10000000

;Control (internal, $8000-$9FFF)
;4bit0
;-----
;CPPMM
;|||||
;|||++- Mirroring (0: one-screen, lower bank; 1: one-screen, upper bank;
;|||               2: vertical; 3: horizontal)
;|++--- PRG ROM bank mode (0, 1: switch 32 KB at $8000, ignoring low bit of bank number;
;|                         2: fix first bank at $8000 and switch 16 KB bank at $C000;
;|                         3: fix last bank at $C000 and switch 16 KB bank at $8000)
;+----- CHR ROM bank mode (0: switch 8 KB at a time; 1: switch two separate 4 KB banks)

.alias  MMC1Config   $8000
  .alias  MMC1MirrorHoriz         %00011
  .alias  MMC1MirrorVert          %00010
  .alias  MMC1MirrorSingleUpper   %00001
  .alias  MMC1MirrorSingleLower   %00000
  .alias  MMC1PRGBank32KB         %00100
  .alias  MMC1PRGBankUpper16KB    %01100
  .alias  MMC1PRGBankLower16KB    %01000
  .alias  MMC1CHR8KB              %00000
  .alias  MMC1CHR4KB              %10000

;CHR bank 0 (internal, $A000-$BFFF)
;4bit0
;-----
;CCCCC
;|||||
;+++++- Select 4 KB or 8 KB CHR bank at PPU $0000 (low bit ignored in 8 KB mode)
;MMC1 can do CHR banking in 4KB chunks. Known carts with CHR RAM have 8 KiB, so
;that makes 2 banks. RAM vs ROM doesn't make any difference for address lines. 
;For carts with 8 KiB of CHR (be it ROM or RAM), MMC1 follows the common behavior
; of using only the low-order bits: the bank number is in effect ANDed with 1.

.alias  MMC1CHR0Select            $A000

;CHR bank 1 (internal, $C000-$DFFF)
;4bit0
;-----
;CCCCC
;|||||
;+++++- Select 4 KB CHR bank at PPU $1000 (ignored in 8 KB mode)

.alias  MMC1CHR1Select            $C000

;PRG bank (internal, $E000-$FFFF)
;4bit0
;-----
;RPPPP
;|||||
;|++++- Select 16 KB PRG ROM bank (low bit ignored in 32 KB mode)
;+----- PRG RAM chip enable (0: enabled; 1: disabled; ignored on MMC1A);

.alias  MMC1PRGSelect             $E000
  .alias  MMC1WRAMEnable          %00000
  .alias  MMC1WRAMDisable         %10000

; 8KB MMC1 Work RAM, also serves as 
; battery-backed SRAM on SNROM boards.
; Located at $6000-$7FFF
  .alias	MMC1WRAM			$6000

; TODO - A bunch of shit below this line needs to be fact-checked, because
; most of it is copied from my MMC3 code, and is probably incorrect for
; MMC1 usage. PRG RAM addressing is most likely correct, but everything
; else definitely needs a sanity check.

;----------------------------------------------------------------------

; MMC1 Functions

; First, write your mapper config into MMC1Config, then do the proper
; setup to bankswap the appropriate ROM/RAM location.

; Just LDA your bank number before calling this function, and it should
; take care of all the complicated shifting automatically.

; TODO - implement mapper shift register reset and sanity checks
; against mapper writes interrupted by VBlank.

; !! Don't forget to OR the PRG RAM enable/disable flags first!
MMC1SwitchPRG:
  STA MMC1PRGSelect
  LSR
  STA MMC1PRGSelect
  LSR
  STA MMC1PRGSelect
  LSR
  STA MMC1PRGSelect
  LSR
  STA MMC1PRGSelect
  RTS

; Same as above, only shifting data into CHR0 Select.
MMC1SwitchCHR0:
  STA MMC1CHR0Select
  LSR
  STA MMC1CHR0Select
  LSR
  STA MMC1CHR0Select
  LSR
  STA MMC1CHR0Select
  LSR
  STA MMC1CHR0Select
  RTS

; SHUT UP, YOU'RE A COPY AND PASTE HACK!
MMC1SwitchCHR1:
  STA MMC1CHR1Select
  LSR
  STA MMC1CHR1Select
  LSR
  STA MMC1CHR1Select
  LSR
  STA MMC1CHR1Select
  LSR
  STA MMC1CHR1Select
  RTS

; Hey, I got lucky on this one. The MMC3 and MMC1 have their WRAM in the exact
; same places, so all I need to do is fix the locking/unlocking logic, which
; as fate may have it, is a simple bitmask in the PRG control register.

; !! This means you NEED to set the RAM enable flag when tweaking PRG banks.
; A smart coder would set a few bytes in zero page with the current mapper
; configuration, then OR the flags against that before calling the PRG Switch.

ClearMMC1WRAM:		; Clear out MMC1 WRAM. Erases battery backup on SNROM.
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
	RTS