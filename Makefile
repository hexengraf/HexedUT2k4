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

packages:=HexedUT

.sysdir:=System
.ufiles:=$(packages:%=$(.sysdir)/%.u)
.uclfiles:=$(packages:%=$(.sysdir)/%.ucl)
.intfiles:=$(packages:%=$(.sysdir)/%.int)
.compressedfiles:=$(.ufiles:%=%.uz2)
.targets:=$(.ufiles) $(.uclfiles) $(.intfiles)

$(foreach p,$(packages),$(eval $p.sources:=$(wildcard $p/Classes/*.uc)))

.SECONDEXPANSION:
.ONESHELL:
.PHONY: all compressed clean

all: $(.targets)

$(.sysdir)/%.u $(.sysdir)/%.ucl: $$($$*.sources)
	rm -f $@
	cd System
	wine UCC.exe make -ini=../$*/make.ini

$(.sysdir)/%.int: $(.sysdir)/%.u
	rm -f $@
	cd System
	wine UCC.exe dumpint $*.u

$(.sysdir)/%.uz2: $(.sysdir)/%
	cd System
	wine UCC.exe compress $*

compressed: $(.compressedfiles)

clean:
	rm -f $(.targets) $(.compressedfiles)
