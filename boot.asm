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

    mov byte [selectedIndex], 0
    call draw_menu
    jmp menu_input

; Menu variables
selectedIndex db 0


menu_input:
    mov ah, 0
    int 0x16

    cmp al, 0
    jne check_enter   ; normal key

    ; Special keys (arrow keys)
    int 0x16          ; get scan code in AH
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

    xor bx, bx         ; index
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
    mov al, '>'       ; highlight indicator
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



; Clear Screen
clear_screen:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    ret



; Print String
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


; Load Kernel
load_kernel:
    call clear_screen

    mov ax, 0x0000
    mov es, ax
    mov bx, 0x7E00        ; Load address

    mov ah, 0x02          ; Read sectors
    mov al, 5             ; Number of sectors
    mov ch, 0             ; Cylinder
    mov cl, 2             ; Sector
    mov dh, 0             ; Head
    mov dl, 0x00          ; Drive
    int 0x13


    jmp 0x0000:0x7E00



reboot:
    mov al, 0xFE
    out 0x64, al
    jmp $

advanced_boot:


; Strings
menu_title db "Sock OS Boot Menu",13,10,0

menuOptions:
    dw opt0
    dw opt1
    dw opt2

opt0 db "Boot Sock OS (i686)",13,10,0
opt1 db "Advanced Boot Options",13,10,0
opt2 db "Reboot",13,10,0

prompt  db "Select option: ",13,10,0

; Bootloader signature
times 510-($-$$) db 0
dw 0xAA55
