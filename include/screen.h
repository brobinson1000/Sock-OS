#ifndef SCREEN_H
#define SCREEN_H

#include <stdint.h>

void clear_screen(void);
void kprint(const char* str);
void kprint_hex(uint32_t n);
void kdelete(void);
void ktab(void);
void kprint_newline();
#endif
