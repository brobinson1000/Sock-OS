#include "idt.h"
#include "pic.h"
#include "screen.h"

static uint32_t tick = 0;

void timer_callback(registers_t* regs) {
    (void)regs;
    tick++;
}

uint32_t timer_ticks(void) { return tick; }

void timer_install(uint32_t hz) {
    uint32_t divisor = 1193180 / hz;
    outb(0x43, 0x36);                       /* channel 0, lo/hi, mode 3 */
    outb(0x40, divisor & 0xFF);
    outb(0x40, (divisor >> 8) & 0xFF);
}
