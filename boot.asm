bits 16
org 0x7c00

mov si, 0

; Print OS boot information

print_os:
    mov ah, 0x0e
    mov al, [os + si]
    int 0x10
    add si, 1
    cmp byte [os + si], 0
    jne print_os

mov ah, 0x0e
mov al, 0x0D
int 0x10

mov ah, 0x0e
mov al, 0x0A
int 0x10


mov si, 0

print_version:
    mov ah, 0x0e
    mov al, [version + si]
    int 0x10
    add si, 1
    cmp byte [version + si], 0
    jne print_version

mov ah, 0x0e
mov al, 0x0D
int 0x10

mov ah, 0x0e
mov al, 0x0A
int 0x10

mov si, 0

print_link:
    mov ah, 0x0e
    mov al, [link + si]
    int 0x10
    add si, 1
    cmp byte [link + si], 0
    jne print_link

mov ah, 0x0e
mov al 0x0D
int 0x10

mov ah, 0x0e
mov al, 0x0A
int 0x10

mov si, 0


jmp $

; Accept keyboard input

mov si, 0
mov di, input_buffer


print_prompt:
    mov ah, 0x0e
    mov al, '>'
    int 0x10
    mov ah, 0x0e
    mov al, ' '
    int 0x10

read_input:
    mov ah, 0x0e
    int 0x16
    cmp al, 0x0D
    je done_input
    mov [di], al
    inc di
    jmp read_input









; Boot print statements

os:
    db "Sock OS", 0
version:
    db "Version 1.00.0000 Sock OS", 0
link:
    db "https://github.com/brobinson1000/Sock-OS.git", 0


times 510 - ($ - $$) db 0
dw 0xAA55
