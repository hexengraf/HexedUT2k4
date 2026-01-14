# Copyright (c) 2025 Marleson Graf

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

project:=HexedUT2k4
packages:=HexedSRC HexedUT HexedPatches HexedUTComp
requiresint:=HexedSRC HexedUT HexedPatches HexedUTComp
requirescompressed:=HexedSRC HexedUT HexedUTComp
miscfiles:=README.md LICENSE

.outdir:=build
.versionfiles:=$(packages:%=$(.outdir)/%.make)

-include $(.versionfiles)

.projectversion:=v2.0
.packages:=$(foreach p,$(packages),$p$($p.version))
.intpackages:=$(foreach p,$(requiresint),$p$($p.version))
.compressedpackages:=$(foreach p,$(requirescompressed),$p$($p.version))
.archive:=$(.outdir)/$(project)$(.projectversion).zip
.miscfiles:=$(addprefix $(.outdir)/$(project)$(.projectversion)-, $(miscfiles))
.ufiles:=$(.packages:%=$(.outdir)/System/%.u)
.intfiles:=$(.intpackages:%=$(.outdir)/System/%.int)
.compressedfiles:=$(.compressedpackages:%=$(.outdir)/%.u.uz2)
.targets:=$(.ufiles) $(.intfiles)
.winecmd:=WINEPREFIX=~/.ucc-prefix wine
.findsources=$(wildcard $1/Classes/*.uc) $(wildcard $1/Classes/Include/*.uci)

$(foreach p,$(packages),$(if $($p.version),$(eval $p$($p.version).name:=$p)))
$(foreach p,$(packages),$(eval $p$($p.version).sources:=$p/make.ini $(call .findsources,$p)))

.SECONDEXPANSION:
.ONESHELL:
.PHONY: all compressed release clean distclean

all: $(.targets)

compressed: $(.compressedfiles)

release: $(.archive)

clean:
	@rm -rf $(.outdir)/System
	@rm -f $(.compressedfiles)
	@rm -f $(.archive)

distclean: clean
	@rm -rf $(.outdir)

$(.outdir)/System/%.u: $$($$*.sources)
	@mkdir -p $(@D)
	@$(if $($*.name),ln -s $($*.name) $*)
	@rm -f System/$*.{u,ucl}
	@cd System
	$(.winecmd) UCC.exe make -ini=../$*/make.ini
	@cd ../
	@$(if $($*.name),rm $*)
	@cp System/$*.u $(@D)
	@if [[ -f System/$*.ucl ]]; then cp System/$*.ucl $(@D); fi

$(.outdir)/System/%.int: $(.outdir)/System/%.u
	@mkdir -p $(@D)
	@rm -f System/$*.int
	@cd System
	$(.winecmd) UCC.exe dumpint $*.u
	@cd ../
	@cp System/$*.int $(@D)

$(.outdir)/%.u.uz2: $(.outdir)/System/%.u
	@rm -f System/$*.u.uz2
	@cd System
	$(.winecmd) UCC.exe compress $*.u
	@cd ../
	@cp System/$*.u.uz2 $(@D)

$(.outdir)/%.zip: $(.targets) $(.compressedfiles) $(.miscfiles)
	@rm -f $@
	@cd $(.outdir)
	@7z a -mmt=8 -mx=9 $(@F) System/ $(.compressedfiles:$(.outdir)/%=%) $(.miscfiles:$(.outdir)/%=%)

$(.outdir)/$(project)$(.projectversion)-%: %
	@cp $^ $@

$(.versionfiles): $(.outdir)/%.make: %/make.ini
	@mkdir -p $(@D)
	@sed -nr "s/.*=[ ]*$*([vV]?[.0-9]*[a-zA-Z]*)$$/$*.version:=\1/gp" $*/make.ini > $@
