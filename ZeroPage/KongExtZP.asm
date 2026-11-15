; Extended zero-page allocation for libKong's newer modules:
;
;   Video/KongFrame.asm        (frame sync, rendering on/off)
;   Video/KongVRAMBuffer.asm   (NMI-time VRAM update queue)
;   Video/KongSprites.asm      (OAM helpers, metasprites)
;   Input/KongInputEdge.asm    (newly-pressed buttons)
;   Math/KongMath.asm          (random numbers, decimal digits)
;
; Include this directly after ZeroPage/MainZP.asm, inside your .data
; segment. MainZP ends at $2C, and this continues from there to $42,
; so start your own zero-page variables at $48 or higher.

  .space  PPUMaskSettings   1   ; Shadow of PPUControl2 ($2001)
  .space  FrameCount        1   ; Bumped once per frame by your NMI handler
  .space  PressedP1         1   ; Buttons that went down this frame, player 1
  .space  PressedP2         1   ; Buttons that went down this frame, player 2
  .space  VRAMBufIdx        1   ; Write index into the VRAM update buffer
  .space  OAMIndex          1   ; Next free byte in the OAM shadow
  .space  MSprPtr           2   ; Metasprite definition pointer
  .space  MSprX             2   ; Metasprite anchor X (16-bit, signed)
  .space  MSprY             2   ; Metasprite anchor Y (16-bit, signed)
  .space  MSprAttr          1   ; EORed into every sprite's attribute byte
  .space  MSprFlip          1   ; $40 = mirror the metasprite horizontally
  .space  MSprClipTop       1   ; Sprites above this scanline are skipped
  .space  MSprTmp           2   ; Scratch for DrawMetaSprite
  .space  RandSeed          2   ; KongRandom state; must never be all zero
  .space  KongDigits        3   ; KongByteToDigits output: hundreds, tens, ones

; Allocated to $42
