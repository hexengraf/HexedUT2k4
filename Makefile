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

packages:=HexedUT HexedGUI HexedUTComp

.outdir:=build
.versionfiles:=$(packages:%=$(.outdir)/%.make)

-include $(.versionfiles)

.versionedpackages:=$(foreach p,$(packages),$p$($p.version))
.archives:=$(.versionedpackages:%=$(.outdir)/%.7z)
.ufiles:=$(.versionedpackages:%=$(.outdir)/System/%.u)
.uclfiles:=$(.versionedpackages:%=$(.outdir)/System/%.ucl)
.intfiles:=$(.versionedpackages:%=$(.outdir)/System/%.int)
.compressedfiles:=$(.ufiles:%=%.uz2)
.targets:=$(.ufiles) $(.intfiles)
.outputfiles:=$(.compressedfiles) $(.ufiles) $(.uclfiles) $(.intfiles)

$(foreach p,$(packages),$(if $($p.version),$(eval $p$($p.version).name:=$p)))
$(foreach p,$(packages),$(eval $p$($p.version).deps:=$p/make.ini $(wildcard $p/Classes/*.uc)))

.SECONDEXPANSION:
.ONESHELL:
.PHONY: all compressed release clean distclean

all: $(.targets)

compressed: $(.compressedfiles)

release: $(.archives)

clean:
	@rm -rf $(.outdir)/System
	@rm -f $(.outputfiles:$(.outdir)/%=%)
	@rm -f $(.archives)

distclean: clean
	@rm -rf $(.outdir)

$(.outdir)/System/%.u: $$($$*.deps)
	@mkdir -p $(@D)
	@$(if $($*.name),ln -s $($*.name) $*)
	@rm -f System/$*.{u,ucl}
	@cd System
	wine UCC.exe make -ini=../$*/make.ini
	@cd ../
	@$(if $($*.name),rm $*)
	@cp System/$*.u $(@D)
	@if [[ -f System/$*.ucl ]]; then cp System/$*.ucl $(@D); fi

$(.outdir)/System/%.int: $(.outdir)/System/%.u
	@mkdir -p $(@D)
	@rm -f System/$*.int
	@cd System
	wine UCC.exe dumpint $*.u
	@cd ../
	@cp System/$*.int $(@D)

$(.outdir)/System/%.u.uz2: $(.outdir)/System/%.u
	@rm -f System/$*.u.uz2
	@cd System
	wine UCC.exe compress $*.u
	@cd ../
	@cp System/$*.u.uz2 $(@D)

$(.outdir)/%.7z: $(.outdir)/System/%.u.uz2
	@rm -f $@
	@7z a -m0=lzma2 -mmt=8 -mx=9 $@ System/$*.*

$(.versionfiles): $(.outdir)/%.make: %/make.ini
	@mkdir -p $(@D)
	@sed -nr "s/.*=[ ]*$*([vV]?[.0-9]*[a-zA-Z]?)$$/$*.version:=\1/gp" $*/make.ini > $@
