; kernel_entry.asm
bits 32
global start
extern kmain
extern __bss_start
extern __bss_end

section .text.entry
start:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov esp, 0x90000

    ; Zero .bss -- it occupies no space in the disk image, so nobody
    ; else has cleared it. Globals like idt[256] live here.
    mov edi, __bss_start
    mov ecx, __bss_end
    sub ecx, edi
    xor eax, eax
    rep stosb

    call kmain

hang:
    cli
    hlt
    jmp hang
