# Copyright (c) 2025-2026 Marleson Graf

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute,
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
# OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

PROJECT:=HexedUT2k4
TAG:=vDEV
OUTDIR:=build
TAGGEDPKGS:=HexedSRC HexedUT HexedVOTE HexedARENA HexedNET
UNTAGGEDPKGS:=HexedPatches
HELPFILES:=README.md LICENSE CHANGELOG.md
REQUIREDIRS:=System Textures Sounds StaticMeshes Animations
VERBOSITY:=success|export|error|warning

-include $(OUTDIR)/Config.make

ifndef INSTALLDIR
$(error You must specify 'INSTALLDIR' with the path to your UT2004 installation!\
Please run: `make configure INSTALLDIR=PATH/TO/UT2004`)
endif
ifneq ($(OS),Windows_NT)
WINEDEBUG:=-all
WINEPREFIX:=$(HOME)/.ucc-prefix
export WINEDEBUG
export WINEPREFIX
UCC:=wine UCC.exe
else
UCC:=UCC.exe
endif
MAKEFLAGS+=--no-builtin-rules --no-builtin-variables

pkgs:=$(TAGGEDPKGS:=$(TAG)) $(UNTAGGEDPKGS)
utdirs=$(REQUIREDIRS:%=$(OUTDIR)/%)
ufiles:=$(pkgs:%=$(OUTDIR)/System/%.u)
uz2files:=$(TAGGEDPKGS:%=$(OUTDIR)/%$(TAG).u.uz2)
inifiles:=$(pkgs:%=$(OUTDIR)/%.ini)
releasezip:=$(OUTDIR)/$(PROJECT)$(TAG).zip
toolsdir:=Tools
tagplaceholder:=%TAG%
pkgplaceholder:=%PKG%
inttemplate:=Template.int
getsrcs=$(wildcard $(OUTDIR)/$1/Classes/*.uc) $(wildcard $(OUTDIR)/$1/Classes/Include/*.uci)
getdeps=$(if $(NODEPS),,$($(1:$(TAG)=)_INTDEPS:%=$(OUTDIR)/System/%$(TAG).u))

.SECONDEXPANSION:
.ONESHELL:
.PHONY: all release configure clean distclean

all: $(ufiles) | $(OUTDIR)/System

release: $(releasezip)

configure: | $(OUTDIR)
	@echo "PROJECT:=$(PROJECT)" > $(OUTDIR)/Config.make
	echo "TAG:=$(TAG)" >> $(OUTDIR)/Config.make
	echo "INSTALLDIR:=$(INSTALLDIR)" >> $(OUTDIR)/Config.make
	echo "TAGGEDPKGS:=$(TAGGEDPKGS)" >> $(OUTDIR)/Config.make
	echo "UNTAGGEDPKGS:=$(UNTAGGEDPKGS)" >> $(OUTDIR)/Config.make
	echo "HELPFILES:=$(HELPFILES)" >> $(OUTDIR)/Config.make
	echo "REQUIREDIRS:=$(REQUIREDIRS)" >> $(OUTDIR)/Config.make
	echo "VERBOSITY:=$(VERBOSITY)" >> $(OUTDIR)/Config.make

clean:
	@rm -f $(ufiles) $(uz2files) $(ufiles:.u=.ucl) $(ufiles:.u=.int) $(releasezip)
	rm -rf $(OUTDIR)/Help

distclean: clean
	@rm -rf $(OUTDIR)

-include $(TAGGEDPKGS:=/Config.make) $(UNTAGGEDPKGS:=/Config.make)

$(pkgs): %: $(OUTDIR)/System/%.u

$(OUTDIR)/System/%.u: $(OUTDIR)/%.ini $$(call getsrcs,$$*) $$(call getdeps,$$*) | $(utdirs)
	@echo "[COMPILE] $* -> .u"
	mutators=$$(find $(OUTDIR)/$*/Classes/ -name "Mut*.uc")
	for m in $${mutators}; do
		sed -i -r "s/$(tagplaceholder)/$(TAG)/g" "$${m}"
	done
	work_dir=$$(pwd)
	cd $(OUTDIR)/System
	rm -f $*.u $*.ucl
	$(UCC) make -ini=../$*.ini -log=../$*.log -nohomedir | grep -Ei "$(VERBOSITY)"
	$(UCC) dumpint $*.u | grep -Ei "$(VERBOSITY)"
	if [ -f "../$*/$(inttemplate)" ]; then
		sed -r "s/$(pkgplaceholder)/$*/g" "../$*/$(inttemplate)" >> "$*.int";
	fi
	cd "$${work_dir}"
	for m in $${mutators}; do
		sed -i -r "s/$(TAG)/$(tagplaceholder)/g" "$${m}"
		touch -r "$(OUTDIR)/System/$*.u" "$${m}"
	done

$(inifiles): $(OUTDIR)/%.ini: $(OUTDIR)/%/Config.make
	@echo "[ SETUP ] $* -> .ini"
	echo "[Engine.Engine]" > $@
	echo "EditorEngine=Editor.EditorEngine" >> $@
	echo "" >> $@
	echo "[Core.System]" >> $@
	echo "SavePath=../Save" >> $@
	echo "CachePath=../Cache" >> $@
	echo "CacheExt=.uxx" >> $@
	echo "CacheRecordPath=../System/*.ucl" >> $@
	echo "MusicPath=../Music" >> $@
	echo "SpeechPath=../Speech" >> $@
	echo "Paths=../System/*.u" >> $@
	echo "Paths=../Maps/*.ut2" >> $@
	echo "Paths=../Textures/*.utx" >> $@
	echo "Paths=../Sounds/*.uax" >> $@
	echo "Paths=../Music/*.umx" >> $@
	echo "Paths=../StaticMeshes/*.usx" >> $@
	echo "Paths=../Animations/*.ukx" >> $@
	echo "Paths=../Saves/*.uvx" >> $@
	echo "" >> $@
	echo "[Editor.EditorEngine]" >> $@
	echo "EditPackages=Core" >> $@
	echo "EditPackages=Engine" >> $@
	for d in $($(*:$(TAG)=)_EXTDEPS) $($(*:$(TAG)=)_INTDEPS:=$(TAG)); do
		echo "EditPackages=$${d}" >> "$@"
	done
	echo "EditPackages=$*" >> "$@"

$(releasezip): $(ufiles) $(uz2files) $(HELPFILES:%=$(OUTDIR)/Help/$(PROJECT)$(TAG)-%)
	@echo "[RELEASE] $@"
	rm -f $@
	cd $(OUTDIR)
	files="$(^:$(OUTDIR)/%=%)"
	for p in $(pkgs); do
		if [ -f "System/$${p}.int" ]; then
			files="$${files} System/$${p}.int"
		fi
		if [ -f "System/$${p}.ucl" ]; then
			files="$${files} System/$${p}.ucl"
		fi
	done
	7z a -mmt=8 -mx=9 $(@F) $${files}

$(OUTDIR)/System/%.u.uz2: $(OUTDIR)/System/%.u
	@cd $(OUTDIR)/System
	$(UCC) compress $*.u

$(OUTDIR)/%.u.uz2: $(OUTDIR)/System/%.u.uz2
	@mv $(OUTDIR)/System/$*.u.uz2 $@

$(OUTDIR)/Help/$(PROJECT)$(TAG)-%: % | $(OUTDIR)/Help
	@cp $^ $@

$(OUTDIR) $(OUTDIR)/Help:
	@mkdir -p $@

$(OUTDIR)/%/Config.make: | $(OUTDIR)
	@ln -s ../$(*:$(TAG)=) $(OUTDIR)/$*

$(utdirs): $(OUTDIR)/%:
	@ln -s $(INSTALLDIR)/$* $@
