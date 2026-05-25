#include "screen.h"

void yes(const char* str) {
    for(;;) {
        kprint(str);
        kprint("\n");
    }
}

