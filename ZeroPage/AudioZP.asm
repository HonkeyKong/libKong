  .space  APUDisableUpdate      1   ; Disable per-frame updates for audio engine.
  .space  SoundRegion           1   ; I'll explain these when I figure them out.
  .space  SoundParamByte0       1
  .space  SoundParamByte1       1
  .space  SoundParamByte2       1
  .space  SoundLocalByte0       1
  .space  SoundLocalByte1       1
  .space  SoundLocalByte2       1
  .space  SoundParamWord0       2
  .space  SoundParamWord1       2
  .space  SoundParamWord2       2
  .space  SoundParamWord3       2
  .space  SoundLocalWord0       1
  .space  SoundLocalWord1       1
  .space  SoundLocalWord2       1

  .space  BaseInstrumentAddr    2
  .space  BaseNoteTableLow      2
  .space  BaseNoteTableHigh     2

  .space  BasePCMSampleTable    2
  .space  BasePCMNoteIndex      2
  .space  BasePCMSampleLength   2
  .space  BasePCMLoopPitchIndex 2

  .space  SongListAddress       2
  .space  SFXListAddress        2
  .space  SongAddress           2
  .space  APURegisters          20

  .space  APUDataReady          1
  .space  APUSquare1Old         1
  .space  APUSquare2Old         1

  .space  AudioPCMState         1

  .space  SoundStream           1
  .space  SoundChannel          1
  .space  StartingReadAddress   2
  .space  SoundCallbackAddress  2
  .space  SoundReadAddress      2