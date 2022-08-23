ifeq ($(OS),Windows_NT)
	TXT_TARGET=tools/text2data.exe
	NSF_TARGET=tools/nsf2data.exe
else
	TXT_TARGET=tools/text2data
	NSF_TARGET=tools/nsf2data
endif

TARGET=bin/HonkeyPong-Redux.nes

SOURCES=../../KongSetup.asm \
		../../Video/KongPPU.asm \
		../../Video/KongRender.asm \
		../../Input/KongInput.asm \
		src/sprites.asm \
		src/engine.asm \
		src/famitone2.asm \
		$(MUSIC_ASM) \
		src/main.asm

MUSIC_SRC=res/snd/ReduxSoundtrack.txt

MUSIC_ASM=res/snd/ReduxSoundtrack.oph

SOUND_SRC=res/snd/Sounds.nsf

SOUND_ASM=res/snd/Sounds.oph

TXT_SRC=src/text2data.cpp

NSF_SRC=src/nsf2data.cpp

MAIN_SRC=HonkeyPong-Redux_iNES.oph

SRC_MAP=HonkeyPong-Redux_Debug.map

BINARIES=$(SRC_MAP) \
		$(TARGET) \
		$(TARGET).PRG \
		$(TARGET).CHR \
		$(TARGET).PRG.bin \
		$(TARGET).CHR.bin

CXX=g++

all: soundtools sound rom

rom: $(TARGET)

$(TARGET): $(SOURCES)
	@echo Assembling iNES ROM...
	@mkdir -p bin
	@ophis -o $@ $(MAIN_SRC)

debugrom: $(SOURCES)
	@echo Assembling iNES ROM with debug info...
	@mkdir -p bin
	@ophis -o $(TARGET) $(MAIN_SRC) -m $(SRC_MAP)

debug: debugrom
	@echo Loading debugger...
	@fceux $(TARGET)

soundtools: $(SND_SRC)
	@echo Building text2data...
	@$(CXX) -o $(TXT_TARGET) $(TXT_SRC)
	@echo Building nsf2data...
	@$(CXX) -o $(NSF_TARGET) $(NSF_SRC)

.PHONY: sound
sound: $(MUSIC_SRC)
	@echo Generating music data...
	@$(TXT_TARGET) $(MUSIC_SRC) -ophis -v
	@echo Generating sound data...
	@$(NSF_TARGET) $(SOUND_SRC) -ophis

.PHONY: clean-sound
clean-sound:
	@echo Cleaning music...
	@rm -f $(MUSIC_ASM)
	@echo Cleaning sound...
	@rm -f $(SOUND_ASM)

.PHONY: clean-soundtools
clean-soundtools:
	@echo Cleaning sound tools...
	@rm -f $(TXT_TARGET) $(NSF_TARGET)

.PHONY: cartridge
cartridge: rom
	@echo Preparing cartridge ROMs...
	@python tools/nesprep.py $(TARGET) -splitPRG -splitCHR -quiet

.PHONY: test
test: rom
	@echo Loading emulator...
	@Nestopia $(TARGET)

.PHONY: clean
clean:
	@echo Cleaning ROM...
	@rm -f $(BINARIES)

.PHONY: clean-all
clean-all: clean clean-sound clean-soundtools