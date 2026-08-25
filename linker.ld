ENTRY(start)

SECTIONS
{
    . = 0x7E00;

    .text : {
        *(.text.entry)      /* kernel.asm start must be first */
        *(.text*)
    }

    .rodata : { *(.rodata*) }
    .data   : { *(.data*)   }

    . = ALIGN(4);
    __bss_start = .;
    .bss : {
        *(COMMON)
        *(.bss*)
    }
    . = ALIGN(4);
    __bss_end = .;

    __kernel_end = .;
}
