[BITS 16]        ; Set the code to 16-bit mode
[ORG 0x7c00]     ; Set the origin (starting address) to 0x7c00, typical for boot loaders


CODE_OFFSET equ 0x8
DATA_OFFSET equ 0x10

KERNEL_LOAD_SEG equ 0x1000
KERNEL_START_ADDR equ 0x100000



start:
    cli
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti

    ; Clear screen
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; Print menu
    mov si, msg_menu
    call print_string

wait_key:
    mov ah, 0x00
    int 0x16          ; BIOS keyboard read - waits for keypress

    cmp al, '1'
    je load_kernel

    ; Any other key
    mov si, msg_invalid
    call print_string
    jmp wait_key

load_kernel:
    mov si, msg_loading
    call print_string

    ; Load kernel from disk
    mov ax, KERNEL_LOAD_SEG
    mov es, ax
    mov bx, 0x0000
    mov dh, 0x00
    mov dl, 0x80
    mov cl, 0x02
    mov ch, 0x00
    mov ah, 0x02
    mov al, 8
    int 0x13

    jc disk_read_error

    jmp load_PM


; print null-terminated string pointed to by SI
print_string:
    pusha
.loop:
    lodsb
    cmp al, 0
    je .done
    mov ah, 0x0E
    int 0x10
    jmp .loop
.done:
    popa
    ret


disk_read_error:
    mov si, msg_disk_err
    call print_string
    hlt


load_PM:
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or al, 1
    mov cr0, eax
    jmp CODE_OFFSET:PModeMain


msg_menu     db 13, 10
             db "=============================", 13, 10
             db "     Welcome to SockOS       ", 13, 10
             db "=============================", 13, 10
             db 13, 10
             db "  Press 1 to launch kernel   ", 13, 10
             db 13, 10, 0

msg_loading  db 13, 10, "Loading kernel...", 13, 10, 0
msg_invalid  db "Invalid key. Press 1 to continue.", 13, 10, 0
msg_disk_err db 13, 10, "Disk read error! System halted.", 0


gdt_start:
    dd 0x0
    dd 0x0

    ; Code segment descriptor
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00

    ; Data segment descriptor
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start


[BITS 32]
PModeMain:
    mov ax, DATA_OFFSET
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov ss, ax
    mov gs, ax
    mov ebp, 0x9C00
    mov esp, ebp

    in al, 0x92
    or al, 2
    out 0x92, al

    jmp CODE_OFFSET:KERNEL_START_ADDR


times 510 - ($ - $$) db 0
dw 0xAA55
