; LibKong Audio Functions
; Inspired by GGSound/Gradual Sound

InitSound:
  LDA #$01
  STA APUDisableUpdate

  LDA SoundParamByte0
  STA SoundRegion

  ; Set Song List Address.
  LDA SoundParamWord0
  STA SongListAddress
  LDA SoundParamWord0+1
  STA SongListAddress+1

  ; Get SFX Address.
  LDA SoundParamWord1
  STA SFXListAddress
  LDA SoundParamWord1+1
  STA SFXListAddress+1

  ; Get Instrument Address.
  LDA SoundParamWord2
  STA BaseInstrumentAddr
  LDA SoundParamWord2+1
  STA BaseInstrumentAddr+1

  ; Get PCM Samples.
  LDY #$00
  LDA (SoundParamWord3), Y
  STA BasePCMSampleTable
  INY
  LDA (SoundParamWord3), Y
  STA BasePCMSampleTable+1

  ; Get PCM to Sample Index Table.
  INY
  LDA (SoundParamWord3), Y
  STA BasePCMNoteIndex
  INY
  LDA (SoundParamWord3, Y)
  STA BasePCMNoteIndex+1

  ; Get PCM Sample Length Table.
  INY
  LDA (SoundParamWord3), Y
  STA BasePCMSampleLength
  INY
  LDA (SoundParamWord3), Y
  STA BasePCMSampleLength+1

  ; Get PCM Pitch Index Table.
  INY
  LDA (SoundParamWord3), Y
  STA BasePCMLoopPitchIndex
  INY
  LDA (SoundParamWord3), Y
  STA BasePCMLoopPitchIndex+1

  ; Set Audio Region.
  
