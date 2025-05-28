#include <windows.h>
#include <stdio.h>
#include <inttypes.h>

//__declspec(dllimport) int32_t __cdecl ovr_Initialize(const void* params);

typedef int32_t (__cdecl *Ovr_Initialize)(const void*);

int main() {
  HINSTANCE libOVR;
  Ovr_Initialize ovr_Initialize;
  int32_t result;

  
  printf("Loading LibOVR.dll\n");
  libOVR = LoadLibrary("LibOVR.dll");
  
  if (libOVR) {
    printf("Locating ovr_Initialize in LibOVR.dll\n");
    ovr_Initialize = (Ovr_Initialize)GetProcAddress(libOVR, "ovr_Initialize");

    if (ovr_Initialize) {
      printf("Calling ovr_Initialize\n");
      result = ovr_Initialize(0);
      printf("ovr_Initialize(0) returned %"PRId32"\n", result);
    }
    else
      printf("Failed to locate ovr_Initialize in LibOVR.dll\n");

    FreeLibrary(libOVR);
  }
  else
    printf("Failed to load LibOVR.dll\n");
    
  return 0;
}
