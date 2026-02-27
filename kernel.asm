[org 0x7E00]

; 16-bit entry section
bits 16

start:
    cli

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x9C00

    call enable_a20
    call load_gdt
    call enter_protected_mode

hang:
    jmp hang


; A20
enable_a20:
    in al, 0x92
    or al, 00000010b
    out 0x92, al
    ret


; GDT
gdt_start:
    dq 0x0000000000000000
    dq 0x00CF9A000000FFFF
    dq 0x00CF92000000FFFF
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

load_gdt:
    lgdt [gdt_descriptor]
    ret


; Enter Protected Mode
enter_protected_mode:
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 0x08:protected_mode_start


; 32-bit section
bits 32

protected_mode_start:

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov esp, 0x90000

    call kmain

halt:
    cli
    hlt
    jmp halt


kmain:
    mov edi, 0xB8000
    mov esi, message
    mov ah, 0x0F

.print:
    lodsb
    test al, al
    jz .done

    mov [edi], al
    inc edi
    mov [edi], ah
    inc edi

    jmp .print

.done:
    ret

message db "32-bit Kernel Active!",0
