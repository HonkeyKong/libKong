;Zero-Page allocation for libKong

.org $00
  .space  PPUSettings       1   ; PPU Config byte.
  .space  BlankTiles        1   ; Counter for blank tiles.
  .space  BlankRows         1   ; Counter for blank rows.
  .space  MapAddr           2   ; Address of tile map for bulk transfer.
  .space  StrAddr           2   ; Address of string in ROM for optimized rendering.
  .space  NTTmp             1   ; Temporary storage of upper byte for text rendering.
  .space  NTPtr             2   ; Address for NameTable Pointer.
  .space  TextOffset        2   ; Nametable offset for text rendering.
  .space  BGPtrLow          1   ; Low byte of BG Pointer for restoration.
  .space  BgPtr             2   ; Pointer to Background address.
  .space  AttrPtr           2   ; Pointer to Attribute address.
  .space  PPUAddress        2   ; PPU Offset for SetPPU subroutine.
  .space  PalAddr           2   ; Address of palette to load.
  .space  BankType          1   ; Type of bank to be switched
  .space  BankSlot          1   ; Which slot to be switched in.
  .space  BufferP1          1   ; Player 1 Input Buffer
  .space  ButtonsP1         1   ; Player 1 Button State
  .space  BufferP2          1   ; Player 2 Input Buffer
  .space  ButtonsP2         1   ; Player 2 Button State
  .space  BufferP3          1   ; Player 3 Input Buffer
  .space  ButtonsP3         1   ; Player 3 Button State
  .space  BufferP4          1   ; Player 4 Input Buffer
  .space  ButtonsP4         1   ; Player 4 Button State
  .space  BankControl       1   ; Index for Bank Control Register.
  .space  SpriteBank        1   ; Current Sprite Set Bank Number.
  .space  BGBank            1   ; Current Background Bank Number.
  .space  Port1Sig          1   ; Signature byte of port 1
  .space  Port2Sig          1   ; Signature byte of port 2
  .space  HasFourScore      1   ; Whether or not a 4-player adapter exists.
  
  ; These variables will probably be moved into a separate ZP header.

; Allocated to $24