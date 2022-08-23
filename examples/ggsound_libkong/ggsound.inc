;Comment out these equates for features you do not wish to use.
.alias FEATURE_DPCM 1
.alias FEATURE_ARPEGGIOS 1

;ifdef FEATURE_DPCM
.alias DPCM_STATE_NOP 0
.alias DPCM_STATE_UPLOAD 1
.alias DPCM_STATE_UPLOAD_THEN_WAIT 2
.alias DPCM_STATE_WAIT 3
;endif

;Max number of music streams, sfx streams, and max total streams
;based on whether dpcm is enabled. soundeffect_one and soundeffect_two
;are always to be used when specifying sound effect priority.
;ifdef FEATURE_DPCM
.alias MAX_MUSIC_STREAMS 5
.alias soundeffect_one 5
.alias soundeffect_two 6
;else
;MAX_MUSIC_STREAMS 4
;soundeffect_one 4
;soundeffect_two 5
;endif
.alias MAX_SFX_STREAMS 2
.alias MAX_STREAMS 7; MAX_MUSIC_STREAMS+MAX_SFX_STREAMS

;****************************************************************
;The following are all opcodes. All opcodes in range 0-86 are
;interpreted as a note playback call. Everything 87 or above
;are interpreted as stream control opcodes.
;****************************************************************

.alias C0  0
.alias CS0 1
.alias D0  2
.alias DS0 3
.alias E0  4
.alias F0  5
.alias FS0 6
.alias G0  7
.alias GS0 8
.alias A0  9
.alias AS0 10
.alias B0  11
.alias C1  12
.alias CS1 13
.alias D1  14
.alias DS1 15
.alias E1  16
.alias F1  17
.alias FS1 18
.alias G1  19
.alias GS1 20
.alias A1  21
.alias AS1 22
.alias B1  23
.alias C2  24
.alias CS2 25
.alias D2  26
.alias DS2 27
.alias E2  28
.alias F2  29
.alias FS2 30
.alias G2  31
.alias GS2 32
.alias A2  33
.alias AS2 34
.alias B2  35
.alias C3  36
.alias CS3 37
.alias D3  38
.alias DS3 39
.alias E3  40
.alias F3  41
.alias FS3 42
.alias G3  43
.alias GS3 44
.alias A3  45
.alias AS3 46
.alias B3  47
.alias C4  48
.alias CS4 49
.alias D4  50
.alias DS4 51
.alias E4  52
.alias F4  53
.alias FS4 54
.alias G4  55
.alias GS4 56
.alias A4  57
.alias AS4 58
.alias B4  59
.alias C5  60
.alias CS5 61
.alias D5  62
.alias DS5 63
.alias E5  64
.alias F5  65
.alias FS5 66
.alias G5  67
.alias GS5 68
.alias A5  69
.alias AS5 70
.alias B5  71
.alias C6  72
.alias CS6 73
.alias D6  74
.alias DS6 75
.alias E6  76
.alias F6  77
.alias FS6 78
.alias G6  79
.alias GS6 80
.alias A6  81
.alias AS6 82
.alias B6  83
.alias C7  84
.alias CS7 85
.alias D7  86
.alias DS7 87
.alias E7  88
.alias F7  89
.alias FS7 90
.alias G7  91
.alias GS7 92
.alias A7  93
.alias AS7 94
.alias B7  95

.alias HIGHEST_NOTE B7

.alias OPCODES_BASE 96

;stream control opcodes

;set length opcodes for standard note lengths
.alias SL1 0  + OPCODES_BASE
.alias SL2 1  + OPCODES_BASE
.alias SL3 2  + OPCODES_BASE
.alias SL4 3  + OPCODES_BASE
.alias SL5 4  + OPCODES_BASE
.alias SL6 5  + OPCODES_BASE
.alias SL7 6  + OPCODES_BASE
.alias SL8 7  + OPCODES_BASE
.alias SL9 8  + OPCODES_BASE
.alias SLA 9  + OPCODES_BASE
.alias SLB 10 + OPCODES_BASE
.alias SLC 11 + OPCODES_BASE
.alias SLD 12 + OPCODES_BASE
.alias SLE 13 + OPCODES_BASE
.alias SLF 14 + OPCODES_BASE
.alias SL0 15 + OPCODES_BASE

;set length lo byte
.alias SLL 16+OPCODES_BASE

;set length hi byte
.alias SLH 17+OPCODES_BASE

;set instrument
.alias STI 18+OPCODES_BASE

;goto
.alias GOT 19+OPCODES_BASE

;call
.alias CAL 20+OPCODES_BASE

;return
.alias RET 21+OPCODES_BASE

;terminate
.alias TRM 22+OPCODES_BASE

;ifdef FEATURE_ARPEGGIOS
;set arpeggio envelope
.alias SAR 25+OPCODES_BASE
;endif

;opcodes read from volume and pitch envelopes. These values are also
;reserved by Famitracker, so they are safe to use.
.alias ENV_STOP %10000000 ;-128
.alias ENV_LOOP %01111111 ; 127

;a different set of opcodes for stop and loop for duty cycle envelopes.
;This is necessary since ENV_STOP can be intepreted as duty cycle 2,
;preventing users from using that setting.
.alias DUTY_ENV_STOP %00111111
.alias DUTY_ENV_LOOP %00101010

;these opcodes exist at the start of any arpeggio envelope to indicate
;how the arpeggio is to be executed.
.alias ARP_TYPE_ABSOLUTE 0
.alias ARP_TYPE_FIXED    1
.alias ARP_TYPE_RELATIVE 2

;values for stream flags
.alias STREAM_ACTIVE_SET         %00000001
.alias STREAM_ACTIVE_TEST        %00000001
.alias STREAM_ACTIVE_CLEAR       %11111110

.alias STREAM_SILENCE_SET        %00000010
.alias STREAM_SILENCE_TEST       %00000010
.alias STREAM_SILENCE_CLEAR      %11111101

.alias STREAM_PAUSE_SET          %00000100
.alias STREAM_PAUSE_TEST         %00000100
.alias STREAM_PAUSE_CLEAR        %11111011

.alias STREAM_PITCH_LOADED_SET   %00001000
.alias STREAM_PITCH_LOADED_TEST  %00001000
.alias STREAM_PITCH_LOADED_CLEAR %11110111

;default tempo.
.alias DEFAULT_TEMPO 256 * 15

;Region constants.
.alias SOUND_REGION_NTSC 0
.alias SOUND_REGION_PAL  1
.alias SOUND_REGION_DENDY 2

.alias track_header_ntsc_tempo_lo            0
.alias track_header_ntsc_tempo_hi            1
.alias track_header_pal_tempo_lo             2
.alias track_header_pal_tempo_hi             3
.alias track_header_square1_stream_address   4
.alias track_header_square2_stream_address   6
.alias track_header_triangle_stream_address  8
.alias track_header_noise_stream_address     10
;ifdef FEATURE_DPCM
.alias track_header_dpcm_stream_address      12
;endif

.alias instrument_header_volume_offset 0
.alias instrument_header_pitch_offset 1
.alias instrument_header_duty_offset 2
.alias instrument_header_arpeggio_offset 3
.alias instrument_header_arpeggio_type 4

.macro advance_stream_read_address

    inc stream_read_address_lo,x
    bne _endm
    inc stream_read_address_hi,x
    _endm:

.macend

;this macro updates the sound engine. It is intended to
;be used at the end of an nmi routine, after ppu synchronization.
.macro soundengine_update

    lda sound_disable_update
    bne _endm

    jsr sound_update
    jsr sound_upload

_endm:

.macend
