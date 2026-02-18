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
mov al, 0x0D
int 0x10

mov ah, 0x0e
mov al, 0x0A
int 0x10

mov si, 0

print_prompt:
    mov ah, 0x0e
    mov al, [prompt + si]
    int 0x10
    add si, 1
    cmp byte [prompt + si], 0
    jne print_prompt

mov ah, 0x0e
mov al, 0x0D
int 0x10

mov ah, 0x0e
mov al, 0x0A
int 0x10

mov si, 0



get_input:
    
    mov ah, 0x00
    int 0x16

    cmp al, 0x0D
    je done_input


    cmp al, 0x73
    je match_s

    jmp get_input

match_s:

    cmp byte [message_printed], 1
    je get_input

    mov si, 0
    mov ah, 0x0e
    mov al, '*'
    int 0x10
    mov al, 'S'
    int 0x10
    mov al, 'o'
    int 0x10
    mov al, 'c'
    int 0x10
    mov al, 'k'
    int 0x10
    mov al, 'O'
    int 0x10
    mov al, 'S'
    int 0x10

    mov byte [message_printed], 1

    jmp get_input


done_input:
    jmp $



; Boot print statements

os:
    db "Sock OS", 0
version:
    db "Version 1.00.0000 Sock OS", 0
link:
    db "https://github.com/brobinson1000/Sock-OS.git", 0
prompt:
    db "Boot Menu", 0 
    input_buffer db 32 ; stores space for 32 characters
    input_index db 0; track where use types

message_printed db 0

times 510 - ($ - $$) db 0
dw 0xAA55
