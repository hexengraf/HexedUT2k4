.POSIX:
.SUFFIXES:

#
# REQUIRED
#
# Specifying UT2004 installation path is required:
# $ UT2004="C:/Users/user/Downloads/UT2004" make
# or:
# $ export UT2004="C:/Users/user/Downloads/UT2004"
# $ make
#
# Specifying UCC is optional:
# $ UCC=".winecmd:=WINEDEBUG=-all WINEPREFIX=~/.ucc-prefix wine" make
#
# Because of ucc limitations this makefile builds in the System folder
# of UT2004:
# all      Build packages in the UT2004 System folder. Start the game
#          after building to test them
# release  Copy the build output from the UT2004 System folder to the
#          temporary packaging folder and zip it
# clean    Remove build output in the UT2004 System folder and the
#          temporary packaging folder
#

VER = v9rc5
OUT = $(PWD)/build
SYS = $(UT2004)/System
ZIP = 7z a -mmt=8 -mx=9

.SILENT: all release clean UT2004
.PHONY: all release clean UT2004

UT2004:
	./make.sh check

all: \
	$(SYS)/HexedSRC$(VER).u \
	$(SYS)/HexedUT$(VER).u \
	$(SYS)/HexedVOTE$(VER).u \
	$(SYS)/HexedARENA$(VER).u \
	$(SYS)/HexedNET$(VER).u \
	$(SYS)/HexedPatches.u

release: all README.md LICENSE CHANGELOG.md
	mkdir -p "$(OUT)" "$(OUT)"/System "$(OUT)"/Help
	./make.sh extract "HexedSRC HexedUT HexedVOTE HexedARENA HexedNET HexedPatches" "$(OUT)"/System "$(SYS)" "$(UCC)"
	./make.sh compress "HexedSRC HexedUT HexedVOTE HexedARENA HexedNET" "$(OUT)" "$(SYS)" "$(UCC)"
	cp -f README.md    "$(OUT)"/Help/HexedUT2k4"$(VER)"-README.md
	cp -f LICENSE      "$(OUT)"/Help/HexedUT2k4"$(VER)"-LICENSE
	cp -f CHANGELOG.md "$(OUT)"/Help/HexedUT2k4"$(VER)"-CHANGELOG.md
	$(ZIP) HexedUT2k4"$(VER)".zip "$(OUT)"/*

clean:
	rm -f "$(UT2004)"/Hexed* # Remove symlinks
	rm -f "$(SYS)"/Hexed* # Remove compiled packages (.u .ucl .int)
	rm -f "$(SYS)"/ucc*.log "$(SYS)"/StdOut*.log # Remove logs
	rm -f -r "$(OUT)" # Remove build directory

$(SYS)/HexedSRC$(VER).u: HexedSRC/make.ini HexedSRC/Classes/*.uc HexedSRC/Classes/Include/*.uci
	@./make.sh build HexedSRC "$(SYS)" "$(UCC)"

$(SYS)/HexedUT$(VER).u: $(SYS)/HexedSRC$(VER).u HexedUT/make.ini HexedUT/Classes/*.uc
	@./make.sh build HexedUT "$(SYS)" "$(UCC)"

$(SYS)/HexedVOTE$(VER).u: $(SYS)/HexedSRC$(VER).u HexedVOTE/make.ini HexedVOTE/Classes/*.uc
	@./make.sh build HexedVOTE "$(SYS)" "$(UCC)"

$(SYS)/HexedARENA$(VER).u: $(SYS)/HexedSRC$(VER).u HexedARENA/make.ini HexedARENA/Classes/*.uc
	@./make.sh build HexedARENA "$(SYS)" "$(UCC)"

$(SYS)/HexedNET$(VER).u: $(SYS)/HexedSRC$(VER).u HexedNET/make.ini HexedNET/Classes/*.uc
	@./make.sh build HexedNET "$(SYS)" "$(UCC)"

$(SYS)/HexedPatches.u: $(SYS)/HexedSRC$(VER).u HexedPatches/make.ini HexedPatches/Classes/*.uc HexedPatches/Classes/Include/*.uci
	@./make.sh build HexedPatches "$(SYS)" "$(UCC)"
