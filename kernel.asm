; kernel_entry.asm
bits 32               ; 32-bit code
global start           ; linker entry
extern kmain           ; defined in C

start:
    ; Setup data segments
    mov ax, 0x10      ; data segment selector (from GDT)
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Setup stack
    mov esp, 0x90000

    ; Call C kernel main
    call kmain

hang:
    cli
    hlt
    jmp hang
