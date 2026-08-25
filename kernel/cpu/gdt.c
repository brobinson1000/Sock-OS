#include <stdint.h>

// GDT entry structure
struct gdt_entry {
    uint16_t limit_low;
    uint16_t base_low;
    uint8_t  base_middle;
    uint8_t  access;
    uint8_t  granularity;
    uint8_t  base_high;
} __attribute__((packed));

// GDT pointer passed to lgdt
struct gdt_ptr {
    uint16_t limit;
    uint32_t base;
} __attribute__((packed));

struct gdt_entry gdt[3];
struct gdt_ptr gp;

void gdt_set_entry(int index, uint32_t base, uint32_t limit, uint8_t access, uint8_t gran) {
    gdt[index].base_low    = base & 0xFFFF;
    gdt[index].base_middle = (base >> 16) & 0xFF;
    gdt[index].base_high   = (base >> 24) & 0xFF;

    gdt[index].limit_low   = limit & 0xFFFF;
    gdt[index].granularity  = ((limit >> 16) & 0x0F) | (gran & 0xF0);

    gdt[index].access = access;
}

void gdt_install() {
    gp.limit = sizeof(gdt) - 1;
    gp.base  = (uint32_t)&gdt;

    // Null descriptor (index 0) - required
    gdt_set_entry(0, 0, 0, 0, 0);

    // Code segment (index 1) - selector 0x08
    //   access 0x9A = present, ring 0, code, readable
    //   gran   0xCF = 4KB granularity, 32-bit
    gdt_set_entry(1, 0, 0xFFFFFFFF, 0x9A, 0xCF);

    // Data segment (index 2) - selector 0x10
    //   access 0x92 = present, ring 0, data, writable
    //   gran   0xCF = 4KB granularity, 32-bit
    gdt_set_entry(2, 0, 0xFFFFFFFF, 0x92, 0xCF);

    // Load the GDT
    __asm__ __volatile__("lgdt (%0)" : : "r"(&gp));

    // Reload segment registers with new selectors
    __asm__ __volatile__(
        "ljmp $0x08, $1f\n"   
        "1:\n"
        "mov $0x10, %%ax\n"   
        "mov %%ax, %%ds\n"
        "mov %%ax, %%es\n"
        "mov %%ax, %%fs\n"
        "mov %%ax, %%gs\n"
        "mov %%ax, %%ss\n"
        : : : "ax"
    );
}
