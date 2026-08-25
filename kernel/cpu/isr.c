#include "idt.h"
#include "pic.h"
#include "screen.h"

static const char* exception_messages[32] = {
    "Division By Zero",
    "Debug",
    "Non Maskable Interrupt",
    "Breakpoint",
    "Overflow",
    "Bound Range Exceeded",
    "Invalid Opcode",
    "Device Not Available",
    "Double Fault",
    "Coprocessor Segment Overrun",
    "Invalid TSS",
    "Segment Not Present",
    "Stack-Segment Fault",
    "General Protection Fault",
    "Page Fault",
    "Reserved",
    "x87 Floating-Point Exception",
    "Alignment Check",
    "Machine Check",
    "SIMD Floating-Point Exception",
    "Virtualization Exception",
    "Control Protection Exception",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Reserved",
    "Hypervisor Injection Exception",
    "VMM Communication Exception",
    "Security Exception",
    "Reserved",
    "Reserved"
};

extern void timer_callback(registers_t* regs);
extern void keyboard_callback(registers_t* regs);

void isr_handler(registers_t* regs) {
    kprint("\nEXCEPTION: ");
    if (regs->int_no < 32)
        kprint(exception_messages[regs->int_no]);
    else
        kprint("Unknown");

    kprint("\n  int=");   kprint_hex(regs->int_no);
    kprint("  err=");     kprint_hex(regs->err_code);
    kprint("\n  eip=");   kprint_hex(regs->eip);
    kprint("  cs=");      kprint_hex(regs->cs);
    kprint("  eflags="); kprint_hex(regs->eflags);
    kprint("\n");

    for (;;) __asm__ __volatile__("cli; hlt");
}

void irq_handler(registers_t* regs) {
    switch (regs->int_no) {
        case 32: timer_callback(regs);    break;
        case 33: keyboard_callback(regs); break;
        default: break;
    }

    if (regs->int_no >= 40)
        outb(0xA0, 0x20);   /* EOI to slave */
    outb(0x20, 0x20);       /* EOI to master */
}
