; LibKong Audio Code

  .alias AUDIO_NTSC               0
  .alias AUDIO_PAL                1
  .alias AUDIO_DENDY              2

  ; Arpeggio Type Indicators
  .alias ARP_ABSOLUTE             0
  .alias ARP_FIXED                1
  .alias ARP_RELATIVE             2

  ; Stream Flags
  .alias STREAM_ACTIVE_SET          %00000001
  .alias STREAM_ACTIVE_TEST         %00000001
  .alias STREAM_ACTIVE_CLEAR        %11111110

  .alias STREAM_SILENCE_SET         %00000010
  .alias STREAM_SILENCE_TEST        %00000010
  .alias STREAM_SILENCE_CLEAR       %11111101

  .alias STREAM_PAUSE_SET           %00000100
  .alias STREAM_PAUSE_TEST          %00000100
  .alias STREAM_PAUSE_CLEAR         %11111011

  .alias STREAM_PITCH_LOADED_SET    %00001000
  .alias STREAM_PITCH_LOADED_TEST   %00001000
  .alias STREAM_PITCH_LOADED_CLEAR  %11110111

  .alias DEFAULT_TEMPO              256 * 15

  .alias NTSC_HEADER_LOW_TEMPO      0
  .alias NTSC_HEADER_HIGH_TEMPO     1
  .alias PAL_HEADER_LOW_TEMPO       2
  .alias PAL_HEADER_HIGH_TEMPO      3

  .alias APUStatus                  $4015
    
  .alias Pulse1Timer                $4000
  .alias Pulse1Length               $4001
  .alias Pulse1Envelope             $4002
  .alias Pulse1Sweep                $4003
    
  .alias Pulse2Timer                $4004
  .alias Pulse2Length               $4005
  .alias Pulse2Envelope             $4006
  .alias Pulse2Sweep                $4007

    