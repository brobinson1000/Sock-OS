#include "screen.h"
#include "gdt.h"
#include "idt.h"
#include "pic.h"
#include "shell.h"

extern void timer_install(uint32_t hz);

void kmain(void) {
    clear_screen();
    kprint("SockOS booting...\n");

    gdt_install();      /* GDT first: IDT gates reference selector 0x08 */
    idt_install();
    pic_remap();
    timer_install(100);

    kprint("Interrupts enabled. Type something.\n");
    __asm__ __volatile__("sti");

    shell_run();

    for (;;) __asm__ __volatile__("hlt");
}
