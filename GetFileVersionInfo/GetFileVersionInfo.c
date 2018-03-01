#include <tchar.h>
#include <Windows.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#if !defined(UNICODE) || !defined(_UNICODE)
static_assert(0, "UNICODE/_UNICODE is not defined!");
#endif

int _tmain(int argc, const TCHAR *argv[]) {
    if (argc != 2 || _tcslen(argv[1]) == 0) {
        _tprintf(_T("Usage: GetFileVersionInfo.exe <PATH>\n"));
        return 1;
    }

    void *oldRedirectionState;
    Wow64DisableWow64FsRedirection(&oldRedirectionState);

    //In case %WINDIR% or similar was used:
    TCHAR target[MAX_PATH];
    ExpandEnvironmentStrings(argv[1], target, _countof(target) - 1);

    DWORD _ignore;
    DWORD vinfoSize = GetFileVersionInfoSizeEx(0 | FILE_VER_GET_NEUTRAL | FILE_VER_GET_LOCALISED, target, &_ignore);
    if (vinfoSize == 0) {
        uint32_t error = GetLastError();

        switch (error) {
        case ERROR_RESOURCE_DATA_NOT_FOUND:
        case ERROR_RESOURCE_TYPE_NOT_FOUND:
            _tprintf(_T("The selected binary does not contain a valid version info table!\n"));
            break;
        default:
            _tprintf(_T("Error retrieving file version info size for target %s: %d\n"),
                target, (int) GetLastError());
            break;
        }
        return GetLastError();
    }

    void *vinfo = malloc(vinfoSize);
    DWORD result = GetFileVersionInfoEx(0 | FILE_VER_GET_NEUTRAL | FILE_VER_GET_LOCALISED, target, _ignore, vinfoSize, vinfo);
    if (result == 0) {
        _tprintf(_T("GetFileVersionInfoEx failed against %s with error 0x%d\n"), target, (int) GetLastError());
        return GetLastError();
    }

    // Retrieve a list of valid localizations to query the version table against
    struct Translation {
        int16_t Language;
        int16_t Codepage;
    } *translations = NULL;
    uint32_t translationLength = 0;
    TCHAR blockBuffer[MAX_PATH];
    _tcscpy_s(blockBuffer, _countof(blockBuffer), _T("\\VarFileInfo\\Translation"));
    VerQueryValue(vinfo, blockBuffer, (LPVOID *) &translations, &translationLength);

    for (size_t i = 0; i < (translationLength / sizeof(struct Translation)); ++i) {
        TCHAR key[MAX_PATH] = { 0 };
        _stprintf_s(key, _countof(key), _T("\\StringFileInfo\\%04x%04x\\FileVersion"), translations[i].Language, translations[i].Codepage);

        const TCHAR *ffInfo = NULL;
        uint32_t ffiLength = 0;

        result = VerQueryValue(vinfo, key, (LPVOID *) &ffInfo, &ffiLength);
        if (result != TRUE) {
            //Possibly no FileVersion key for this language
            continue;
        }

        //This is a string of the format Maj.Maj.Min.Min and then some extra text
        uint32_t version[4] = {0};
        uint32_t *v = version;
        _stscanf_s(ffInfo, _T("%d.%d.%d.%d"), &v[0], &v[1], &v[2], &v[3]);

        /* _tprintf(_T("%s: "), ffInfo); */
        _tprintf(_T("%d.%d.%d.%d\n"), v[0], v[1], v[2], v[3]);
        return 0;
    }

    _tprintf(_T("The binary %s does not contain any valid FileVersion records."), target);
}
