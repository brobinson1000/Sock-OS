#include "kernel.h"

void kernel_main() {
    char* video = (char*)0xB8000;   // VGA text buffer
    const char* msg = "Hello World from SockOS";

    for (int i = 0; msg[i] != '\0'; i++) {
        video[i*2] = msg[i];       // character
        video[i*2+1] = 0x0F;      // color attribute: white on black
    }

    while(1) { }  // stop here so CPU doesn’t continue into garbage
}
