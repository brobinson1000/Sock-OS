#ifndef MEM_H
#define MEM_H

#include <stdint.h>

void* memset(void* dest, int val, uint32_t len);
void* memcpy(void* dest, const void* src, uint32_t count);
int   memcmp(const void* a, const void* b, uint32_t count);
uint32_t strlen(const char* str);
int   strcmp(const char* a, const char* b);

#endif
