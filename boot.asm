org 0x7C00
bits 16

video_mode:
    mov ah, 0x00
    mov al, 0x03
    int 0x10

start:
    xor ax, ax
    mov ds, ax
    mov es, ax

    ; Save boot drive provided by BIOS
    mov [bootDrive], dl

    mov byte [selectedIndex], 0
    call draw_menu
    jmp menu_input

; Menu variables
selectedIndex db 0
bootDrive     db 0

menu_input:
    mov ah, 0
    int 0x16

    cmp al, 0
    jne check_enter

    int 0x16
    cmp ah, 0x48      ; Up arrow
    je move_up
    cmp ah, 0x50      ; Down arrow
    je move_down
    jmp menu_input

move_up:
    dec byte [selectedIndex]
    cmp byte [selectedIndex], 0
    jge redraw_menu
    mov byte [selectedIndex], 2
    jmp redraw_menu

move_down:
    inc byte [selectedIndex]
    cmp byte [selectedIndex], 2
    jle redraw_menu
    mov byte [selectedIndex], 0
    jmp redraw_menu

check_enter:
    cmp al, 0x0D
    je select_option
    jmp menu_input

redraw_menu:
    call draw_menu
    jmp menu_input

select_option:
    mov al, [selectedIndex]
    cmp al, 0
    je load_kernel
    cmp al, 1
    je advanced_boot
    cmp al, 2
    je reboot

draw_menu:
    call clear_screen

    mov si, menu_title
    call print_string

    mov si, prompt
    call print_string

    xor bx, bx
.draw_loop:
    mov di, bx
    shl di, 1
    mov si, [menuOptions + di]

    cmp bl, [selectedIndex]
    je .highlight_option
    call print_string
    jmp .next_item

.highlight_option:
    call print_highlighted_string
.next_item:
    inc bx
    cmp bx, 3
    jl .draw_loop

    ret

print_highlighted_string:
    mov ah, 0x0E
    mov al, '>'
    int 0x10

.print_loop_highlight:
    lodsb
    or al, al
    jz .done_highlight
    mov ah, 0x0E
    int 0x10
    jmp .print_loop_highlight
.done_highlight:
    ret

clear_screen:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    ret

print_string:
.print_loop:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp .print_loop
.done:
    ret

; Load kernel, switch to protected mode, jump in
load_kernel:
    call clear_screen

    mov ax, 0x0000
    mov es, ax
    mov bx, 0x7E00        ; Load address

    mov ah, 0x02          ; Read sectors
    mov al, 5             ; Number of sectors
    mov ch, 0             ; Cylinder
    mov cl, 2             ; Sector (starts at 2, right after bootloader)
    mov dh, 0             ; Head
    mov dl, [bootDrive]   ; FIX: use the drive BIOS gave us (0x80 for HDD)
    int 0x13

    jc disk_error         ; Carry flag set = read failed

    ; Enable A20 line
    in al, 0x92
    or al, 2
    out 0x92, al

    ; Load GDT
    cli
    lgdt [gdt_descriptor]

    ; Protected Mode 
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; Far jump to flush pipeline and enter 32-bit code segment (selector 0x08)
    jmp 0x08:protected_mode_start

disk_error:
    mov si, disk_err_msg
    call print_string
    jmp $

reboot:
    mov al, 0xFE
    out 0x64, al
    jmp $

advanced_boot:
    jmp $   ; maybe fix videos settings in the future

; GDT
gdt_start:

gdt_null:              
    dd 0x00000000
    dd 0x00000000

gdt_code:               ; code segment: base=0, limit=4GB, 32-bit, ring 0
    dw 0xFFFF           ; limit low
    dw 0x0000           ; base low
    db 0x00             ; base mid
    db 10011010b        ; access: present, ring0, code, executable, readable
    db 11001111b        ; flags: 4KB granularity, 32-bit + limit high nibble
    db 0x00             ; base high

gdt_data:               ; data segment: same but writable, not executable
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b        ; access: present, ring0, data, writable
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1   ; size
    dd gdt_start                  ; address

; 32-bit protected mode entry (still in boot sector)
bits 32
protected_mode_start:
    ; Set all data segments to data selector (0x10)
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    ; Jump to kernel entry point
    jmp 0x7E00

; Strings
bits 16
menu_title db "Sock OS Boot Menu",13,10,0

menuOptions:
    dw opt0
    dw opt1
    dw opt2

opt0 db "Boot Sock OS (i686)",13,10,0
opt1 db "Advanced Boot Options",13,10,0
opt2 db "Reboot",13,10,0

prompt       db "Select option: ",13,10,0
disk_err_msg db "Disk read error!",13,10,0

; boot sig
times 510-($-$$) db 0
dw 0xAA55
