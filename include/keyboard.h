#ifndef KEYBOARD_H
#define KEYBOARD_H

#include "idt.h"

void keyboard_callback(registers_t* regs);
int  kbd_has_char(void);
char kbd_getchar(void);
void kbd_flush(void);
#endif
