# Compile with nmake from a VS Dev Command Prompt
# Requires some basic posix utilities (sed, echo, cat)
# RunInBash aliased to `$` is required. WSL must be installed.

.PHONY: all

all: x86/msvcrt.lib x64/msvcrt.lib

GetFileVersionInfo.exe: GetFileVersionInfo/GetFileVersionInfo.c
	cl.exe -DUNICODE -W4 -D_UNICODE $? /link mincore.lib /out:$@

x64:
	mkdir x64

x86:
	mkdir x86

x64/msvcrt.exports: x64
	dumpbin.exe /EXPORTS C:\\Windows\\System32\\msvcrt.dll > x64/msvcrt.exports

x86/msvcrt.exports: x86
	dumpbin.exe /EXPORTS C:\\Windows\\syswow64\\msvcrt.dll > x86/msvcrt.exports

x64/msvcrt.funcs: x64/msvcrt.exports
	$$ sed -r "s/.*?(:?[A-F0-9]+ ){2}/\t/;tx;d;:x" ./x64/msvcrt.exports > ./x64/msvcrt.funcs

x86/msvcrt.funcs: x86/msvcrt.exports
	$$ sed -r "s/.*?(:?[A-F0-9]+ ){2}/\t/;tx;d;:x" ./x86/msvcrt.exports > ./x86/msvcrt.funcs

x64/msvcrt.def: x64/msvcrt.funcs
	echo EXPORTS > ./x64/msvcrt.def
	cat x64/msvcrt.funcs >> ./x64/msvcrt.def

x86/msvcrt.def: x86/msvcrt.funcs
	echo EXPORTS > x86/msvcrt.def
	cat x86/msvcrt.funcs >> x86/msvcrt.def

x64/msvcrt.lib: x64/msvcrt.def
	lib.exe /MACHINE:X64 /def:x64/msvcrt.def /out:x64/msvcrt.lib

x86/msvcrt.lib: x86/msvcrt.def
	lib.exe /MACHINE:X86 /def:x86/msvcrt.def /out:x86/msvcrt.lib

.PHONY: zip

version.txt: GetFileVersionInfo.exe x64/msvcrt.lib
	.\\GetFileVersionInfo.exe %windir%\\system32\\ntoskrnl.exe > version.txt

readme.txt: Makefile GetFileVersionInfo.exe
	$$ printf "msvcrt.lib by Mahmoud Al-Qudsi <mqudsi@neosmart.net>\r\nCopyright NeoSmart Technologies 2018\r\nhttps://github.com/neosmart/msvcrt.lib\r\n\r\nBuilt against Windows %%s and msvcrt.dll %%s\r\n" "$$(./GetFileVersionInfo.exe user32.dll | dos2unix)" "$$(./GetFileVersionInfo.exe msvcrt.dll | dos2unix)" > $@

zip: x86/msvcrt.lib x64/msvcrt.lib releases version.txt readme.txt
# get Windows version number
# ver.bat | grep -o -P "\d+.\d+.\d+" > version.txt
#   for /f does not support piping
	$$ zip ./msvcrt.zip ./readme.txt ./x86/msvcrt.lib ./x64/msvcrt.lib
	for /f "tokens=* USEBACKQ" %i IN (`cat version.txt`) DO ( \
		move msvcrt.zip releases/msvcrt_%i.zip \
	)

releases:
	mkdir -p ./releases

clean:
	rm -f *.exe
	rm -f *.exp
	rm -f *.obj
	rm -f *.zip
	rm -f version.txt
	rm -rf x64
	rm -rf x86
