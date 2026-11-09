ResetNES:
	SEI          		; disable IRQs
	CLD          		; disable decimal mode
	LDX #$40
	STX $4017    		; disable APU frame IRQ
	LDX #$00
	STX PPUControl1		; disable NMI
	STX PPUControl2		; disable rendering
	STX $4010			; disable DMC IRQs
	PLA					; Pull our return address off the old stack.
	TAY
	PLA
	LDX #$FF
	TXS					; Point the stack at the top of its page.
	PHA					; Put the return address back on the new stack.
	TYA
	PHA
	LDX #$00
	RTS

ClearRAM:			; Should be self-explanatory.
	LDX	#$00
*	LDA	#$00
	STA	$00,X
	; $100-$1FF contains the stack, call `clearStack instead.
	; $200-$2FF is our OAM copy. Clear with JSR ClearSprites.
	STA	$300,X
	STA	$400,X
	STA	$500,X
	STA	$600,X
	STA	$700,X
	INX
	BNE	-
	RTS

ResetScroll:		; Reset the scroll registers.
	LDA	#$00 		; Set accumulator to zero.
	STA	BGScroll 	; Zero out horizontal scroll.
	STA	BGScroll 	; Zero out vertical scroll.
	RTS

InitZP:
  LDA #$00
  LDX #$00
* STA $00, X
  INX
  BNE -
  RTS

; Clearing the stack is set up as a macro instead
; of a subroutine, because the stack contains the
; return address when a subroutine is called. If 
; we clear out the stack, and then call RTS, the
; program won't know where to go, and crash. This
; allows us to clear the stack with a single call
; for simplicity's sake, without crashing the game.
.macro clearStack
	LDX #$00
	LDA #$00
_clearByte:
	STA $100,X
	INX
	BNE _clearByte
.macend
