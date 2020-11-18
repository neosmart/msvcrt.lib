# msvcrt.lib generator

`msvcrt.dll` is the generic C runtime library (aka "libc") on Microsoft Windows that has shipped
alongside Windows since Windows 95. Unlike other versions of the Microsoft C Runtime, this binary is
available on all end user machines and requires no preinstallation or dependency management
solution. _However, unlike versioned MSVCRT releases (such as `msvcrt71.dll`), `msvcrt.dll` does not
have a stable API and its exposed functions are not guaranteed backwards compatible by Microsoft._
As such, Microsoft - despite linking against this dll themselves for many of their applications -
does not provide the required library stub (`msvcrt.lib`) for developers to dynamically link against
`msvcrt.dll` for their own applications.

The `Makefile` in this repository will create a version of `msvcrt.lib` describing the API exposed
by the currently installed version of `msvcrt.dll`, allowing developers to link against the system
copy of `msvcrt.dll` instead of using a specific, versioned release of the MSVC runtime that
requires the installation of the VC redistributable package on consumer PCs before applications
linked against it can be used.

**Note: It is recommended to use the versioned C runtime when and where possible; this script is
only provided for the convenience of developers familiar with the pitfalls and caveats that come
with using the unversioned copy of `msvcrt.dll` and the minimal APIs it exposes!**

## Building msvcrt.lib

To build your own copy of `msvcrt.lib`, simply launch a copy of the Visual Studio Command Line Tools
and `cd` into the directory you checked out a copy of this repository into, then use the Microsoft
Makefile compiler (`nmake`) to build:

```batch
git clone https://github.com/neosmart/msvcrt.lib
cd msvcrt.lib
nmake all
```

Note that this script currently requires a working installation of the Windows Subsystem for Linux
(WSL) installed, and a copy of [`RunInBash`](https://github.com/neosmart/runinbash/) aliased to
`$.exe` to properly generate the `.lib` file. _There are no dependencies/requirements for the
resulting file, these are only "build dependencies."_

## Downloading msvcrt.lib

Builds of `msvcrt.lib` tagged against the version of Windows they were built on/against can be found
[on the Releases page](https://github.com/neosmart/msvcrt.lib/releases) of this repository.


## Other notes

* The 32-bit and 64-bit copies of `msvcrt.dll` are virtually identical, but this script generates a
  separate copy of `msvcrt.lib` of each for posterity's sake and out of an abundance of caution.
* Since the API of `msvcrt.dll` is not guaranteed, be sure to test your application thoroughly on
  all versions of Windows.
* If you do not need the zero-dependency, dynamically-linked binaries that come as a result of
  linking against the system `msvcrt.dll`, we do not recommend that you do so.

## License

The `msvcrt.lib` generation script and all utilities included in this repository are licensed under
the terms of the MIT Public License and can be freely redistributed accordingly. The `msvcrt.lib`
Makefile script and the `GetFileVersionInfo.exe` helper utility are developed and maintained by
Mahmoud Al-Qudsi <mqudsi@neosmart.net> of NeoSmart Technologies. This document and thes source code
in this repository Copyright NeoSmart Technologies, 2017-2020.
