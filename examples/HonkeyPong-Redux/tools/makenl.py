#!/usr/bin/python

# makenl.py - FCEUX Debug Map Generator
# Copyright 2016 Ryan D. Souders (HonkeyKong), All Rights Reserved.
# Generates FCEUX-compatible debug maps from map files,
# exported at assemble-time using the -m switch in Ophis, shown below.
# ophis sourcefile.oph -m sourcefile.map

import sys, os, re

class load():

	mapFile = None
	mapSrc = None
	ramRegex = re.compile('^\$0|^\$1|^\$2|^\$3|^\$4|^\$5|^\$6|^\$7')
	romRegex = re.compile('^\$8|^\$9|^\$A|^\$B|^\$C|^\$D|^\$E|^\$F')
	
	def __init__(self, fileName):
		self.mapFile = open(fileName, 'r')
		
	def writeNL(self):
		self.nlSrc = open("bin/%s.nes.0.nl".strip('.map') % self.mapFile.name, 'w')
		self.nlRamSrc = open("bin/%s.nes.ram.nl".strip('.map') % self.mapFile.name, 'w')
		for line in self.mapFile.readlines():
			if (not "*" in line): # discard anonymous labels, they'll only fuck things up.
				maplabel = line.split('|')
				if(self.ramRegex.match(maplabel[0])):
					self.nlRamSrc.write("%s#%s#%s" % (maplabel[0].strip(' '), maplabel[1].strip(' '), maplabel[2]))
				if(self.romRegex.match(maplabel[0])):
					self.nlSrc.write("%s#%s#%s" % (maplabel[0].strip(' '), maplabel[1].strip(' '), maplabel[2]))
		self.nlSrc.close()
		self.nlRamSrc.close()
		if(quietMode == False):
			print "Source map written to %s and %s" % (self.nlSrc.name, self.nlRamSrc.name)

	def __exit__(self):
		self.mapFile.close()
#end map class 

if __name__ == "__main__":

	quietMode = False

	if (len(sys.argv) < 2):
		print "Usage: makenl.py mapFile [options]"
		print "Generates FCEUX-compatible debug maps from exported label maps generated at assemble-time with '-m outputFile' switch."
		print "Options:"
		print "-q or --quiet: Suppresses log messages."

	elif (len(sys.argv) >= 2):
		for arg in sys.argv:
			if (arg == "--quiet") or (arg == "-q"):
				quietMode = True
		srcMap = load(sys.argv[1])
		srcMap.writeNL()
