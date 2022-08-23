; Graphics Data
; HonkeyLogoData:
;  .byte $76, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F, $50, $51, $52, $53
;  .byte $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $1D, $1E, $1F, $60, $61, $62, $63
;  .byte $20, $21, $2B, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $2D, $2E, $2F, $70, $71, $72, $00
;  .byte $10, $11, $12, $33, $34, $35, $36, $37, $38, $2B, $3A, $3B, $3C, $3D, $3E, $3F, $30, $31, $32, $00
;  .byte $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F, $5E, $5F, $39, $00

; KongLogoData:
;  .byte $54, $55, $56, $03, $04, $05, $06, $57, $58, $59, $5A, $5B, $5C, $5D
;  .byte $64, $65, $66, $13, $14, $15, $16, $67, $68, $69, $6A, $6B, $6C, $6D
;  .byte $64, $75, $00, $23, $24, $25, $26, $77, $78, $2B, $7A, $7B, $7C, $7D
;  .byte $64, $73, $74, $33, $34, $35, $36, $6F, $79, $2B, $7E, $7F, $80, $81
;  .byte $22, $82, $83, $43, $44, $45, $46, $84, $85, $86, $87, $88, $89, $8A

; HonkeySprite:
;  .byte $C0, $C1, $C2, $C3 
;  .byte $D0, $D1, $D2, $D3 
;  .byte $E0, $E1, $E2, $E3 
;  .byte $F0, $F1, $F2, $F3 
;  .byte $C4, $C5, $C6, $C7 
;  .byte $D4, $D5, $D6, $D7 

; HonkeyKongURLData:
;  ; http://www.honkeykong.org/
;  .byte $8B, $8C, $8D, $8E, $8F, $90, $91, $92, $9B, $9C, $9D, $9E, $9F, $A0, $A1, $A2, $AB, $AC, $AD, $AE
;  .byte $93, $94, $95, $96, $97, $98, $99, $9A, $A3, $A4, $A5, $A6, $A7, $A8, $A9, $AA, $AF, $B0, $B1, $B2

; Raw Nametable data for the title screen.
TitleScreen:
 .incbin "../res/nam/reduxtitle2.nam"

ReduxField:
	.incbin "../res/nam/reduxfield.nam"

ReduxATR:
  .incbin "../res/nam/redux.atr"
  
RetroCard:
  .INCBIN "../res/nam/retroredux.nam"
  
CreditsBG:
  .INCBIN "../res/nam/creditsred.nam"
  
Credits1ATR:
  .INCBIN "../res/nam/credits1.atr"
  
Credits2ATR:
  .incbin "../res/nam/credits2.atr"