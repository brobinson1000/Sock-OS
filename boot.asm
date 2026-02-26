org 0x7C00
bits 16

start:
    xor ax, ax
    mov ds, ax
    mov es, ax

menu:
    call clear_screen

    mov si, menu_title
    call print_string

    mov si, option1
    call print_string

    mov si, option2
    call print_string

    mov si, option3
    call print_string

    mov si, prompt
    call print_string

    ; Wait for key press
    mov ah, 0x00
    int 0x16

    cmp al, '1'
    je load_kernel

    cmp al, '3'
    je reboot

    ; Any other key redraws menu
    jmp menu


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

    mov si, booting_msg
    call print_string

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

    jc disk_error         ; If carry flag set → error

    jmp 0x0000:0x7E00


disk_error:
    mov si, disk_msg
    call print_string
    jmp $

reboot:
    mov al, 0xFE
    out 0x64, al
    jmp $

; Strings
menu_title db 13,10,"Sock OS Boot Menu",13,10
           db "https://github.com/brobinson1000/Sock-OS", 13,10 ,0
           db "Version 1.00 ~beta", 13, 10, 1
           db "---------------------",13,10,2


option1 db "1) Sock OS",13,10,0
option2 db "2) Advanced options for Sock",13,10,0
option3 db "3) Reboot",13,10,13,10,0
prompt  db "Select option: ",0

booting_msg db 13,10,"Booting kernel...",13,10,0
disk_msg    db 13,10,"Disk read error!",13,10,0


times 510-($-$$) db 0
dw 0xAA55
