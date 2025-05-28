# Overiew

This repo is for documenting and duplicating an issue whereby `LibOVR.dll` stopped loading `LibOVRRT_32.dll` with
wine 9 and later releases. The culprit is likely that [_wintrust: Use CRT allocation function_
(6db69d0)](https://gitlab.winehq.org/wine/wine/-/commit/6db69d0) resulted in expanded memory areas not being
cleared (`realloc` does not clear expanded memory while `WINTRUST_ReAlloc` did).


# Issue details

That is, when running under in wine 8, after two calls to `WinVerifyTrust` returned succesful, `LibOVR.dll` loads
`LibOVRRT_32.dll`
```
..
Loading LibOVR.dll
0024:trace:loaddll:build_module Loaded L"Z:\\home\\tyson\\issue-wine-ovr\\LibOVR.dll" at 7ACD0000: native
Locating ovr_Initialize in LibOVR.dll
Calling ovr_Initialize
...
0024:trace:wintrust:WinVerifyTrust (FFFFFFFF, {00aac56b-cd44-11d0-8cc2-00c04fc295ee}, 0031EF94)
...
0024:trace:wintrust:WTHelperProvDataFromStateData 00346E28
0024:trace:wintrust:WTHelperGetProvSignerFromChain (00346E28 0 0 0)
0024:trace:wintrust:WTHelperGetProvSignerFromChain returning 00895F78
0024:trace:wintrust:WinVerifyTrust (FFFFFFFF, {00aac56b-cd44-11d0-8cc2-00c04fc295ee}, 0031EF94)
...
0024:trace:wintrust:WinVerifyTrust returning 00000000
0024:trace:loaddll:build_module Loaded L"C:\\windows\\system32\\opengl32.dll" at 79F80000: builtin
0024:trace:loaddll:build_module Loaded L"C:\\windows\\system32\\wined3d.dll" at 7A0B0000: builtin
0024:trace:loaddll:build_module Loaded L"C:\\windows\\system32\\dxgi.dll" at 7A3A0000: builtin
0024:trace:loaddll:build_module Loaded L"C:\\windows\\system32\\msacm32.dll" at 79EF0000: builtin
0024:trace:loaddll:build_module Loaded L"C:\\windows\\system32\\rpcrt4.dll" at 7B6B0000: builtin
0024:trace:loaddll:build_module Loaded L"C:\\windows\\system32\\combase.dll" at 7B9F0000: builtin
0024:trace:loaddll:build_module Loaded L"C:\\windows\\system32\\coml2.dll" at 7B660000: builtin
0024:trace:loaddll:build_module Loaded L"C:\\windows\\system32\\ole32.dll" at 7BA50000: builtin
0024:trace:loaddll:build_module Loaded L"C:\\windows\\system32\\WINMM.dll" at 79F20000: builtin
0024:trace:loaddll:build_module Loaded L"C:\\windows\\system32\\shcore.dll" at 7AD10000: builtin
0024:trace:loaddll:build_module Loaded L"C:\\windows\\system32\\shlwapi.dll" at 7AD40000: builtin
0024:trace:loaddll:build_module Loaded L"C:\\windows\\system32\\SHELL32.dll" at 7ADA0000: builtin
0024:trace:loaddll:build_module Loaded L"C:\\windows\\system32\\d3d11.dll" at 79E70000: builtin
0024:trace:loaddll:build_module Loaded L"Z:\\home\\tyson\\issue-wine-ovr\\LibOVRRT32_1.dll" at 7A3F0000: native
0024:trace:loaddll:build_module Loaded L"C:\\windows\\system32\\uxtheme.dll" at 7A7C0000: builtin
0024:trace:loaddll:build_module Loaded L"C:\\windows\\system32\\DbgHelp.dll" at 79DE0000: builtin
0024:fixme:dbghelp:elf_search_auxv can't find symbol in module
0140:trace:loaddll:build_module Loaded L"C:\\windows\\system32\\uxtheme.dll" at 7A7C0000: builtin
28/05 13:57:38.766 {INFO}    [Kernel:Default] [CAPI] LibOVR module is located at Z:\home\tyson\Revi
ve\Externals\Test\build\LibOVRRT32_1.dll
28/05 13:57:38.766 {INFO}    [Kernel:System] Graceful shutdown: OnThreadDestroy
28/05 13:57:38.766 {INFO}    [Kernel:System] Graceful shutdown: OnSystemDestroy
28/05 13:57:38.766 {INFO}    [Kernel:System] Graceful shutdown: Stopping logger
0024:fixme:dbghelp:elf_search_auxv can't find symbol in module
0024:trace:loaddll:free_modref Unloaded module L"Z:\\home\\tyson\\issue-wine-ovr\\LibOVRRT32_1.dll" : native
0024:trace:loaddll:free_modref Unloaded module L"C:\\windows\\system32\\d3d11.dll" : builtin
0024:trace:loaddll:free_modref Unloaded module L"C:\\windows\\system32\\SHELL32.dll" : builtin
0024:trace:loaddll:free_modref Unloaded module L"C:\\windows\\system32\\shlwapi.dll" : builtin
0024:trace:loaddll:free_modref Unloaded module L"C:\\windows\\system32\\shcore.dll" : builtin
0024:trace:loaddll:free_modref Unloaded module L"C:\\windows\\system32\\WINMM.dll" : builtin
0024:trace:loaddll:free_modref Unloaded module L"C:\\windows\\system32\\ole32.dll" : builtin
0024:trace:loaddll:free_modref Unloaded module L"C:\\windows\\system32\\coml2.dll" : builtin
0024:trace:loaddll:free_modref Unloaded module L"C:\\windows\\system32\\combase.dll" : builtin
0024:trace:loaddll:free_modref Unloaded module L"C:\\windows\\system32\\rpcrt4.dll" : builtin
0024:trace:loaddll:free_modref Unloaded module L"C:\\windows\\system32\\msacm32.dll" : builtin
0024:trace:loaddll:free_modref Unloaded module L"C:\\windows\\system32\\dxgi.dll" : builtin
0024:trace:loaddll:free_modref Unloaded module L"C:\\windows\\system32\\wined3d.dll" : builtin
0024:trace:loaddll:free_modref Unloaded module L"C:\\windows\\system32\\opengl32.dll" : builtin
ovr_Initialize(0) returned -3003
```

Under wine 9 and later, it now does an extra round of _WinVerifyTrust_ calls and then just returns without ever
loading _LibOVRRT_32.dll_
```
...
Loading LibOVR.dll
0024:trace:loaddll:build_module Loaded L"Z:\\home\\tyson\\issue-wine-ovr\\LibOVR.dll" at 7AC50000: native
Locating ovr_Initialize in LibOVR.dll
Calling ovr_Initialize
...
0024:trace:wintrust:WinVerifyTrust (FFFFFFFF, {00aac56b-cd44-11d0-8cc2-00c04fc295ee}, 0031EF94)
...
0024:trace:wintrust:WinVerifyTrust returning 00000000
0024:trace:wintrust:WTHelperProvDataFromStateData 00346E28
0024:trace:wintrust:WTHelperGetProvSignerFromChain (00346E28 0 0 0)
0024:trace:wintrust:WTHelperGetProvSignerFromChain returning 00897A58
0024:trace:wintrust:WinVerifyTrust (FFFFFFFF, {00aac56b-cd44-11d0-8cc2-00c04fc295ee}, 0031EF94)
...
0024:trace:wintrust:WinVerifyTrust returning 00000000
0024:trace:wintrust:WinVerifyTrust (FFFFFFFF, {00aac56b-cd44-11d0-8cc2-00c04fc295ee}, 0031EF94)
...
0024:trace:wintrust:WinVerifyTrust returning 00000000
0024:trace:wintrust:WTHelperProvDataFromStateData 008C4618
0024:trace:wintrust:WTHelperGetProvSignerFromChain (008C4618 0 0 0)
0024:trace:wintrust:WTHelperGetProvSignerFromChain returning 00909638
0024:trace:wintrust:WinVerifyTrust (FFFFFFFF, {00aac56b-cd44-11d0-8cc2-00c04fc295ee}, 0031EF94)
...
0024:trace:wintrust:WinVerifyTrust returning 00000000
ovr_Initialize(0) returned -3021
```


# Culprit details

It seems that something must have changed in the additional data returned by _WinVerifyTrust_.

The point at which things went bad was tracked down by bisecting all commits touching _dlls/wintrust_ since wine 8.
This identified [_wintrust: Use CRT allocation function_
(6db69d0)](https://gitlab.winehq.org/wine/wine/-/commit/6db69d0), and this was fully confirmed by reverting just
this commit in issolation in several later versions or wine, the most recent of which was 10.7.

The commit is basically just replacing Windows heap allocation calls with the equivalent
malloc/calloc/realloc/free calls, and looks to be pretty innocuous with respect to this issue.
A careful examination does reveal one critical difference though that could be the issue.
The original `WINTRUST_ReAlloc` function used `HEAP_ZERO_MEMORY`
```
static void* WINTRUST_ReAlloc(void *ptr, DWORD cb) __WINE_ALLOC_SIZE(2);
static void* WINTRUST_ReAlloc(void *ptr, DWORD cb)
{
    return HeapReAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, ptr, cb);
}
```
which causes Windows to zero any added memory. The replacement calls to realloc, for example
```
-    if (data->csSigners)
-        data->pasSigners = WINTRUST_ReAlloc(data->pasSigners,
-         (data->csSigners + 1) * sizeof(CRYPT_PROVIDER_SGNR));
-    else
-    {
-        data->pasSigners = WINTRUST_Alloc(sizeof(CRYPT_PROVIDER_SGNR));
-        data->csSigners = 0;
-    }
+    data->pasSigners = realloc(data->pasSigners,
+     (data->csSigners + 1) * sizeof(CRYPT_PROVIDER_SGNR));
```
will not be doing this. Likely this is introducing some garbage in a field and causing _LibOVR.dll_ to choke in its
verification process.


# Test

Included in this repo are the

* Oculus libraries `LibOVR.dll` and `LibOVRRT_32.dll`,
* a short Windows program `test.c` that loads `LibOVR.dll` to demonstrate the problem, and
* a conflict-resolved patch to revert commit 6db69d0 under wine 10.

Also includud is a nix expression for building both the test program (`nix build .#test`),
an unpatched (`nix shell .#wineStock`) and a patched (`nix shell .#winePatched`) 10.7 wine.
A typical test session might look like
```
nix build .#test -o test
export WINEPREFIX=$(mktemp -d)
nix shell .#winePatched
wineboot
WINEDEBUG=+loaddll,+wintrust wine test/bin/test.exe
exit
rm -fr $WINEPREFIX
unset WINEPREFIX
```
