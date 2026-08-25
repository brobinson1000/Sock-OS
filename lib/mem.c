#include "mem.h"
void* memset(void* dest, int val, uint32_t count) {
    uint8_t* d = (uint8_t*)dest;
    for (uint32_t i = 0; i < count; i++) {
        d[i] = (uint8_t)val;
    }
    return dest;
}

void* memcpy(void* dest, const void* src, uint32_t count) {
    uint8_t* d = (uint8_t*)dest;
    const uint8_t* s = (const uint8_t*)src;
    for (uint32_t i = 0; i < count; i++) {
        d[i] = s[i];
    }
    return dest;
}

int memcmp(const void* a, const void* b, uint32_t count) {
    const uint8_t* pa = (const uint8_t*)a;
    const uint8_t* pb = (const uint8_t*)b;
    for (uint32_t i = 0; i < count; i++) {
        if (pa[i] != pb[i]) return pa[i] - pb[i];
    }
    return 0;
}

uint32_t strlen(const char* str) {
    uint32_t len = 0;
    while (str[len]) len++;
    return len;
}

int strcmp(const char* a, const char* b) {
    while (*a && *a == *b) { a++; b++; }
    return *(uint8_t*)a - *(uint8_t*)b;
}

char* strcpy(char* dest, const char* src) {
    char* d = dest;
    while ((*d++ = *src++));
    return dest;
}

