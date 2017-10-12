.PHONY: all

all: x86/msvcrt.lib x64/msvcrt.lib

x64/msvcrt.exports: x64
	dumpbin.exe /EXPORTS C:\\Windows\\System32\\msvcrt.dll > x64/msvcrt.exports

x86/msvcrt.exports: x86
	dumpbin.exe /EXPORTS C:\\Windows\\syswow64\\msvcrt.dll > x86/msvcrt.exports

x64/msvcrt.funcs: x64/msvcrt.exports x64
	sed -r "s/.*?(:?[A-F0-9]+ ){2}/\t/;tx;d;:x" ./x64/msvcrt.exports > ./x64/msvcrt.funcs

x86/msvcrt.funcs: x86/msvcrt.exports x86
	sed -r "s/.*?(:?[A-F0-9]+ ){2}/\t/;tx;d;:x" ./x86/msvcrt.exports > ./x86/msvcrt.funcs

x64/msvcrt.def: x64/msvcrt.funcs x64
	echo EXPORTS > ./x64/msvcrt.def
	cat x64/msvcrt.funcs >> ./x64/msvcrt.def

x86/msvcrt.def: x86/msvcrt.funcs
	echo EXPORTS > x86/msvcrt.def
	cat x86/msvcrt.funcs >> x86/msvcrt.def

x64:
	mkdir x64

x86:
	mkdir x86

x64/msvcrt.lib: x64/msvcrt.def x64 x64
	lib /MACHINE:X64 /def:x64/msvcrt.def /out:x64/msvcrt.lib

x86/msvcrt.lib: x86/msvcrt.def x86
	lib /MACHINE:X86 /def:x86/msvcrt.def /out:x86/msvcrt.lib

clean:
	rm -f *.exp
	rm -rf x86
	rm -rf x64
