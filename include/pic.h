#ifndef PIC_H
#define PIC_H

#include <stdint.h>

void pic_remap();
void outb(uint16_t port, uint8_t value);
uint8_t inb(uint16_t port);

#endif
