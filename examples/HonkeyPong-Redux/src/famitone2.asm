; I should note that while I haven't changed much in the functionality of the code
; written by Shiru and Pops, I did do a lot of adjustment for readability's sake.
; I want to keep this project consistent on that front. That being said, here's the
; gist of what I changed and why.
; 
; 1. Assembler directives are only syntax highlighted in editors like Sublime Text
; 	 when they're indented, so 2-space indentation has been applied.
; 2. Opcodes are also only syntax highlighted in said editors when they're in caps.
; 3. The mix of decimal and hex numbers in code seemed strange and inconsistent,
;    and lowercase hex numbers just look weird, so those have been corrected.
; 
; Having said that, thanks for the audio code. It saves me from having to write my 
; own sound engine right now. Cheers!
; 
; -- HonkeyKong

; ============================== Public Defines ================================
; Note: The FT_BASE_ADR AND FT_TEMP variables are relocated to main.asm.
; There's a better way to reserve the FT_BASE_ADR memory, as illustrated there.
; I don't want FT_TEMP hardcoded at the beginning of zeropage, trashing game vars.
;  .alias	FT_BASE_ADR			$0300	; page in RAM, should be $xx00.
;  .alias	FT_TEMP			  	$00		; 3 bytes in zeropage used as a scratchpad
  .alias	FT_SFX_STREAMS		4		; # sound effects played at once.
  ;.alias	FT_DPCM_DATA		$C000	; location of DPCM samples in ROM.
  ;.alias	FT_DPCM_PTR		  	[FT_DPCM_DATA & $3FFF]/64
  
; ================================= Registers ==================================
  .alias 	PPU_CTRL			$2000
  .alias 	PPU_MASK			$2001
  .alias 	PPU_STATUS			$2002
  .alias 	PPU_SCROLL			$2005
  .alias 	PPU_ADDR			$2006
  .alias 	PPU_DATA			$2007
  .alias	APU_PL1_VOL			$4000
  .alias	APU_PL1_SWEEP		$4001
  .alias	APU_PL1_LO			$4002
  .alias	APU_PL1_HI			$4003
  .alias	APU_PL2_VOL			$4004
  .alias	APU_PL2_SWEEP		$4005
  .alias	APU_PL2_LO			$4006
  .alias	APU_PL2_HI			$4007
  .alias	APU_TRI_LINEAR		$4008
  .alias	APU_TRI_LO			$400A
  .alias	APU_TRI_HI			$400B
  .alias	APU_NOISE_VOL		$400C
  .alias	APU_NOISE_LO		$400E
  .alias	APU_NOISE_HI		$400F
  .alias	APU_DMC_FREQ		$4010
  .alias	APU_DMC_RAW			$4011
  .alias	APU_DMC_START		$4012
  .alias	APU_DMC_LEN			$4013
  .alias	PPU_SPR_DMA			$4014
  .alias	APU_SND_CHN			$4015
  .alias	CTRL_PORT1			$4016
  .alias	APU_FRAMECNT		$4017

; ============================= FamiTone2 Library ==============================
;zero page variables

  .alias	FT_TEMP_PTR			  	FT_TEMP		;word
  .alias	FT_TEMP_PTR_L		  	FT_TEMP_PTR+0
  .alias	FT_TEMP_PTR_H		  	FT_TEMP_PTR+1
  .alias	FT_TEMP_VAR1		  	FT_TEMP+2


;envelope structure offsets, 5 bytes per envelope, grouped by variable type

  .alias	FT_ENVELOPES_ALL	  	3+3+3+2	; 3 for the pulse AND triangle channels, 
  .alias	FT_ENV_STRUCT_SIZE	  	5		; 2 for the noise channel

  .alias	FT_ENV_VALUE		  	FT_BASE_ADR+0*FT_ENVELOPES_ALL
  .alias	FT_ENV_REPEAT		  	FT_BASE_ADR+1*FT_ENVELOPES_ALL
  .alias	FT_ENV_ADR_L		  	FT_BASE_ADR+2*FT_ENVELOPES_ALL
  .alias	FT_ENV_ADR_H		  	FT_BASE_ADR+3*FT_ENVELOPES_ALL
  .alias	FT_ENV_PTR			  	FT_BASE_ADR+4*FT_ENVELOPES_ALL


;channel structure offsets, 7 bytes per channel

  .alias	FT_CHANNELS_ALL		  	5
  .alias	FT_CHN_STRUCT_SIZE	  	9

  .alias	FT_CHN_PTR_L		  	FT_BASE_ADR+0*FT_CHANNELS_ALL
  .alias	FT_CHN_PTR_H		  	FT_BASE_ADR+1*FT_CHANNELS_ALL
  .alias	FT_CHN_NOTE			  	FT_BASE_ADR+2*FT_CHANNELS_ALL
  .alias	FT_CHN_INSTRUMENT	  	FT_BASE_ADR+3*FT_CHANNELS_ALL
  .alias	FT_CHN_REPEAT		 	FT_BASE_ADR+4*FT_CHANNELS_ALL
  .alias	FT_CHN_RETURN_L		  	FT_BASE_ADR+5*FT_CHANNELS_ALL
  .alias	FT_CHN_RETURN_H		  	FT_BASE_ADR+6*FT_CHANNELS_ALL
  .alias	FT_CHN_REF_LEN		  	FT_BASE_ADR+7*FT_CHANNELS_ALL
  .alias	FT_CHN_DUTY				FT_BASE_ADR+8*FT_CHANNELS_ALL


;variables AND aliases

  .alias	FT_ENVELOPES	  		FT_BASE_ADR
  .alias	FT_CH1_ENVS				FT_ENVELOPES+0
  .alias	FT_CH2_ENVS				FT_ENVELOPES+3
  .alias	FT_CH3_ENVS				FT_ENVELOPES+6
  .alias	FT_CH4_ENVS		  		FT_ENVELOPES+9

  .alias	FT_CHANNELS		  		FT_ENVELOPES+FT_ENVELOPES_ALL*FT_ENV_STRUCT_SIZE
  .alias	FT_CH1_VARS		  		FT_CHANNELS+0
  .alias	FT_CH2_VARS		  		FT_CHANNELS+1
  .alias	FT_CH3_VARS		  		FT_CHANNELS+2
  .alias	FT_CH4_VARS		  		FT_CHANNELS+3
  .alias	FT_CH5_VARS		  		FT_CHANNELS+4


  .alias	FT_CH1_NOTE			  	FT_CH1_VARS+<FT_CHN_NOTE
  .alias	FT_CH2_NOTE			  	FT_CH2_VARS+<FT_CHN_NOTE
  .alias	FT_CH3_NOTE			  	FT_CH3_VARS+<FT_CHN_NOTE
  .alias	FT_CH4_NOTE			  	FT_CH4_VARS+<FT_CHN_NOTE
  .alias	FT_CH5_NOTE			  	FT_CH5_VARS+<FT_CHN_NOTE

  .alias	FT_CH1_INSTRUMENT	  	FT_CH1_VARS+<FT_CHN_INSTRUMENT
  .alias	FT_CH2_INSTRUMENT	  	FT_CH2_VARS+<FT_CHN_INSTRUMENT
  .alias	FT_CH3_INSTRUMENT	  	FT_CH3_VARS+<FT_CHN_INSTRUMENT
  .alias	FT_CH4_INSTRUMENT	  	FT_CH4_VARS+<FT_CHN_INSTRUMENT
  .alias	FT_CH5_INSTRUMENT	  	FT_CH5_VARS+<FT_CHN_INSTRUMENT

  .alias	FT_CH1_DUTY			  	FT_CH1_VARS+<FT_CHN_DUTY
  .alias	FT_CH2_DUTY			  	FT_CH2_VARS+<FT_CHN_DUTY
  .alias	FT_CH3_DUTY			  	FT_CH3_VARS+<FT_CHN_DUTY
  .alias	FT_CH4_DUTY			  	FT_CH4_VARS+<FT_CHN_DUTY
  .alias	FT_CH5_DUTY			  	FT_CH5_VARS+<FT_CHN_DUTY

  .alias	FT_CH1_VOLUME		  	FT_CH1_ENVS+<FT_ENV_VALUE+0
  .alias	FT_CH2_VOLUME		  	FT_CH2_ENVS+<FT_ENV_VALUE+0
  .alias	FT_CH3_VOLUME		  	FT_CH3_ENVS+<FT_ENV_VALUE+0
  .alias	FT_CH4_VOLUME		  	FT_CH4_ENVS+<FT_ENV_VALUE+0

  .alias	FT_CH1_NOTE_OFF		  	FT_CH1_ENVS+<FT_ENV_VALUE+1
  .alias	FT_CH2_NOTE_OFF		  	FT_CH2_ENVS+<FT_ENV_VALUE+1
  .alias	FT_CH3_NOTE_OFF		  	FT_CH3_ENVS+<FT_ENV_VALUE+1
  .alias	FT_CH4_NOTE_OFF		  	FT_CH4_ENVS+<FT_ENV_VALUE+1

  .alias	FT_CH1_PITCH_OFF	  	FT_CH1_ENVS+<FT_ENV_VALUE+2
  .alias	FT_CH2_PITCH_OFF	  	FT_CH2_ENVS+<FT_ENV_VALUE+2
  .alias	FT_CH3_PITCH_OFF	  	FT_CH3_ENVS+<FT_ENV_VALUE+2


  .alias	FT_VARS			  		FT_CHANNELS+FT_CHANNELS_ALL*FT_CHN_STRUCT_SIZE

  .alias	FT_PAL_ADJUST	  FT_VARS+0
  .alias	FT_SONG_LIST_L	  FT_VARS+1
  .alias	FT_SONG_LIST_H	  FT_VARS+2
  .alias	FT_INSTRUMENT_L   FT_VARS+3
  .alias	FT_INSTRUMENT_H   FT_VARS+4
  .alias	FT_TEMPO_STEP_L	  FT_VARS+5
  .alias	FT_TEMPO_STEP_H	  FT_VARS+6
  .alias	FT_TEMPO_ACC_L	  FT_VARS+7
  .alias	FT_TEMPO_ACC_H	  FT_VARS+8
  .alias	FT_SONG_SPEED	  FT_CH5_INSTRUMENT
  .alias	FT_PULSE1_PREV	  FT_CH3_DUTY
  .alias	FT_PULSE2_PREV	  FT_CH5_DUTY
  .alias	FT_DPCM_LIST_L	  FT_VARS+9
  .alias	FT_DPCM_LIST_H	  FT_VARS+10
  .alias	FT_DPCM_EFFECT    FT_VARS+11
  .alias	FT_OUT_BUF		  FT_VARS+12	;11 bytes


;sound effect stream variables, 2 bytes AND 15 bytes per stream
;when sound effects are disabled, this memory is not used
  .alias	FT_SFX_ADR_L		  FT_VARS+23
  .alias	FT_SFX_ADR_H		  FT_VARS+24
  .alias	FT_SFX_BASE_ADR		  FT_VARS+25
  .alias	FT_SFX_STRUCT_SIZE	  15
  .alias	FT_SFX_REPEAT		  FT_SFX_BASE_ADR+0
  .alias	FT_SFX_PTR_L		  FT_SFX_BASE_ADR+1
  .alias	FT_SFX_PTR_H		  FT_SFX_BASE_ADR+2
  .alias	FT_SFX_OFF			  FT_SFX_BASE_ADR+3
  .alias	FT_SFX_BUF			  FT_SFX_BASE_ADR+4	;11 bytes


;aliases for sound effect channels to use in user calls
  .alias	FT_SFX_CH0			  FT_SFX_STRUCT_SIZE*0
  .alias	FT_SFX_CH1			  FT_SFX_STRUCT_SIZE*1
  .alias	FT_SFX_CH2			  FT_SFX_STRUCT_SIZE*2
  .alias	FT_SFX_CH3			  FT_SFX_STRUCT_SIZE*3


; aliases for the APU registers in the output buffer
; sound effects are enabled, thus write to output buffer.
  .alias	FT_MR_PULSE1_V		  FT_OUT_BUF
  .alias	FT_MR_PULSE1_L		  FT_OUT_BUF+1
  .alias	FT_MR_PULSE1_H		  FT_OUT_BUF+2
  .alias	FT_MR_PULSE2_V		  FT_OUT_BUF+3
  .alias	FT_MR_PULSE2_L		  FT_OUT_BUF+4
  .alias	FT_MR_PULSE2_H		  FT_OUT_BUF+5
  .alias	FT_MR_TRI_V			  FT_OUT_BUF+6
  .alias	FT_MR_TRI_L			  FT_OUT_BUF+7
  .alias	FT_MR_TRI_H			  FT_OUT_BUF+8
  .alias	FT_MR_NOISE_V		  FT_OUT_BUF+9
  .alias	FT_MR_NOISE_F		  FT_OUT_BUF+10

.macro FT_SwitchBank
	;PHA
	;`A53_SwitchBank 2
	;PLA
.macend


;------------------------------------------------------------------------------
; reset APU, initialize FamiTone
; in: A   0 for NTSC, not 1 for PAL
;     X,Y pointer to music data
;------------------------------------------------------------------------------

FamiToneInit:
	`FT_SwitchBank
	STX FT_SONG_LIST_L		;store music data pointer for further use
	STY FT_SONG_LIST_H
	STX <FT_TEMP_PTR_L
	STY <FT_TEMP_PTR_H
	
	TAX						;set SZ flags for A
	BEQ _pal
	LDA #$40
_pal:
	STA FT_PAL_ADJUST
	
	JSR FamiToneMusicStop	;initialize channels AND envelopes
	
	LDY #$01
	LDA (FT_TEMP_PTR),y		;get instrument list address
	STA FT_INSTRUMENT_L
	INY
	LDA (FT_TEMP_PTR),y
	STA FT_INSTRUMENT_H
	INY
	LDA (FT_TEMP_PTR),y		;get sample list address
	STA FT_DPCM_LIST_L
	INY
	LDA (FT_TEMP_PTR),y
	STA FT_DPCM_LIST_H

	LDA #$FF				;previous pulse period MSB, to not write it when not changed
	STA FT_PULSE1_PREV
	STA FT_PULSE2_PREV

	LDA #$0F				;enable channels, stop DMC
	STA APU_SND_CHN
	LDA #$80				;disable triangle length counter
	STA APU_TRI_LINEAR
	LDA #$00				;load noise length
	STA APU_NOISE_HI

	LDA #$30				;volumes to 0
	STA APU_PL1_VOL
	STA APU_PL2_VOL
	STA APU_NOISE_VOL
	LDA #$08				;no sweep
	STA APU_PL1_SWEEP
	STA APU_PL2_SWEEP

	;JMP FamiToneMusicStop


;------------------------------------------------------------------------------
; stop music that is currently playing, if any
; in: none
;------------------------------------------------------------------------------

FamiToneMusicStop:
.scope
	LDA #$00
	STA FT_SONG_SPEED		;stop music, reset pause flag
	STA FT_DPCM_EFFECT		;no DPCM effect playing

	LDX #<FT_CHANNELS	;initialize channel structures

_set_channels:

	LDA #$00
	STA FT_CHN_REPEAT,x
	STA FT_CHN_INSTRUMENT,x
	STA FT_CHN_NOTE,x
	STA FT_CHN_REF_LEN,x
	LDA #$30
	STA FT_CHN_DUTY,x

	INX						;next channel
	CPX #<FT_CHANNELS+FT_CHANNELS_ALL
	BNE _set_channels

	LDX #<FT_ENVELOPES	;initialize all envelopes to the dummy envelope
.scend
_set_envelopes:

	LDA #<_FT2DummyEnvelope
	STA FT_ENV_ADR_L,x
	LDA #>_FT2DummyEnvelope
	STA FT_ENV_ADR_H,x
	LDA #$00
	STA FT_ENV_REPEAT,x
	STA FT_ENV_VALUE,x
	INX
	CPX #<FT_ENVELOPES+FT_ENVELOPES_ALL

	BNE _set_envelopes

	RTS


;------------------------------------------------------------------------------
; Play music
; in: A number of subsong
;------------------------------------------------------------------------------

FamiToneMusicPlay:
	`FT_SwitchBank
.scope
	LDX FT_SONG_LIST_L
	STX <FT_TEMP_PTR_L
	LDX FT_SONG_LIST_H
	STX <FT_TEMP_PTR_H

	LDY #$00
	CMP (FT_TEMP_PTR),y		;check if there is such sub song
	BCS _skip

	ASL						;multiply song number by 14
	STA <FT_TEMP_PTR_L		;use pointer LSB as temp variable
	ASL
	TAX
	ASL
	ADC <FT_TEMP_PTR_L
	STX <FT_TEMP_PTR_L
	ADC <FT_TEMP_PTR_L
	ADC #$05					;add offset
	TAY

	LDA FT_SONG_LIST_L		;restore pointer LSB
	STA <FT_TEMP_PTR_L

	JSR FamiToneMusicStop	;stop music, initialize channels AND envelopes

	LDX #<FT_CHANNELS	;initialize channel structures

_set_channels:

	LDA (FT_TEMP_PTR),y		;read channel pointers
	STA FT_CHN_PTR_L,x
	INY
	LDA (FT_TEMP_PTR),y
	STA FT_CHN_PTR_H,x
	INY

	LDA #$00
	STA FT_CHN_REPEAT,x
	STA FT_CHN_INSTRUMENT,x
	STA FT_CHN_NOTE,x
	STA FT_CHN_REF_LEN,x
	LDA #$30
	STA FT_CHN_DUTY,x

	INX						;next channel
	CPX #<FT_CHANNELS+FT_CHANNELS_ALL
	BNE _set_channels


	LDA FT_PAL_ADJUST		;read tempo for PAL or NTSC
	BEQ _pal
	INY
	INY
_pal:

	LDA (FT_TEMP_PTR),y		;read the tempo step
	STA FT_TEMPO_STEP_L
	INY
	LDA (FT_TEMP_PTR),y
	STA FT_TEMPO_STEP_H


	LDA #$00					;reset tempo accumulator
	STA FT_TEMPO_ACC_L
	LDA #$06					;default speed
	STA FT_TEMPO_ACC_H
	STA FT_SONG_SPEED		;apply default speed, this also enables music

_skip:
	RTS
.scend

;------------------------------------------------------------------------------
; pause AND unpause current music
; in: A 0 or not 0 to play or pause
;------------------------------------------------------------------------------

FamiToneMusicPause:
.scope
	TAX					;set SZ flags for A
	BEQ _unpause
_pause:
	LDA #$00				;mute sound
	STA FT_CH1_VOLUME
	STA FT_CH2_VOLUME
	STA FT_CH3_VOLUME
	STA FT_CH4_VOLUME
	LDA FT_SONG_SPEED	;set pause flag
	ORA #$80
	BNE _done
_unpause:
	LDA FT_SONG_SPEED	;reset pause flag
	AND #$7F
_done:
	STA FT_SONG_SPEED

	RTS
.scend

;------------------------------------------------------------------------------
; update FamiTone STAte, should be called every NMI
; in: none
;------------------------------------------------------------------------------

FamiToneUpdate:
	`FT_SwitchBank
	
	;.byte $ad,$00,$00
	LDA FT_TEMP_PTR_L
	PHA
	;.byte $ad,$01,$00
	LDA FT_TEMP_PTR_H
	PHA

	LDA FT_SONG_SPEED		;speed 0 means that no music is playing currently
	BMI _pause				;bit 7 set is the pause flag
	BNE _update
_pause:
	JMP _update_sound

_update:

	CLC						;update frame counter that considers speed, tempo, AND PAL/NTSC
	LDA FT_TEMPO_ACC_L
	ADC FT_TEMPO_STEP_L
	STA FT_TEMPO_ACC_L
	LDA FT_TEMPO_ACC_H
	ADC FT_TEMPO_STEP_H
	CMP FT_SONG_SPEED
	BCS _update_row			;overflow, row update is needed
	STA FT_TEMPO_ACC_H		;no row update, skip to the envelopes update
	JMP _update_envelopes

_update_row:

	SEC
	SBC FT_SONG_SPEED
	STA FT_TEMPO_ACC_H


	LDX #<FT_CH1_VARS	;process channel 1
	JSR _FT2ChannelUpdate
	BCC _no_new_note1
	LDX #<FT_CH1_ENVS
	LDA FT_CH1_INSTRUMENT
	JSR _FT2SetInstrument
	STA FT_CH1_DUTY
_no_new_note1:

	LDX #<FT_CH2_VARS	;process channel 2
	JSR _FT2ChannelUpdate
	BCC _no_new_note2
	LDX #<FT_CH2_ENVS
	LDA FT_CH2_INSTRUMENT
	JSR _FT2SetInstrument
	STA FT_CH2_DUTY
_no_new_note2:

	LDX #<FT_CH3_VARS	;process channel 3
	JSR _FT2ChannelUpdate
	BCC _no_new_note3
	LDX #<FT_CH3_ENVS
	LDA FT_CH3_INSTRUMENT
	JSR _FT2SetInstrument
_no_new_note3:

	LDX #<FT_CH4_VARS	;process channel 4
	JSR _FT2ChannelUpdate
	BCC _no_new_note4
	LDX #<FT_CH4_ENVS
	LDA FT_CH4_INSTRUMENT
	JSR _FT2SetInstrument
	STA FT_CH4_DUTY
_no_new_note4:

	LDX #<FT_CH5_VARS	;process channel 5
	JSR _FT2ChannelUpdate
	BCC _no_new_note5
	LDA FT_CH5_NOTE
	BNE _play_sample
	JSR FamiToneSampleStop
	BNE _no_new_note5		;A is non-zero after FamiToneSampleStop
_play_sample:
	JSR FamiToneSamplePlayM
_no_new_note5:


_update_envelopes:

	LDX #<FT_ENVELOPES ;process 11 envelopes

_envprocess:

	LDA FT_ENV_REPEAT,x		;check envelope repeat counter
	BEQ _envread			;if it is zero, process envelope
	DEC FT_ENV_REPEAT,x		;otherwise DECrement the counter
	BNE _envnext

_envread:

	LDA FT_ENV_ADR_L,x		;load envelope data address into temp
	STA <FT_TEMP_PTR_L
	LDA FT_ENV_ADR_H,x
	STA <FT_TEMP_PTR_H
	LDY FT_ENV_PTR,x		;load envelope pointer

_envread_value:

	LDA (FT_TEMP_PTR),y		;read a byte of the envelope data
	BPL _envspecial		;values below 128 used as a special code, loop or repeat
	CLC						;values above 128 are output value+192 (output values are signed -63..64)
	;ADC #256-192
	ADC #$40
	STA FT_ENV_VALUE,x		;store the output value
	INY						;advance the pointer
	BNE _envnext_store_ptr ;bra

_envspecial:

	BNE _envset_repeat		;zero is the loop point, non-zero values used for the repeat counter
	INY						;advance the pointer
	LDA (FT_TEMP_PTR),y		;read loop position
	TAY						;use loop position
	JMP _envread_value		;read next byte of the envelope

_envset_repeat:

	INY
	STA FT_ENV_REPEAT,x		;store the repeat counter value

_envnext_store_ptr:

	TYA						;store the envelope pointer
	STA FT_ENV_PTR,x

_envnext:

	INX						;next envelope

	CPX #<FT_ENVELOPES+FT_ENVELOPES_ALL
	BNE _envprocess


_update_sound:

	;convert envelope AND channel output data into APU register values in the output buffer

	LDA FT_CH1_NOTE
	BEQ _ch1cut
	CLC
	ADC FT_CH1_NOTE_OFF
	ORA FT_PAL_ADJUST
	TAX
	LDA FT_CH1_PITCH_OFF
	TAY
	ADC _FT2NoteTableLSB,x
	STA FT_MR_PULSE1_L
	TYA						;sign extension for the pitch offset
	ORA #$7F
	BMI _ch1sign
	LDA #$00
_ch1sign:
	ADC _FT2NoteTableMSB,x
	STA FT_MR_PULSE1_H
_ch1prev:
	LDA FT_CH1_VOLUME
_ch1cut:
	ORA FT_CH1_DUTY
	STA FT_MR_PULSE1_V


	LDA FT_CH2_NOTE
	BEQ _ch2cut
	CLC
	ADC FT_CH2_NOTE_OFF
	ORA FT_PAL_ADJUST
	TAX
	LDA FT_CH2_PITCH_OFF
	TAY
	ADC _FT2NoteTableLSB,x
	STA FT_MR_PULSE2_L
	TYA
	ORA #$7F
	BMI _ch2sign
	LDA #$00
_ch2sign:
	ADC _FT2NoteTableMSB,x
	STA FT_MR_PULSE2_H
_ch2prev:
	LDA FT_CH2_VOLUME
_ch2cut:
	ORA FT_CH2_DUTY
	STA FT_MR_PULSE2_V


	LDA FT_CH3_NOTE
	BEQ _ch3cut
	CLC
	ADC FT_CH3_NOTE_OFF
	ORA FT_PAL_ADJUST
	TAX
	LDA FT_CH3_PITCH_OFF
	TAY
	ADC _FT2NoteTableLSB,x
	STA FT_MR_TRI_L
	TYA
	ORA #$7F
	BMI _ch3sign
	LDA #$00
_ch3sign:
	ADC _FT2NoteTableMSB,x
	STA FT_MR_TRI_H
	LDA FT_CH3_VOLUME
_ch3cut:
	ORA #$80
	STA FT_MR_TRI_V


	LDA FT_CH4_NOTE
	BEQ _ch4cut
	CLC
	ADC FT_CH4_NOTE_OFF
	AND #$0F
	EOR #$0F
	STA <FT_TEMP_VAR1
	LDA FT_CH4_DUTY
	ASL
	AND #$80
	ORA <FT_TEMP_VAR1
	STA FT_MR_NOISE_F
	LDA FT_CH4_VOLUME
_ch4cut:
	ORA #$F0
	STA FT_MR_NOISE_V

	;process all sound effect streams
	
	LDX #FT_SFX_CH0
	JSR _FT2SfxUpdate
	LDX #FT_SFX_CH1
	JSR _FT2SfxUpdate
	LDX #FT_SFX_CH2
	JSR _FT2SfxUpdate
	LDX #FT_SFX_CH3
	JSR _FT2SfxUpdate

	;send data from the output buffer to the APU

	LDA FT_OUT_BUF		;pulse 1 volume
	STA APU_PL1_VOL
	LDA FT_OUT_BUF+1	;pulse 1 period LSB
	STA APU_PL1_LO
	LDA FT_OUT_BUF+2	;pulse 1 period MSB, only applied when changed
	CMP FT_PULSE1_PREV
	BEQ _no_pulse1_upd
	STA FT_PULSE1_PREV
	STA APU_PL1_HI
_no_pulse1_upd:

	LDA FT_OUT_BUF+3	;pulse 2 volume
	STA APU_PL2_VOL
	LDA FT_OUT_BUF+4	;pulse 2 period LSB
	STA APU_PL2_LO
	LDA FT_OUT_BUF+5	;pulse 2 period MSB, only applied when changed
	CMP FT_PULSE2_PREV
	BEQ _no_pulse2_upd
	STA FT_PULSE2_PREV
	STA APU_PL2_HI
_no_pulse2_upd:

	LDA FT_OUT_BUF+6	;triangle volume (plays or not)
	STA APU_TRI_LINEAR
	LDA FT_OUT_BUF+7	;triangle period LSB
	STA APU_TRI_LO
	LDA FT_OUT_BUF+8	;triangle period MSB
	STA APU_TRI_HI

	LDA FT_OUT_BUF+9	;noise volume
	STA APU_NOISE_VOL
	LDA FT_OUT_BUF+10	;noise period
	STA APU_NOISE_LO

	PLA
	;.byte $8d,$01,$00
	STA FT_TEMP_PTR_H
	PLA
	;.byte $8d,$00,$00
	STA FT_TEMP_PTR_L

	RTS


;internal routine, sets up envelopes of a channel according to current instrument
;in X envelope group offset, A instrument number

_FT2SetInstrument:
	ASL						;instrument number is pre multiplied by 4
	TAY
	LDA FT_INSTRUMENT_H
	ADC #$00				;use carry to extend range for 64 instruments
	STA <FT_TEMP_PTR_H
	LDA FT_INSTRUMENT_L
	STA <FT_TEMP_PTR_L

	LDA (FT_TEMP_PTR),y		;duty cycle
	STA <FT_TEMP_VAR1
	INY

	LDA (FT_TEMP_PTR),y		;instrument pointer LSB
	STA FT_ENV_ADR_L,x
	INY
	LDA (FT_TEMP_PTR),y		;instrument pointer MSB
	INY
	STA FT_ENV_ADR_H,x
	INX						;next envelope

	LDA (FT_TEMP_PTR),y		;instrument pointer LSB
	STA FT_ENV_ADR_L,x
	INY
	LDA (FT_TEMP_PTR),y		;instrument pointer MSB
	STA FT_ENV_ADR_H,x

	LDA #$00
	STA FT_ENV_REPEAT-1,x	;reset env1 repeat counter
	STA FT_ENV_PTR-1,x		;reset env1 pointer
	STA FT_ENV_REPEAT,x		;reset env2 repeat counter
	STA FT_ENV_PTR,x		;reset env2 pointer

	CPX #<FT_CH4_ENVS	;noise channel has only two envelopes
	BCS _no_pitch

	INX						;next envelope
	INY
	STA FT_ENV_REPEAT,x		;reset env3 repeat counter
	STA FT_ENV_PTR,x		;reset env3 pointer
	LDA (FT_TEMP_PTR),y		;instrument pointer LSB
	STA FT_ENV_ADR_L,x
	INY
	LDA (FT_TEMP_PTR),y		;instrument pointer MSB
	STA FT_ENV_ADR_H,x

_no_pitch:
	LDA <FT_TEMP_VAR1
	RTS


;internal routine, parses channel note data

_FT2ChannelUpdate:
.scope
	LDA FT_CHN_REPEAT,x		;check repeat counter
	BEQ _no_repeat
	DEC FT_CHN_REPEAT,x		;DECrease repeat counter
	CLC						;no new note
	RTS

_no_repeat:
	LDA FT_CHN_PTR_L,x		;load channel pointer into temp
	STA <FT_TEMP_PTR_L
	LDA FT_CHN_PTR_H,x
	STA <FT_TEMP_PTR_H
_no_repeat_r:
	LDY #$00

_read_byte:
	LDA (FT_TEMP_PTR),y		;read byte of the channel

	INC <FT_TEMP_PTR_L		;advance pointer
	BNE _no_INC_ptr1
	INC <FT_TEMP_PTR_H
_no_INC_ptr1:

	ORA #$00
	BMI _special_code		;bit 7 0=note 1=special code

	LSR						;bit 0 set means the note is followed by an empty row
	BCC _no_empty_row
	INC FT_CHN_REPEAT,x		;set repeat counter to 1
_no_empty_row:
	STA FT_CHN_NOTE,x		;store note code
	SEC						;new note flag is set
	BCS _done ;bra

_special_code:
	AND #$7F
	LSR
	BCS _set_empty_rows
	ASL
	ASL
	STA FT_CHN_INSTRUMENT,x	;store instrument number*4
	BCC _read_byte ;bra

_set_empty_rows:
	CMP #$3D
	BCC _set_repeat
	BEQ _set_speed
	CMP #$3E
	BEQ _set_loop

_set_reference:
	CLC						;remember return address+3
	LDA <FT_TEMP_PTR_L
	ADC #$03
	STA FT_CHN_RETURN_L,x
	LDA <FT_TEMP_PTR_H
	ADC #$00
	STA FT_CHN_RETURN_H,x
	LDA (FT_TEMP_PTR),y		;read length of the reference (how many rows)
	STA FT_CHN_REF_LEN,x
	INY
	LDA (FT_TEMP_PTR),y		;read 16-bit absolute address of the reference
	STA <FT_TEMP_VAR1		;remember in temp
	INY
	LDA (FT_TEMP_PTR),y
	STA <FT_TEMP_PTR_H
	LDA <FT_TEMP_VAR1
	STA <FT_TEMP_PTR_L
	LDY #$00
	JMP _read_byte

_set_speed:
	LDA (FT_TEMP_PTR),y
	STA FT_SONG_SPEED
	INC <FT_TEMP_PTR_L		;advance pointer after reading the speed value
	BNE _read_byte
	INC <FT_TEMP_PTR_H
	BNE _read_byte ;bra

_set_loop:
	LDA (FT_TEMP_PTR),y
	STA <FT_TEMP_VAR1
	INY
	LDA (FT_TEMP_PTR),y
	STA <FT_TEMP_PTR_H
	LDA <FT_TEMP_VAR1
	STA <FT_TEMP_PTR_L
	DEY
	JMP _read_byte

_set_repeat:
	STA FT_CHN_REPEAT,x		;set up repeat counter, carry is clear, no new note

_done:
	LDA FT_CHN_REF_LEN,x	;check reference row counter
	BEQ _no_ref				;if it is zero, there is no reference
	DEC FT_CHN_REF_LEN,x	;DECrease row counter
	BNE _no_ref

	LDA FT_CHN_RETURN_L,x	;end of a reference, return to previous pointer
	STA FT_CHN_PTR_L,x
	LDA FT_CHN_RETURN_H,x
	STA FT_CHN_PTR_H,x
	RTS

_no_ref:
	LDA <FT_TEMP_PTR_L
	STA FT_CHN_PTR_L,x
	LDA <FT_TEMP_PTR_H
	STA FT_CHN_PTR_H,x
	RTS
.scend
;------------------------------------------------------------------------------
; stop DPCM sample if it plays
;------------------------------------------------------------------------------

FamiToneSampleStop:

	LDA #%00001111
	STA APU_SND_CHN

	RTS


;------------------------------------------------------------------------------
; Play DPCM sample, used by music player, could be used externally
; in: A is number of a sample, 1..12
;------------------------------------------------------------------------------

FamiToneSamplePlayM:		;for music (low priority)
	`FT_SwitchBank
	LDX FT_DPCM_EFFECT
	BEQ _FT2SamplePlay
	TAX
	LDA APU_SND_CHN
	AND #$10
	BEQ _not_busy
	RTS

_not_busy:
	STA FT_DPCM_EFFECT
	TXA
	JMP _FT2SamplePlay

;------------------------------------------------------------------------------
; Play DPCM sample with higher priority, for sound effects
; in: A is number of a sample, 1..12
;------------------------------------------------------------------------------

FamiToneSamplePlay:
	`FT_SwitchBank
	LDX #$01
	STX FT_DPCM_EFFECT

_FT2SamplePlay:
	ASL					;offset in the sample table
	ASL
	ADC FT_DPCM_LIST_L
	STA <FT_TEMP_PTR_L
	LDA #$00
	ADC FT_DPCM_LIST_H
	STA <FT_TEMP_PTR_H

	LDA #%00001111			;stop DPCM
	STA APU_SND_CHN

	LDY #$00
	LDA (FT_TEMP_PTR),y		;sample offset
	STA APU_DMC_START
	INY
	LDA (FT_TEMP_PTR),y		;sample length
	STA APU_DMC_LEN
	INY
	LDA (FT_TEMP_PTR),y		;pitch AND loop
	STA APU_DMC_FREQ

	LDA #$20				;reset DAC counter
	STA APU_DMC_RAW
	LDA #%00011111			;STArt DMC
	STA APU_SND_CHN

	RTS
	

;------------------------------------------------------------------------------
; init sound effects player, set pointer to data
; in: X,Y is address of sound effects data
;------------------------------------------------------------------------------

FamiToneSfxInit:
	`FT_SwitchBank
	LDA FT_PAL_ADJUST		;add 2 to the sound list pointer for PAL
	BNE _ntsc
	INX
	BNE _no_INC1
	INY
_no_INC1:
	INX
	BNE _ntsc
	INY
_ntsc:

	STX FT_SFX_ADR_L		;remember pointer to the data
	STY FT_SFX_ADR_H

	LDX #FT_SFX_CH0			;init all the streams

_set_channels:
	JSR _FT2SfxClearChannel
	TXA
	CLC
	ADC #FT_SFX_STRUCT_SIZE
	TAX
	CPX #FT_SFX_STRUCT_SIZE*FT_SFX_STREAMS
	BNE _set_channels

	RTS


;internal routine, clears output buffer of a sound effect
;in: A is 0
;    X is offset of sound effect stream

_FT2SfxClearChannel:

	LDA #$00
	STA FT_SFX_PTR_H,x		;this stops the effect
	STA FT_SFX_REPEAT,x
	STA FT_SFX_OFF,x
	STA FT_SFX_BUF+6,x		;mute triangle
	LDA #$30
	STA FT_SFX_BUF+0,x		;mute pulse1
	STA FT_SFX_BUF+3,x		;mute pulse2
	STA FT_SFX_BUF+9,x		;mute noise

	RTS


;------------------------------------------------------------------------------
; Play sound effect
; in: A is a number of the sound effect
;     X is offset of sound effect channel, should be FT_SFX_CH0..FT_SFX_CH3
;------------------------------------------------------------------------------

FamiToneSfxPlay:
	`FT_SwitchBank
	ASL					;get offset in the effects list
	ASL
	TAY

	JSR _FT2SfxClearChannel	;stops the effect if it plays

	LDA FT_SFX_ADR_L
	STA <FT_TEMP_PTR_L
	LDA FT_SFX_ADR_H
	STA <FT_TEMP_PTR_H

	LDA (FT_TEMP_PTR),y		;read effect pointer from the table
	STA FT_SFX_PTR_L,x		;store it
	INY
	LDA (FT_TEMP_PTR),y
	STA FT_SFX_PTR_H,x		;this enables the effect

	RTS


;internal routine, update one sound effect stream
;in: X is offset of sound effect stream

_FT2SfxUpdate:

	LDA FT_SFX_REPEAT,x		;check if repeat counter is not zero
	BEQ _no_repeat
	DEC FT_SFX_REPEAT,x		;DECrement AND return
	BNE _update_buf			;just mix with output buffer

_no_repeat:
	LDA FT_SFX_PTR_H,x		;check if MSB of the pointer is not zero
	BNE _sfx_active
	RTS						;return otherwise, no active effect

_sfx_active:
	STA <FT_TEMP_PTR_H		;load effect pointer into temp
	LDA FT_SFX_PTR_L,x
	STA <FT_TEMP_PTR_L
	LDY FT_SFX_OFF,x
	CLC

_read_byte:
	LDA (FT_TEMP_PTR),y		;read byte of effect
	BMI _get_data			;if bit 7 is set, it is a register write
	BEQ _eof
	INY
	STA FT_SFX_REPEAT,x		;if bit 7 is reset, it is number of repeats
	TYA
	STA FT_SFX_OFF,x
	JMP _update_buf

_get_data:
	INY
	STX <FT_TEMP_VAR1		;it is a register write
	ADC <FT_TEMP_VAR1		;get offset in the effect output buffer
	TAX
	LDA (FT_TEMP_PTR),y		;read value
	INY
	STA FT_SFX_BUF-128,x	;store into output buffer
	LDX <FT_TEMP_VAR1
	JMP _read_byte			;AND read next byte

_eof:
	STA FT_SFX_PTR_H,x		;mark channel as inactive

_update_buf:

	LDA FT_OUT_BUF			;compare effect output buffer with main output buffer
	AND #$0F				;if volume of pulse 1 of effect is higher than that of the
	STA <FT_TEMP_VAR1		;main buffer, overwrite the main buffer value with the new one
	LDA FT_SFX_BUF+0,x
	AND #$0F
	CMP <FT_TEMP_VAR1
	BCC _no_pulse1
	LDA FT_SFX_BUF+0,x
	STA FT_OUT_BUF+0
	LDA FT_SFX_BUF+1,x
	STA FT_OUT_BUF+1
	LDA FT_SFX_BUF+2,x
	STA FT_OUT_BUF+2
_no_pulse1:

	LDA FT_OUT_BUF+3		;same for pulse 2
	AND #$0F
	STA <FT_TEMP_VAR1
	LDA FT_SFX_BUF+3,x
	AND #$0F
	CMP <FT_TEMP_VAR1
	BCC _no_pulse2
	LDA FT_SFX_BUF+3,x
	STA FT_OUT_BUF+3
	LDA FT_SFX_BUF+4,x
	STA FT_OUT_BUF+4
	LDA FT_SFX_BUF+5,x
	STA FT_OUT_BUF+5
_no_pulse2:

	LDA FT_SFX_BUF+6,x		;overwrite triangle of main output buffer if it is active
	BEQ _no_triangle
	STA FT_OUT_BUF+6
	LDA FT_SFX_BUF+7,x
	STA FT_OUT_BUF+7
	LDA FT_SFX_BUF+8,x
	STA FT_OUT_BUF+8
_no_triangle:

	LDA FT_OUT_BUF+9		;same as for pulse 1 AND 2, but for noise
	AND #$0F
	STA <FT_TEMP_VAR1
	LDA FT_SFX_BUF+9,x
	AND #$0F
	CMP <FT_TEMP_VAR1
	BCC _no_noise
	LDA FT_SFX_BUF+9,x
	STA FT_OUT_BUF+9
	LDA FT_SFX_BUF+10,x
	STA FT_OUT_BUF+10
_no_noise:

	RTS


;dummy envelope used to initialize all channels with silence

_FT2DummyEnvelope:
	.byte $C0,$00,$00

;PAL AND NTSC, 11-bit dividers
;rest note, then octaves 1-5, then three zeroes
;first 64 bytes are PAL, next 64 bytes are NTSC

_FT2NoteTableLSB:
	.byte $00,$33,$DA,$86,$36,$EB,$A5,$62,$23,$E7,$AF,$7A,$48,$19,$EC,$C2
	.byte $9A,$75,$52,$30,$11,$F3,$D7,$BC,$A3,$8C,$75,$60,$4C,$3A,$28,$17
	.byte $08,$F9,$EB,$DD,$D1,$C5,$BA,$AF,$A5,$9C,$93,$8B,$83,$7C,$75,$6E
	.byte $68,$62,$5C,$57,$52,$4D,$49,$45,$41,$3D,$3A,$36,$33,$00,$00,$00
	.byte $00,$AD,$4D,$F2,$9D,$4C,$00,$B8,$74,$34,$F7,$BE,$88,$56,$26,$F8
	.byte $CE,$A5,$7F,$5B,$39,$19,$FB,$DE,$C3,$AA,$92,$7B,$66,$52,$3F,$2D
	.byte $1C,$0C,$FD,$EE,$E1,$D4,$C8,$BD,$B2,$A8,$9F,$96,$8D,$85,$7E,$76
	.byte $70,$69,$63,$5E,$58,$53,$4F,$4A,$46,$42,$3E,$3A,$37,$00,$00,$00
_FT2NoteTableMSB:
	.byte $00,$06,$05,$05,$05,$04,$04,$04,$04,$03,$03,$03,$03,$03,$02,$02
	.byte $02,$02,$02,$02,$02,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	.byte $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$06,$06,$05,$05,$05,$05,$04,$04,$04,$03,$03,$03,$03,$03,$02
	.byte $02,$02,$02,$02,$02,$02,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	.byte $01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00