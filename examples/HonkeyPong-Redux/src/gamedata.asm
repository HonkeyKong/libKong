; Game Constants
  .alias LEFTWALL    	$0C
  .alias RIGHTWALL   	$ED
  .alias TOPWALL     	$24
  .alias BOTTOMWALL  	$D4
  .alias PADDLETOP 		$26
  .alias PADDLEBOTTOM $DA
  .alias PADDLELENGTH	$18
  .alias BOTTOMBOUND  $C0
  .alias TOPBOUND     $BD

  .alias STATETITLE     $00
  .alias STATEPLAYING   $01
  .alias STATEGAMEOVER  $02
  .alias STATETITLECARD $03
  .alias STATEOPTIONS   $04
  .alias STATECREDITS   $05
  .alias STATEPAUSED    $06
  .alias PADDLE1X       $18
  .alias PADDLE2X       $E2

; These are the locations in the PPU
; Memory where the tables should be changed.
; Found by starting at $2000 and counting
; forward 1 byte per tile (32 tiles per row).
  .alias  ScoreP1Loc        $284C
  .alias  ScoreP2Loc        $285B

  .alias  gameOverField     $29CB
  .alias  pressStartField   $29E6

TitleCursors:
  .byte $97, $9E, $A7, $AE, $B7

scoreRow:
  .byte "  Player 1: 0    Player 2: 0    "

scoreWin:
  .byte "WIN"

scoreLose:
  .byte "LOSE"

gameOverLine1:
  .byte "GAME OVER!"

gameOverLine2:
  .byte "Press A to continue."

scoreTable:
  .byte "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"